import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/landslide_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // ---------------- GET RISK ----------------

  static Future<TelemetryData> getRisk() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/risk'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TelemetryData.fromJson(data);
      } else {
        throw Exception(
          'Failed to load risk telemetry '
          '(Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Backend service unavailable: $e');
    }
  }

  // ---------------- GET ALERTS ----------------

  static Future<List<AlertItem>> getAlerts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/alerts'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);

        return list
            .map(
              (item) =>
                  AlertItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load alerts '
          '(Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Backend service unavailable: $e');
    }
  }

  // ---------------- GET EMERGENCIES ----------------

  static Future<List<EmergencyReport>> getEmergencies() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/emergencies'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);

        return list
            .map(
              (item) =>
                  EmergencyReport.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load emergency reports '
          '(Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Backend service unavailable: $e');
    }
  }

  // ---------------- RISK PREDICTION ----------------

  static Future<PredictionResult> predictRisk({
    required double rainfall,
    required double soilMoisture,
    required double slope,
    required double vegetation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/prediction'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'rainfall': rainfall,
              'soilMoisture': soilMoisture,
              'slope': slope,
              'vegetation': vegetation,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return PredictionResult.fromJson(data);
      } else {
        throw Exception(
          'Failed to run risk prediction '
          '(Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Backend prediction service unavailable: $e',
      );
    }
  }

  // ---------------- CREATE EMERGENCY REPORT ----------------

  static Future<EmergencyReport> createEmergencyReport({
    required String id,
    required String location,
    required String severity,
    required String description,
    required String reporterName,
    required String timestamp,
    required String status,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/emergency'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'id': id,
              'location': location,
              'severity': severity,
              'description': description,
              'reporterName': reporterName,
              'timestamp': timestamp,
              'status': status,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return EmergencyReport.fromJson(data);
      } else {
        throw Exception(
          'Failed to submit emergency report '
          '(Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Emergency submission service unavailable: $e',
      );
    }
  }
}