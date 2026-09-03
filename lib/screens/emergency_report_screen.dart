import 'package:flutter/material.dart';
import '../models/landslide_data.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../services/sms_service.dart';

class EmergencyReportScreen extends StatefulWidget {
  const EmergencyReportScreen({super.key});

  @override
  State<EmergencyReportScreen> createState() =>
      _EmergencyReportScreenState();
}

class _EmergencyReportScreenState extends State<EmergencyReportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reporterNameController = TextEditingController();

  String _selectedSeverity = 'Critical / High';
  bool _attachedPhoto = false;
  bool _isSubmitting = false;

  List<EmergencyReport> _submittedReports =
      List.from(DummyData.sampleReports);

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEmergencies();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _reporterNameController.dispose();
    super.dispose();
  }

  // ---------------- FETCH EMERGENCY REPORTS ----------------

  Future<void> _fetchEmergencies() async {
    try {
      final reports = await ApiService.getEmergencies();

      if (mounted) {
        setState(() {
          _submittedReports = reports;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  // ---------------- SUBMIT EMERGENCY REPORT ----------------

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final reporterName =
        _reporterNameController.text.trim().isEmpty
            ? 'Anonymous Citizen'
            : _reporterNameController.text.trim();

    final reportId =
        'REP-${DateTime.now().millisecondsSinceEpoch}';

    const timestamp = 'Just now';

    try {
      // Send report to Spring Boot backend
      final savedReport =
          await ApiService.createEmergencyReport(
        id: reportId,
        location: _locationController.text.trim(),
        severity: _selectedSeverity,
        description: _descriptionController.text.trim(),
        reporterName: reporterName,
        timestamp: timestamp,
        status: 'Pending Verification',
      );

      if (!mounted) return;

      // Add successfully saved report to the screen
      setState(() {
        _submittedReports.insert(0, savedReport);
      });

      // Clear form
      _locationController.clear();
      _descriptionController.clear();
      _reporterNameController.clear();

      setState(() {
        _attachedPhoto = false;
        _isSubmitting = false;
      });

      // Success dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Report Submitted',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Text(
            'Your emergency landslide incident report '
            '($reportId) has been registered and transmitted '
            'to the Disaster Control Room.',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // API / network failed — save the report offline so it is not lost.
      final offlineReport = EmergencyReport(
        id: reportId,
        location: _locationController.text.trim(),
        severity: _selectedSeverity,
        description: _descriptionController.text.trim(),
        reporterName: reporterName,
        timestamp: timestamp,
        status: 'Pending Verification',
      );

      await OfflineStorageService.saveReport(offlineReport);

      if (!mounted) return;

      // Add the offline report to the local list so the user sees it.
      setState(() {
        _submittedReports.insert(0, offlineReport);
        _attachedPhoto = false;
        _isSubmitting = false;
      });

      // Clear form
      _locationController.clear();
      _descriptionController.clear();
      _reporterNameController.clear();

      // For Critical / High severity, offer the SMS fallback option.
      final bool offerSms = SmsService.isCriticalOrHigh(offlineReport.severity);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: offerSms ? 10 : 5),
          backgroundColor: const Color(0xFFF97316),
          content: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  offerSms
                      ? 'No internet. Report saved offline. '
                        'Send via SMS for immediate response?'
                      : 'No internet connection. Report saved offline '
                        'and will sync automatically when reconnected.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          action: offerSms
              ? SnackBarAction(
                  label: 'SEND SMS',
                  textColor: Colors.white,
                  onPressed: () => _sendSmsFallback(offlineReport),
                )
              : null,
        ),
      );
    }
  }

  // ---------------- SMS FALLBACK ----------------

  Future<void> _sendSmsFallback(EmergencyReport report) async {
    final result = await SmsService.sendEmergencySms(report);

    if (!mounted) return;

    switch (result) {
      case SmsResult.launched:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF10B981),
            content: Text(
              'SMS app opened. Please tap Send to dispatch the alert.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      case SmsResult.webUnsupported:
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.smartphone, color: Color(0xFF38BDF8), size: 24),
                SizedBox(width: 10),
                Text(
                  'SMS Not Available',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: const Text(
              'SMS fallback requires an Android device.\n\n'
              'You are currently on Chrome/Web where SMS hardware '
              'is unavailable.\n\n'
              'Your report has been saved offline and will sync '
              'automatically when the backend is reachable.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      case SmsResult.launchFailed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFEF4444),
            content: Text(
              'Could not open SMS app. '
              'Report is saved offline and will sync automatically.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
    }
  }

  // ---------------- BUILD UI ----------------

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: LinearProgressIndicator(
                color: Color(0xFF38BDF8),
                backgroundColor: Colors.white10,
              ),
            ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Backend Notice: $_errorMessage '
                '(Showing cached incidents log)',
                style: const TextStyle(
                  color: Color(0xFFF97316),
                  fontSize: 11,
                ),
              ),
            ),

          // ---------------- HEADER ----------------

          const Text(
            'Report Emergency Landslide Incident',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Direct line to Emergency Response & SDRF '
            'Search & Rescue Command',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          // ---------------- MAIN CONTENT ----------------

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              return Flex(
                direction:
                    isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: isWide
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.stretch,
                children: [
                  // ---------------- FORM ----------------

                  Expanded(
                    flex: isWide ? 6 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white12,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.report_problem,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Incident Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(
                              color: Colors.white12,
                              height: 28,
                            ),

                            // ---------------- LOCATION ----------------

                            TextFormField(
                              controller: _locationController,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Incident Location / Landmark *',
                                hintText:
                                    'e.g. NH-58 Km 42 near Rishikesh',
                                prefixIcon: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF38BDF8),
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFF0F172A),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              validator: (val) {
                                if (val == null ||
                                    val.trim().isEmpty) {
                                  return 'Please enter incident location';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // ---------------- SEVERITY ----------------

                            DropdownButtonFormField<String>(
                              initialValue: _selectedSeverity,
                              dropdownColor:
                                  const Color(0xFF0F172A),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Observed Severity Level *',
                                prefixIcon: const Icon(
                                  Icons.speed,
                                  color: Color(0xFFF97316),
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFF0F172A),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              items: [
                                'Extreme / Total Blockage',
                                'Critical / High',
                                'Moderate',
                                'Minor Slope Slip',
                              ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedSeverity =
                                              val;
                                        });
                                      }
                                    },
                            ),

                            const SizedBox(height: 16),

                            // ---------------- REPORTER ----------------

                            TextFormField(
                              controller:
                                  _reporterNameController,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Reporter Name / SDRF ID (Optional)',
                                hintText:
                                    'Officer / Resident Name',
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFF0F172A),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ---------------- DESCRIPTION ----------------

                            TextFormField(
                              controller:
                                  _descriptionController,
                              maxLines: 4,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Detailed Description of Slope Slip / Blockage *',
                                hintText:
                                    'Mention estimated debris volume, trapped vehicles, or road structural damage...',
                                alignLabelWithHint: true,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 60,
                                  ),
                                  child: Icon(
                                    Icons.notes,
                                    color: Colors.white54,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFF0F172A),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              validator: (val) {
                                if (val == null ||
                                    val.trim().isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // ---------------- PHOTO MOCK ----------------

                            InkWell(
                              onTap: _isSubmitting
                                  ? null
                                  : () {
                                      setState(() {
                                        _attachedPhoto =
                                            !_attachedPhoto;
                                      });
                                    },
                              borderRadius:
                                  BorderRadius.circular(10),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0F172A),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _attachedPhoto
                                        ? const Color(0xFF10B981)
                                        : Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _attachedPhoto
                                          ? Icons.check_circle
                                          : Icons.camera_alt,
                                      color: _attachedPhoto
                                          ? const Color(0xFF10B981)
                                          : Colors.white54,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _attachedPhoto
                                          ? 'Photo Attached (landslide_site_img_01.jpg)'
                                          : 'Attach Geo-tagged Photo Mock',
                                      style: TextStyle(
                                        color: _attachedPhoto
                                            ? const Color(
                                                0xFF10B981)
                                            : Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ---------------- SUBMIT BUTTON ----------------

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed:
                                    _isSubmitting
                                        ? null
                                        : _submitReport,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                                label: Text(
                                  _isSubmitting
                                      ? 'SUBMITTING...'
                                      : 'SUBMIT EMERGENCY REPORT',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isWide)
                    const SizedBox(width: 20)
                  else
                    const SizedBox(height: 20),

                  // ---------------- REPORTS PANEL ----------------

                  Expanded(
                    flex: isWide ? 5 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Submitted Incidents Log',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.history,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ],
                          ),

                          const Divider(
                            color: Colors.white12,
                            height: 28,
                          ),

                          ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount:
                                _submittedReports.length,
                            separatorBuilder:
                                (ctx, idx) =>
                                    const SizedBox(height: 12),
                            itemBuilder: (ctx, idx) {
                              final rep =
                                  _submittedReports[idx];

                              return Container(
                                padding:
                                    const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0F172A),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white12,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          rep.id,
                                          style:
                                              const TextStyle(
                                            color: Color(
                                              0xFF38BDF8,
                                            ),
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration:
                                              BoxDecoration(
                                            color: const Color(
                                              0xFFF97316,
                                            ).withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(6),
                                          ),
                                          child: Text(
                                            rep.status,
                                            style:
                                                const TextStyle(
                                              color: Color(
                                                0xFFF97316,
                                              ),
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      rep.location,
                                      style:
                                          const TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      rep.description,
                                      style:
                                          const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          'By ${rep.reporterName}',
                                          style:
                                              const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          rep.timestamp,
                                          style:
                                              const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
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
}