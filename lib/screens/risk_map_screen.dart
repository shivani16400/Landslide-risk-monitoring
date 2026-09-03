import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/landslide_data.dart';
import '../services/api_service.dart';

class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  TelemetryData? _liveTelemetry;

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedLayer = 'Hazard Risk Zones';

  final List<_MapLocation> _locations = [
    const _MapLocation(
      name: 'NH-58 Km 42',
      score: 90,
      trigger: 'Heavy rainfall + high soil moisture',
      soilType: 'Loose rock and soil',
      population: '1,240',
      sensors: 12,
    ),
    const _MapLocation(
      name: 'Joshimath',
      score: 82,
      trigger: 'High rainfall + steep slope',
      soilType: 'Rocky mountain soil',
      population: '980',
      sensors: 9,
    ),
    const _MapLocation(
      name: 'Govindghat',
      score: 68,
      trigger: 'Slope instability',
      soilType: 'Weathered rock',
      population: '620',
      sensors: 7,
    ),
    const _MapLocation(
      name: 'Kedarnath Road',
      score: 47,
      trigger: 'Moderate rainfall',
      soilType: 'Mountain soil',
      population: '430',
      sensors: 6,
    ),
    const _MapLocation(
      name: 'Badrinath Route',
      score: 31,
      trigger: 'Low rainfall',
      soilType: 'Stable soil',
      population: '280',
      sensors: 5,
    ),
    const _MapLocation(
      name: 'Srinagar Sector 18',
      score: 18,
      trigger: 'Stable conditions',
      soilType: 'Dense soil',
      population: '510',
      sensors: 4,
    ),
  ];

  late _MapLocation _selectedLocation;

  @override
  void initState() {
    super.initState();

    _selectedLocation = _locations.first;

    _loadLiveRisk();
  }

  Future<void> _loadLiveRisk() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final telemetry = await ApiService.getRisk();

      if (!mounted) return;

      setState(() {
        _liveTelemetry = telemetry;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to connect to backend';
      });
    }
  }

  Color _riskColor(int score) {
    if (score >= 76) {
      return Colors.redAccent;
    }

    if (score >= 51) {
      return Colors.orangeAccent;
    }

    if (score >= 26) {
      return Colors.amber;
    }

    return Colors.greenAccent;
  }

  String _riskLevel(int score) {
    if (score >= 76) {
      return 'CRITICAL';
    }

    if (score >= 51) {
      return 'HIGH';
    }

    if (score >= 26) {
      return 'MODERATE';
    }

    return 'LOW';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isCompact = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: SafeArea(
        child: isCompact
            ? _buildCompactLayout()
            : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: _buildMapSection(),
              ),
              Expanded(
                flex: 3,
                child: _buildDetailsPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: _buildMapSection(),
                ),
                _buildDetailsPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1929),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.map_outlined,
            color: Colors.cyanAccent,
            size: 26,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'GIS RISK MAP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildLiveStatus(),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _isLoading ? null : _loadLiveRisk,
            tooltip: 'Refresh risk data',
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatus() {
    final connected = _liveTelemetry != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: connected
            ? Colors.greenAccent.withValues(alpha: 0.10)
            : Colors.redAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: connected
              ? Colors.greenAccent.withValues(alpha: 0.50)
              : Colors.redAccent.withValues(alpha: 0.50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: connected
                  ? Colors.greenAccent
                  : Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            connected ? 'LIVE BACKEND' : 'OFFLINE',
            style: TextStyle(
              color: connected
                  ? Colors.greenAccent
                  : Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: EnhancedGisMapPainter(
                showRainfall: _selectedLayer == 'Rainfall Radar',
                showSensors: _selectedLayer == 'Sensor Grid',
              ),
            ),
          ),

          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _buildMapMarkers(
                    constraints.biggest,
                  ),
                );
              },
            ),
          ),

          Positioned(
            left: 16,
            top: 16,
            child: _buildLayerSelector(),
          ),

          Positioned(
            left: 16,
            bottom: 16,
            child: _buildMapLegend(),
          ),

          Positioned(
            right: 16,
            bottom: 16,
            child: _buildMapStats(),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMapMarkers(Size size) {
    final positions = [
      const Offset(0.24, 0.28),
      const Offset(0.43, 0.20),
      const Offset(0.60, 0.35),
      const Offset(0.34, 0.57),
      const Offset(0.68, 0.62),
      const Offset(0.82, 0.40),
    ];

    return List.generate(
      _locations.length,
      (index) {
        final location = _locations[index];

        final left = size.width * positions[index].dx;
        final top = size.height * positions[index].dy;

        final selected =
            location.name == _selectedLocation.name;

        final color = _riskColor(location.score);

        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedLocation = location;
              });
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: EdgeInsets.all(
                    selected ? 7 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: selected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: selected ? 18 : 10,
                      ),
                    ],
                  ),
                  child: Container(
                    width: selected ? 30 : 24,
                    height: selected ? 30 : 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${location.score}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xDD07111F),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayerSelector() {
    final layers = [
      'Hazard Risk Zones',
      'Rainfall Radar',
      'Sensor Grid',
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xDD07111F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: layers.map(
          (layer) {
            final selected = _selectedLayer == layer;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLayer = layer;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.cyanAccent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  layer,
                  style: TextStyle(
                    color: selected
                        ? Colors.cyanAccent
                        : Colors.white70,
                    fontSize: 10,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xDD07111F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RISK LEVEL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _legendItem(
            'Critical',
            Colors.redAccent,
          ),
          _legendItem(
            'High',
            Colors.orangeAccent,
          ),
          _legendItem(
            'Moderate',
            Colors.amber,
          ),
          _legendItem(
            'Low',
            Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    String label,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xDD07111F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'MONITORING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '6 zones • 43 sensors',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final location = _selectedLocation;

    final color = _riskColor(location.score);

    final level = _riskLevel(location.score);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        0,
        16,
        16,
        16,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SELECTED ZONE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              location.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildRiskScoreCard(
              location.score,
              level,
              color,
            ),

            const SizedBox(height: 20),

            const Text(
              'RISK FACTORS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            _detailRow(
              Icons.warning_amber_rounded,
              'Primary Trigger',
              location.trigger,
            ),

            _detailRow(
              Icons.landscape_outlined,
              'Soil Type',
              location.soilType,
            ),

            _detailRow(
              Icons.people_outline,
              'Estimated Population',
              location.population,
            ),

            _detailRow(
              Icons.sensors_outlined,
              'Active Sensors',
              '${location.sensors} nodes',
            ),

            if (_liveTelemetry != null) ...[
              const SizedBox(height: 12),

              const Text(
                'LIVE TELEMETRY',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 10),

              _detailRow(
                Icons.water_drop_outlined,
                'Rainfall',
                '${_liveTelemetry!.rainfallMm.toStringAsFixed(1)} mm',
              ),

              _detailRow(
                Icons.opacity_outlined,
                'Soil Moisture',
                '${_liveTelemetry!.soilMoisturePercent.toStringAsFixed(1)}%',
              ),

              _detailRow(
                Icons.show_chart,
                'Slope',
                '${_liveTelemetry!.slopeAngle.toStringAsFixed(1)}°',
              ),
            ],

            const SizedBox(height: 16),

            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.redAccent.withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Evacuation team dispatch request created.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.local_shipping_outlined,
                ),
                label: const Text(
                  'DISPATCH EVACUATION TEAM',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (_liveTelemetry != null)
              const Center(
                child: Text(
                  '✓ Live data received from Spring Boot API',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskScoreCard(
    int score,
    String level,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RISK SCORE',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                level,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.cyanAccent,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLocation {
  final String name;
  final int score;
  final String trigger;
  final String soilType;
  final String population;
  final int sensors;

  const _MapLocation({
    required this.name,
    required this.score,
    required this.trigger,
    required this.soilType,
    required this.population,
    required this.sensors,
  });
}

class EnhancedGisMapPainter extends CustomPainter {
  final bool showRainfall;
  final bool showSensors;

  EnhancedGisMapPainter({
    required this.showRainfall,
    required this.showSensors,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFF091827);

    canvas.drawRect(
      Offset.zero & size,
      backgroundPaint,
    );

    _drawGrid(canvas, size);

    _drawTerrain(canvas, size);

    _drawRoads(canvas, size);

    _drawRiver(canvas, size);

    if (showRainfall) {
      _drawRainfall(canvas, size);
    }

    if (showSensors) {
      _drawSensors(canvas, size);
    }

    _drawMapBorder(canvas, size);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;

    const spacing = 45.0;

    for (
      double x = 0;
      x <= size.width;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (
      double y = 0;
      y <= size.height;
      y += spacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawTerrain(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.greenAccent.withValues(alpha: 0.10);

    for (int i = 0; i < 9; i++) {
      final path = Path();

      final y = size.height *
          (0.10 + i * 0.095);

      path.moveTo(0, y);

      for (
        double x = 0;
        x <= size.width;
        x += 30
      ) {
        final wave =
            10 *
            (i.isEven ? 1 : -1) *
            math.sin(
              (x / size.width) * 3.14159,
            );

        path.lineTo(
          x,
          y + wave,
        );
      }

      canvas.drawPath(
        path,
        paint,
      );
    }
  }

  void _drawRoads(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final road1 = Path()
      ..moveTo(
        0,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.42,
        size.width * 0.55,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.70,
        size.width,
        size.height * 0.30,
      );

    canvas.drawPath(
      road1,
      paint,
    );

    final road2 = Path()
      ..moveTo(
        size.width * 0.10,
        0,
      )
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.25,
        size.width * 0.45,
        size.height,
      );

    canvas.drawPath(
      road2,
      paint,
    );
  }

  void _drawRiver(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.16)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    final river = Path()
      ..moveTo(
        size.width * 0.72,
        0,
      )
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.22,
        size.width * 0.70,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.70,
        size.width * 0.60,
        size.height,
      );

    canvas.drawPath(
      river,
      paint,
    );
  }

  void _drawRainfall(
    Canvas canvas,
    Size size,
  ) {
    final circles = [
      Offset(
        size.width * 0.25,
        size.height * 0.25,
      ),
      Offset(
        size.width * 0.50,
        size.height * 0.32,
      ),
      Offset(
        size.width * 0.70,
        size.height * 0.55,
      ),
    ];

    final radii = [
      size.width * 0.15,
      size.width * 0.20,
      size.width * 0.12,
    ];

    for (int i = 0; i < circles.length; i++) {
      final paint = Paint()
        ..color = Colors.blueAccent.withValues(
          alpha: 0.10,
        );

      canvas.drawCircle(
        circles[i],
        radii[i],
        paint,
      );
    }
  }

  void _drawSensors(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(
        alpha: 0.55,
      )
      ..style = PaintingStyle.fill;

    final positions = [
      const Offset(0.15, 0.25),
      const Offset(0.30, 0.40),
      const Offset(0.45, 0.30),
      const Offset(0.58, 0.65),
      const Offset(0.75, 0.45),
      const Offset(0.85, 0.70),
    ];

    for (final position in positions) {
      canvas.drawCircle(
        Offset(
          size.width * position.dx,
          size.height * position.dy,
        ),
        4,
        paint,
      );
    }
  }

  void _drawMapBorder(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(
        alpha: 0.12,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant EnhancedGisMapPainter oldDelegate,
  ) {
    return oldDelegate.showRainfall != showRainfall ||
        oldDelegate.showSensors != showSensors;
  }
}