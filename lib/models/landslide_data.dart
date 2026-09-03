import 'package:flutter/material.dart';

class TelemetryData {
  final double overallRiskScore; // 0 - 100
  final String riskCategory; // Critical, High, Moderate, Low
  final double rainfallMm; // mm/hr
  final double soilMoisturePercent; // %
  final double slopeAngle; // degrees
  final int activeLandslides;

  const TelemetryData({
    required this.overallRiskScore,
    required this.riskCategory,
    required this.rainfallMm,
    required this.soilMoisturePercent,
    required this.slopeAngle,
    required this.activeLandslides,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    final score = (json['riskScore'] as num?)?.toDouble() ?? 0.0;
    final level = (json['riskLevel'] as String?) ?? 'LOW';
    final rain = (json['rainfall'] as num?)?.toDouble() ?? 0.0;
    final moisture = (json['soilMoisture'] as num?)?.toDouble() ?? 0.0;
    final slp = (json['slope'] as num?)?.toDouble() ?? 0.0;

    return TelemetryData(
      overallRiskScore: score,
      riskCategory: level.toUpperCase().contains('RISK') ? level.toUpperCase() : '${level.toUpperCase()} RISK',
      rainfallMm: rain,
      soilMoisturePercent: moisture,
      slopeAngle: slp,
      activeLandslides: score >= 75 ? 3 : (score >= 50 ? 1 : 0),
    );
  }

  static Color getRiskColor(double score) {
    if (score >= 75) return const Color(0xFFEF4444); // Critical Red
    if (score >= 50) return const Color(0xFFF97316); // High Orange
    if (score >= 25) return const Color(0xFFFACC15); // Moderate Yellow
    return const Color(0xFF22C55E); // Low Green
  }
}

enum AlertSeverity { critical, high, warning, info }

class AlertItem {
  final String id;
  final String title;
  final String location;
  final String timestamp;
  final AlertSeverity severity;
  final String description;
  bool isAcknowledged;

  AlertItem({
    required this.id,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.severity,
    required this.description,
    this.isAcknowledged = false,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    AlertSeverity parseSeverity(String? sev) {
      if (sev == null) return AlertSeverity.info;
      switch (sev.toUpperCase()) {
        case 'CRITICAL':
          return AlertSeverity.critical;
        case 'HIGH':
          return AlertSeverity.high;
        case 'WARNING':
          return AlertSeverity.warning;
        case 'INFO':
        default:
          return AlertSeverity.info;
      }
    }

    return AlertItem(
      id: json['id']?.toString() ?? 'ALT-000',
      title: json['title'] as String? ?? 'Alert Notice',
      location: json['location'] as String? ?? 'Unknown Location',
      timestamp: json['timestamp'] as String? ?? 'Recently',
      severity: parseSeverity(json['severity'] as String?),
      description: json['description'] as String? ?? '',
      isAcknowledged: json['acknowledged'] as bool? ?? json['isAcknowledged'] as bool? ?? false,
    );
  }
}

class EmergencyReport {
  final String id;
  final String location;
  final String severity;
  final String description;
  final String reporterName;
  final String timestamp;
  final String status; // Pending, Verified, Actioned

  EmergencyReport({
    required this.id,
    required this.location,
    required this.severity,
    required this.description,
    required this.reporterName,
    required this.timestamp,
    required this.status,
  });

  factory EmergencyReport.fromJson(Map<String, dynamic> json) {
    return EmergencyReport(
      id: json['id'] as String? ?? 'REP-000',
      location: json['location'] as String? ?? 'Unknown',
      severity: json['severity'] as String? ?? 'Moderate',
      description: json['description'] as String? ?? '',
      reporterName: json['reporterName'] as String? ?? 'Anonymous',
      timestamp: json['timestamp'] as String? ?? 'Recently',
      status: json['status'] as String? ?? 'Pending Verification',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'severity': severity,
      'description': description,
      'reporterName': reporterName,
      'timestamp': timestamp,
      'status': status,
    };
  }
}

class PredictionResult {
  final double riskScore;
  final String riskLevel;

  const PredictionResult({
    required this.riskScore,
    required this.riskLevel,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['riskLevel'] as String? ?? 'UNKNOWN',
    );
  }
}

class RiskZone {
  final String name;
  final String region;
  final double riskScore;
  final Offset coordinates; // Relative x,y on map grid (0.0 to 1.0)
  final String status;
  final String primaryTrigger;

