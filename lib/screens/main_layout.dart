import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'risk_map_screen.dart';
import 'risk_prediction_screen.dart';
import 'alerts_screen.dart';
import 'emergency_report_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RiskMapScreen(),
    RiskPredictionScreen(),
    AlertsScreen(),
    EmergencyReportScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const [
    'Telemetry Dashboard',
    'GIS Risk Map Visualizer',
    'Risk Prediction Simulation',
    'Early Warning Alerts',
    'Emergency Incident Report',
    'Command Profile & Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            elevation: 2,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: const Icon(Icons.landslide, color: Color(0xFFEF4444), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Landslide Risk Monitoring System',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _titles[_selectedIndex],
                      style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Connection Status Badge
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Row(
                  children: const [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text(
                      'GRID ONLINE',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  backgroundColor: const Color(0xFF1E293B),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  extended: constraints.maxWidth > 1100,
                  minExtendedWidth: 200,
                  selectedIconTheme: const IconThemeData(color: Color(0xFF38BDF8)),
                  unselectedIconTheme: const IconThemeData(color: Colors.white54),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map),
                      label: Text('Risk Map'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.psychology_outlined),
                      selectedIcon: Icon(Icons.psychology),
                      label: Text('Risk Prediction'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_active_outlined),
                      selectedIcon: Icon(Icons.notifications_active),
                      label: Text('Alerts'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.report_problem_outlined),
                      selectedIcon: Icon(Icons.report_problem),
                      label: Text('Emergency Report'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outlined),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _screens[_selectedIndex],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  backgroundColor: const Color(0xFF1E293B),
                  indicatorColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.dashboard, color: Color(0xFF38BDF8)),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.map_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.map, color: Color(0xFF38BDF8)),
                      label: 'Risk Map',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.psychology_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.psychology, color: Color(0xFF38BDF8)),
                      label: 'Predict',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_active_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.notifications_active, color: Color(0xFF38BDF8)),
                      label: 'Alerts',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.report_problem_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.report_problem, color: Color(0xFF38BDF8)),
                      label: 'Report',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.person, color: Color(0xFF38BDF8)),
                      label: 'Profile',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
