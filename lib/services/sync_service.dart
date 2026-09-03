import '../services/api_service.dart';
import '../services/offline_storage_service.dart';

/// Synchronises pending offline emergency reports with the Spring Boot backend.
///
/// Call [syncPendingReports] once at app startup (and optionally whenever
/// connectivity is restored). It is fully error-safe: a failure to sync one
/// report never affects the remaining ones, and no report is deleted before
/// a confirmed successful submission.
class SyncService {
  /// Attempts to upload every pending offline emergency report to the backend.
  ///
  /// For each report:
  /// - On success  → removes it from [OfflineStorageService].
  /// - On failure  → leaves it in [OfflineStorageService] for the next attempt.
  ///
  /// Returns the number of reports successfully synced.
  static Future<int> syncPendingReports() async {
    int synced = 0;

    // Check quickly whether there is anything to do.
    final hasPending = await OfflineStorageService.hasPendingReports();
    if (!hasPending) return 0;

    final pending = await OfflineStorageService.getPendingReports();

    for (final report in pending) {
      try {
        // Re-submit the stored report to the backend using the existing API.
        await ApiService.createEmergencyReport(
          id: report.id,
          location: report.location,
          severity: report.severity,
          description: report.description,
          reporterName: report.reporterName,
          timestamp: report.timestamp,
          status: report.status,
        );

        // Only remove from local storage AFTER a confirmed successful upload.
        await OfflineStorageService.removeReport(report.id);
        synced++;
      } catch (_) {
        // Submission failed (backend offline / network error).
        // Leave the report in local storage; it will be retried next time.
      }
    }

    return synced;
  }
}
