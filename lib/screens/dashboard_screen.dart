import 'package:flutter/material.dart';
import '../models/landslide_data.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TelemetryData _telemetry = DummyData.currentTelemetry;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRiskData();
  }

  Future<void> _fetchRiskData() async {
    try {
      final data = await ApiService.getRisk();
      if (mounted) {
        setState(() {
          _telemetry = data;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = _telemetry;
    final riskColor = TelemetryData.getRiskColor(telemetry.overallRiskScore);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: LinearProgressIndicator(color: Color(0xFF38BDF8), backgroundColor: Colors.white10),
            ),
          // Banner Notice
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: riskColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HIGH DISASTER WARNING ACTIVE — WESTERN GHATS & GARHWAL SECTORS',
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _errorMessage != null
                            ? 'Backend Notice: $_errorMessage (Showing cached telemetry)'
                            : 'Automated early-warning systems active. 3 high-probability slopes triggered.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Header Row / Hero section
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                children: [
                  // Overall Risk Card
                  Expanded(
                    flex: isWide ? 5 : 0,
                    child: Card(
                      elevation: 4,
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: riskColor.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Overall Landslide Risk Score',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: riskColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: riskColor),
                                  ),
                                  child: Text(
                                    telemetry.riskCategory,
                                    style: TextStyle(
                                      color: riskColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Radial Gauge Visualizer
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 170,
                                  height: 170,
                                  child: CircularProgressIndicator(
                                    value: telemetry.overallRiskScore / 100,
                                    strokeWidth: 16,
                                    backgroundColor: Colors.white10,
                                    color: riskColor,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${telemetry.overallRiskScore.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: riskColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Index (0-100)',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStatus('Threshold', '65.0%', Colors.white60),
                                Container(height: 20, width: 1, color: Colors.white10),
                                _buildMiniStatus('Stability Status', 'UNSTABLE', riskColor),
                                Container(height: 20, width: 1, color: Colors.white10),
                                _buildMiniStatus('Confidence', '94.2%', const Color(0xFF38BDF8)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (!isWide) const SizedBox(height: 16) else const SizedBox(width: 16),

                  // Quick Action & Summary Box
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: Column(
                      children: [
                        _buildQuickTelemetryBox(
                          title: 'Active Landslides Tracked',
                          value: '${telemetry.activeLandslides}',
                          unit: 'Zones Impacted',
                          icon: Icons.landscape,
                          color: const Color(0xFFEF4444),
                          subtext: 'Shimla, Wayanad & Kedarnath',
                        ),
                        const SizedBox(height: 16),
                        _buildQuickTelemetryBox(
                          title: 'Sensor Grid Status',
                          value: '48 / 50',
                          unit: 'Nodes Operational',
                          icon: Icons.sensors,
                          color: const Color(0xFF10B981),
                          subtext: '2 nodes offline due to power loss',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Key Telemetry Metrics Grid
          const Text(
            'Live Sensor Telemetry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1;
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 2;
              }
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  _buildMetricCard(
                    title: 'Rainfall Rate',
                    value: '${telemetry.rainfallMm}',
                    unit: 'mm/hr',
                    icon: Icons.water_drop,
                    color: const Color(0xFF38BDF8),
                    trend: '+18.4% from avg',
                    trendUp: true,
                  ),
                  _buildMetricCard(
                    title: 'Soil Moisture',
                    value: '${telemetry.soilMoisturePercent}',
                    unit: '% Saturation',
                    icon: Icons.grass,
                    color: const Color(0xFFF59E0B),
                    trend: 'Near Saturation Point',
                    trendUp: true,
                  ),
                  _buildMetricCard(
                    title: 'Slope Angle',
                    value: '${telemetry.slopeAngle}',
                    unit: 'degrees (°)',
                    icon: Icons.terrain,
                    color: const Color(0xFFA855F7),
                    trend: 'Critical Steepness',
                    trendUp: false,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Recent Alerts Stream Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Critical Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF38BDF8)),
                label: const Text('View All Alerts', style: TextStyle(color: Color(0xFF38BDF8))),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: DummyData.sampleAlerts.take(3).length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final alert = DummyData.sampleAlerts[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(alert.severity).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: _getSeverityColor(alert.severity),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  alert.id,
                                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${alert.location} • ${alert.timestamp}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      backgroundColor: _getSeverityColor(alert.severity).withValues(alpha: 0.2),
                      side: BorderSide(color: _getSeverityColor(alert.severity)),
                      label: Text(
                        alert.severity.name.toUpperCase(),
                        style: TextStyle(
                          color: _getSeverityColor(alert.severity),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildMiniStatus(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  static Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                trendUp ? Icons.trending_up : Icons.trending_flat,
                color: trendUp ? color : Colors.white38,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  color: trendUp ? color : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildQuickTelemetryBox({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  subtext,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return const Color(0xFFEF4444);
      case AlertSeverity.high:
        return const Color(0xFFF97316);
      case AlertSeverity.warning:
        return const Color(0xFFFACC15);
      case AlertSeverity.info:
        return const Color(0xFF38BDF8);
    }
  }
}
