import 'package:flutter/material.dart';
import '../models/landslide_data.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'ALL';
  List<AlertItem> _alerts = List.from(DummyData.sampleAlerts);
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    try {
      final fetched = await ApiService.getAlerts();
      if (mounted) {
        setState(() {
          _alerts = fetched;
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

  List<AlertItem> get _filteredAlerts {
    if (_selectedFilter == 'ALL') return _alerts;
    return _alerts.where((a) => a.severity.name.toUpperCase() == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: LinearProgressIndicator(color: Color(0xFF38BDF8), backgroundColor: Colors.white10),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Backend Notice: $_errorMessage (Showing cached alerts)',
                style: const TextStyle(color: Color(0xFFF97316), fontSize: 11),
              ),
            ),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Early Warning Alert Center',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Active geological hazards & sensor threshold notifications',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('BROADCAST EMERGENCY SMS DISPATCHED TO ALL REGIONAL OPERATORS'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                icon: const Icon(Icons.cell_tower),
                label: const Text('BROADCAST SOS ALERT'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Filters row
          Wrap(
            spacing: 8,
            children: ['ALL', 'CRITICAL', 'HIGH', 'WARNING', 'INFO'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                selectedColor: const Color(0xFF38BDF8),
                backgroundColor: const Color(0xFF1E293B),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedFilter = filter);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Alerts List
          Expanded(
            child: _filteredAlerts.isEmpty
                ? const Center(
                    child: Text('No alerts matching selected filter.', style: TextStyle(color: Colors.white38)),
                  )
                : ListView.separated(
                    itemCount: _filteredAlerts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alert = _filteredAlerts[index];
                      final color = _getSeverityColor(alert.severity);

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: alert.isAcknowledged ? Colors.white12 : color.withValues(alpha: 0.5),
                          ),
                        ),
                        child: ExpansionTile(
                          iconColor: color,
                          collapsedIconColor: Colors.white54,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.warning_amber_rounded, color: color, size: 22),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    decoration: alert.isAcknowledged ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: color),
                                ),
                                child: Text(
                                  alert.severity.name.toUpperCase(),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${alert.location} • ${alert.timestamp}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(color: Colors.white12),
                                  const SizedBox(height: 8),
                                  Text(
                                    alert.description,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white70,
                                          side: const BorderSide(color: Colors.white24),
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Dispatched response team to ${alert.location}')),
                                          );
                                        },
                                        icon: const Icon(Icons.local_shipping, size: 16),
                                        label: const Text('Dispatch Team'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: alert.isAcknowledged ? Colors.grey : const Color(0xFF10B981),
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            alert.isAcknowledged = !alert.isAcknowledged;
                                          });
                                        },
                                        icon: Icon(alert.isAcknowledged ? Icons.check_circle : Icons.done, size: 16),
                                        label: Text(alert.isAcknowledged ? 'ACKNOWLEDGED' : 'ACKNOWLEDGE'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
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
