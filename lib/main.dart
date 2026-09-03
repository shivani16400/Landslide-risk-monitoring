import 'package:flutter/material.dart';
import 'screens/main_layout.dart';
import 'services/sync_service.dart';

void main() async {
  // Required before any async work or plugin calls.
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt to sync any emergency reports that were saved offline.
  // This runs in the background — errors are swallowed inside SyncService
  // so the app always starts even if the backend is unreachable.
  SyncService.syncPendingReports().ignore();

  runApp(const LandslideRiskApp());
}

class LandslideRiskApp extends StatelessWidget {
  const LandslideRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landslide Risk Monitoring System',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFFEF4444),
          surface: Color(0xFF0F172A),
          error: Color(0xFFEF4444),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainLayout(),
    );
  }
}
