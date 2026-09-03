import 'package:flutter/material.dart';
import '../models/landslide_data.dart';
import '../services/api_service.dart';

class RiskPredictionScreen extends StatefulWidget {
  const RiskPredictionScreen({super.key});

  @override
  State<RiskPredictionScreen> createState() => _RiskPredictionScreenState();
}

class _RiskPredictionScreenState extends State<RiskPredictionScreen> {
  // Input parameters
  double _rainfall = 120.0; // 0 to 300 mm/hr
  double _soilMoisture = 75.0; // 0 to 100 %
  double _slopeAngle = 38.0; // 0 to 75 degrees
  double _vegetationIndex = 0.4; // 0 (Bare rock/degraded) to 1.0 (Dense vegetation)

  double? _apiPredictedScore;
  String? _apiPredictedCategory;
  bool _isPredicting = false;

  Future<void> _runBackendPrediction() async {
    setState(() {
      _isPredicting = true;
    });

    try {
      final res = await ApiService.predictRisk(
        rainfall: _rainfall,
        soilMoisture: _soilMoisture,
        slope: _slopeAngle,
        vegetation: _vegetationIndex * 100,
      );

      if (mounted) {
        setState(() {
          _apiPredictedScore = res.riskScore;
          _apiPredictedCategory = res.riskLevel.toUpperCase().contains('RISK')
              ? res.riskLevel.toUpperCase()
              : '${res.riskLevel.toUpperCase()} RISK';
          _isPredicting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend Prediction Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Calculate predicted risk score
  double get _predictedRiskScore {
    if (_apiPredictedScore != null) return _apiPredictedScore!;

    double rainFactor = (_rainfall / 250.0).clamp(0.0, 1.0) * 35;
    double moistureFactor = (_soilMoisture / 100.0).clamp(0.0, 1.0) * 35;
    double slopeFactor = (_slopeAngle / 60.0).clamp(0.0, 1.0) * 30;
    double vegMitigation = _vegetationIndex * 15;

    double score = (rainFactor + moistureFactor + slopeFactor - vegMitigation).clamp(0.0, 100.0);
    return score;
  }

  String get _riskCategory {
    if (_apiPredictedCategory != null) return _apiPredictedCategory!;

    double score = _predictedRiskScore;
    if (score >= 75) return 'CRITICAL RISK';
    if (score >= 50) return 'HIGH RISK';
    if (score >= 25) return 'MODERATE RISK';
    return 'LOW RISK';
  }

  @override
  Widget build(BuildContext context) {
    final predictedScore = _predictedRiskScore;
    final riskColor = TelemetryData.getRiskColor(predictedScore);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Landslide Risk Predictive Simulation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Adjust geotechnical and meteorological variables to simulate slope stability',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),

          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                children: [
                  // Inputs Panel
                  Expanded(
                    flex: isWide ? 6 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.tune, color: Color(0xFF38BDF8), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Simulation Variables',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 28),

                          // 1. Rainfall Input Slider
                          _buildSliderTile(
                            label: 'Cumulative Rainfall Rate',
                            valueText: '${_rainfall.toStringAsFixed(1)} mm/hr',
                            value: _rainfall,
                            min: 0,
                            max: 300,
                            activeColor: const Color(0xFF38BDF8),
                            icon: Icons.water_drop,
                            onChanged: (val) => setState(() => _rainfall = val),
                          ),

                          const SizedBox(height: 16),

                          // 2. Soil Moisture Input Slider
                          _buildSliderTile(
                            label: 'Soil Moisture Saturation',
                            valueText: '${_soilMoisture.toStringAsFixed(1)} %',
                            value: _soilMoisture,
                            min: 0,
                            max: 100,
                            activeColor: const Color(0xFFF59E0B),
                            icon: Icons.grass,
                            onChanged: (val) => setState(() => _soilMoisture = val),
                          ),

                          const SizedBox(height: 16),

                          // 3. Slope Angle Slider
                          _buildSliderTile(
                            label: 'Hillside Slope Angle',
                            valueText: '${_slopeAngle.toStringAsFixed(1)}°',
                            value: _slopeAngle,
                            min: 0,
                            max: 75,
                            activeColor: const Color(0xFFA855F7),
                            icon: Icons.terrain,
                            onChanged: (val) => setState(() => _slopeAngle = val),
                          ),

                          const SizedBox(height: 16),

                          // 4. Vegetation Protection Index Slider
                          _buildSliderTile(
                            label: 'Vegetation Cover Index (Root Stability)',
                            valueText: _vegetationIndex < 0.3 ? 'Sparse / Bare' : (_vegetationIndex < 0.7 ? 'Moderate' : 'Dense Forest'),
                            value: _vegetationIndex,
                            min: 0.0,
                            max: 1.0,
                            activeColor: const Color(0xFF10B981),
                            icon: Icons.park,
                            onChanged: (val) => setState(() => _vegetationIndex = val),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white24),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _rainfall = 120.0;
                                      _soilMoisture = 75.0;
                                      _slopeAngle = 38.0;
                                      _vegetationIndex = 0.4;
                                      _apiPredictedScore = null;
                                      _apiPredictedCategory = null;
                                    });
                                  },
                                  child: const Text('Reset Defaults'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF38BDF8),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: _isPredicting ? null : _runBackendPrediction,
                                  icon: _isPredicting
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                      : const Icon(Icons.bolt),
                                  label: Text(_isPredicting ? 'PREDICTING...' : 'RUN AI PREDICTION'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),

                  // Prediction Output Panel
                  Expanded(
                    flex: isWide ? 5 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: riskColor.withValues(alpha: 0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: riskColor.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Predicted Failure Risk Score',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Large Animated Gauge Display
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: riskColor.withValues(alpha: 0.1),
                              border: Border.all(color: riskColor, width: 3),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  predictedScore.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: riskColor,
                                  ),
                                ),
                                const Text(
                                  'OUT OF 100',
                                  style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Chip(
                            backgroundColor: riskColor.withValues(alpha: 0.2),
                            side: BorderSide(color: riskColor),
                            label: Text(
                              _riskCategory,
                              style: TextStyle(
                                color: riskColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 12),

                          const Text(
                            'Risk Factor Breakdown',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildFactorBar('Rainfall Trigger', (_rainfall / 300.0).clamp(0.0, 1.0), const Color(0xFF38BDF8)),
                          const SizedBox(height: 10),
                          _buildFactorBar('Soil Saturation', (_soilMoisture / 100.0).clamp(0.0, 1.0), const Color(0xFFF59E0B)),
                          const SizedBox(height: 10),
                          _buildFactorBar('Slope Angle Threat', (_slopeAngle / 75.0).clamp(0.0, 1.0), const Color(0xFFA855F7)),
                          const SizedBox(height: 10),
                          _buildFactorBar('Root Stability Shield', _vegetationIndex, const Color(0xFF10B981)),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: riskColor, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _getRecommendationText(predictedScore),
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required Color activeColor,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: activeColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            Text(
              valueText,
              style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.2),
            inactiveTrackColor: Colors.white10,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFactorBar(String label, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            Text('${(ratio * 100).toInt()}%', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _getRecommendationText(double score) {
    if (score >= 75) {
      return 'CRITICAL: High slope movement probable within 2 hours. Mandatory evacuation recommended.';
    } else if (score >= 50) {
      return 'WARNING: Slope stability degrading. Restrict traffic and mobilize SDRF inspection teams.';
    } else if (score >= 25) {
      return 'MODERATE: Monitor telemetry closely. Heightened alert status for slope sensor node S-02.';
    }
    return 'SAFE: Slope parameters within normal stability limits. Low landslide probability.';
  }
}
