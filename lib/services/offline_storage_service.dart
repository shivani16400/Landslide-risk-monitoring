import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/landslide_data.dart';

/// Service for persisting emergency reports locally while the device is offline.
///
/// Reports are stored in [SharedPreferences] under [_key] as a JSON-encoded
/// list of serialised [EmergencyReport] objects.  Once a report has been
/// successfully synced to the backend it should be removed via [removeReport].
class OfflineStorageService {
  static const String _key = 'pending_emergency_reports';

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  /// Serialises [report] to JSON and appends it to the pending-reports list.
  ///
  /// Duplicate IDs are silently ignored so that re-submitting a form never
  /// creates duplicate offline entries.
  static Future<void> saveReport(EmergencyReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getPendingReports();

    // Guard: skip duplicates
    final alreadyStored = existing.any((r) => r.id == report.id);
    if (alreadyStored) return;

    existing.add(report);

    final jsonList =
        existing.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  // ---------------------------------------------------------------------------
  // Retrieve
  // ---------------------------------------------------------------------------

  /// Returns all pending [EmergencyReport]s that have not yet been synced.
  ///
  /// Returns an empty list when there are no pending reports or when
  /// a stored entry is malformed (corrupt entries are skipped).
  static Future<List<EmergencyReport>> getPendingReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    final reports = <EmergencyReport>[];
    for (final item in jsonList) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        reports.add(EmergencyReport.fromJson(map));
      } catch (_) {
        // Skip malformed entries rather than crashing.
      }
    }
    return reports;
  }

  // ---------------------------------------------------------------------------
  // Remove
  // ---------------------------------------------------------------------------

  /// Removes the report with [reportId] from the pending list.
  ///
  /// Call this after the report has been successfully synced to the backend.
  static Future<void> removeReport(String reportId) async {
    final existing = await getPendingReports();
    final updated = existing.where((r) => r.id != reportId).toList();

    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        updated.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  // ---------------------------------------------------------------------------
  // Check
  // ---------------------------------------------------------------------------

  /// Returns `true` if there is at least one report waiting to be synced.
  static Future<bool> hasPendingReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Clear (utility / testing)
  // ---------------------------------------------------------------------------

  /// Removes **all** pending reports from local storage.
  ///
  /// Useful for testing or when the user explicitly clears offline data.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
