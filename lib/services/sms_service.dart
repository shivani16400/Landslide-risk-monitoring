import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../models/landslide_data.dart';

/// SMS fallback service for emergency reporting.
///
/// On **Android** this opens the native SMS application with the recipient
/// number and message body pre-filled.  The user must tap "Send" inside
/// their own SMS app — nothing is sent automatically.
///
/// On **Web / Chrome** the `sms:` scheme is not supported by the browser,
/// so [sendEmergencySms] returns [SmsResult.webUnsupported] and the caller
/// should display an appropriate message.
///
/// No SEND_SMS permission is required because we only launch an Intent;
/// the OS SMS app handles the actual transmission.
class SmsService {
  // ---------------------------------------------------------------------------
  // Configuration — change this to a real emergency number before deployment.
  // ---------------------------------------------------------------------------

  /// ⚠️ DEMO placeholder — replace with the actual District Disaster
  /// Management Authority (DDMA) or SDRF control-room number before go-live.
  static const String emergencyContactNumber = '+91-XXXXXXXXXX'; // DEMO

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Attempts to open the native SMS app with [report] details pre-filled.
  ///
  /// Returns a [SmsResult] indicating what happened.
  static Future<SmsResult> sendEmergencySms(EmergencyReport report) async {
    // Web browsers do not have SMS hardware.
    if (kIsWeb) return SmsResult.webUnsupported;

    final body = _buildMessageBody(report);

    // RFC 5724 `sms:` URI — supported on Android via the SMS intent.
    final uri = Uri(
      scheme: 'sms',
      path: emergencyContactNumber,
      queryParameters: {'body': body},
    );

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) return SmsResult.launchFailed;

    final launched = await launchUrl(uri);
    return launched ? SmsResult.launched : SmsResult.launchFailed;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` for severity levels that warrant an SMS fallback offer.
  static bool isCriticalOrHigh(String severity) {
    final lower = severity.toLowerCase();
    return lower.contains('critical') ||
        lower.contains('extreme') ||
        lower.contains('high');
  }

  static String _buildMessageBody(EmergencyReport report) {
    return '[LANDSLIDE EMERGENCY ALERT]\n'
        'ID: ${report.id}\n'
        'Location: ${report.location}\n'
        'Severity: ${report.severity}\n'
        'Description: ${report.description}\n'
        'Reporter: ${report.reporterName}\n'
        'Time: ${report.timestamp}\n'
        'Status: ${report.status}\n'
        '--- Sent via Landslide Risk Monitoring System ---';
  }
}

/// Result codes returned by [SmsService.sendEmergencySms].
enum SmsResult {
  /// Native SMS app was opened successfully (user still needs to tap Send).
  launched,

  /// Running on a web browser — SMS hardware unavailable.
  webUnsupported,

  /// The `sms:` URL could not be launched (SMS app not found, etc.).
  launchFailed,
}