  const RiskZone({
    required this.name,
    required this.region,
    required this.riskScore,
    required this.coordinates,
    required this.status,
    required this.primaryTrigger,
  });
}

// Global sample data
class DummyData {
  static const currentTelemetry = TelemetryData(
    overallRiskScore: 78.5,
    riskCategory: 'CRITICAL RISK',
    rainfallMm: 142.8,
    soilMoisturePercent: 88.4,
    slopeAngle: 42.5,
    activeLandslides: 3,
  );

  static final List<AlertItem> sampleAlerts = [
    AlertItem(
      id: 'ALT-1092',
      title: 'High Slope Instability Detected',
      location: 'NH-108, Uttarkashi Sector B',
      timestamp: '10 mins ago',
      severity: AlertSeverity.critical,
      description: 'Soil saturation reached 92%. Active soil creep recorded on 45° slope. Immediate traffic diversion recommended.',
    ),
    AlertItem(
      id: 'ALT-1091',
      title: 'Flash Rainfall Warning',
      location: 'Shimla Upper Ridge Zone 4',
      timestamp: '28 mins ago',
      severity: AlertSeverity.high,
      description: 'Intense precipitation exceeding 45mm/hr detected by Sensor Node S-04. High risk of debris flow.',
    ),
    AlertItem(
      id: 'ALT-1088',
      title: 'Sensor Node Disconnection',
      location: 'Munnar Hill Pass Node 12',
      timestamp: '1 hr ago',
      severity: AlertSeverity.warning,
      description: 'Telemetry link lost due to power surge. Backup battery active. Maintenance team dispatched.',
    ),
    AlertItem(
      id: 'ALT-1084',
      title: 'Geotechnical Soil Creep Alert',
      location: 'Darjeeling Teesta Valley',
      timestamp: '3 hrs ago',
      severity: AlertSeverity.info,
      description: 'Minor lateral displacement of 3mm detected over 6 hours. Monitoring closely.',
    ),
  ];

  static final List<RiskZone> riskZones = [
    const RiskZone(
      name: 'Wayanad Pass Sector 3',
      region: 'Western Ghats, Kerala',
      riskScore: 88.0,
      coordinates: Offset(0.32, 0.68),
      status: 'RED ALERT',
      primaryTrigger: 'Heavy Monsoonal Downpour',
    ),
    const RiskZone(
      name: 'Kedarnath Access Corridor',
      region: 'Garhwal Himalayas, Uttarakhand',
      riskScore: 82.4,
      coordinates: Offset(0.65, 0.28),
      status: 'RED ALERT',
      primaryTrigger: 'Glacial Outflow & Steep Cut Slope',
    ),
    const RiskZone(
      name: 'Shimla Bypass Sector 2',
      region: 'Himachal Pradesh',
      riskScore: 64.2,
      coordinates: Offset(0.55, 0.35),
      status: 'HIGH WARNING',
      primaryTrigger: 'Unstable Debris Heap & Road Cutting',
    ),
    const RiskZone(
      name: 'Teesta River Basin Zone 1',
      region: 'Sikkim',
      riskScore: 49.5,
      coordinates: Offset(0.82, 0.42),
      status: 'MODERATE WATCH',
      primaryTrigger: 'River Bank Erosion',
    ),
    const RiskZone(
      name: 'Nilgiri Mountain Rail Line',
      region: 'Tamil Nadu',
      riskScore: 24.1,
      coordinates: Offset(0.38, 0.82),
      status: 'NORMAL',
      primaryTrigger: 'Low Rainfall / Stable Rock Structure',
    ),
  ];

  static final List<EmergencyReport> sampleReports = [
    EmergencyReport(
      id: 'REP-401',
      location: 'NH-58 Near Chamoli Curve',
      severity: 'Critical / High',
      description: 'Boulders fell across 2 lanes. Mudslides starting from mid-hill.',
      reporterName: 'Officer R. Sharma (SDRF)',
      timestamp: '09:45 AM Today',
      status: 'Dispatched',
    ),
    EmergencyReport(
      id: 'REP-398',
      location: 'Valparai Hill Road Km 14',
      severity: 'Moderate',
      description: 'Tree uprooted causing small slope slip. One lane blocked.',
      reporterName: 'Local Control Room',
      timestamp: 'Yesterday',
      status: 'Actioned',
    ),
  ];
}
