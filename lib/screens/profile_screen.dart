import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _autoRefresh = true;
  bool _soundAlarms = true;
  bool _highPrecisionSensors = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Box
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  child: const Icon(Icons.shield, color: Color(0xFF38BDF8), size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Commander Rajesh V. Verma',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: const Text(
                              'VERIFIED OFFICER',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'National Disaster Response Force (NDRF) • Sector HQ North',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Monitoring Station Node: Shimla Command Hub S-04',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                children: [
                  // Emergency Hotline Contacts
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
                              Icon(Icons.phone_in_talk, color: Color(0xFFEF4444), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Emergency Hotline Contacts',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 28),

                          _buildContactTile(
                            name: 'National Emergency Operation Center (NEOC)',
                            number: '1078 / 011-26701728',
                            tag: '24x7 TOLL FREE',
                          ),
                          const SizedBox(height: 12),
                          _buildContactTile(
                            name: 'State Disaster Management Authority (SDMA Shimla)',
                            number: '+91 177 2812344',
                            tag: 'REGIONAL HQ',
                          ),
                          const SizedBox(height: 12),
                          _buildContactTile(
                            name: 'Geological Survey of India (Landslide Division)',
                            number: '+91 33 22861676',
                            tag: 'GEOTECH EXPERTS',
                          ),
                          const SizedBox(height: 12),
                          _buildContactTile(
                            name: 'Border Roads Organisation (BRO Rescue Wing)',
                            number: '1800-180-4567',
                            tag: 'ROAD CLEARANCE',
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),

                  // System Preferences Panel
                  Expanded(
                    flex: isWide ? 5 : 0,
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
                              Icon(Icons.settings, color: Color(0xFF38BDF8), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'System Preferences & Telemetry Settings',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 28),

                          SwitchListTile(
                            activeThumbColor: const Color(0xFF38BDF8),
                            title: const Text('Auto Telemetry Polling (5s)', style: TextStyle(color: Colors.white, fontSize: 14)),
                            subtitle: const Text('Fetch live sensor updates automatically', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            value: _autoRefresh,
                            onChanged: (val) => setState(() => _autoRefresh = val),
                          ),
                          const Divider(color: Colors.white12),
                          SwitchListTile(
                            activeThumbColor: const Color(0xFFEF4444),
                            title: const Text('Audible Critical Siren Alarms', style: TextStyle(color: Colors.white, fontSize: 14)),
                            subtitle: const Text('Play sound alert when risk index > 75%', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            value: _soundAlarms,
                            onChanged: (val) => setState(() => _soundAlarms = val),
                          ),
                          const Divider(color: Colors.white12),
                          SwitchListTile(
                            activeThumbColor: const Color(0xFF10B981),
                            title: const Text('High Precision Sensor Interpolation', style: TextStyle(color: Colors.white, fontSize: 14)),
                            subtitle: const Text('Use AI smoothing for raw piezometer data', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            value: _highPrecisionSensors,
                            onChanged: (val) => setState(() => _highPrecisionSensors = val),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('SIH HACKATHON BUILD VERSION', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Landslide Risk Monitoring System v1.0.0-SIH', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('Built with Flutter & Dart • Smart India Hackathon Edition', style: TextStyle(color: Colors.white54, fontSize: 11)),
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

  Widget _buildContactTile({required String name, required String number, required String tag}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 2),
                Text(number, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tag, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
