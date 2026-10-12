import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/safety_profile_repository.dart';
import 'urgent_request_view.dart';

/// Screen 5.1: SOS Emergency Hub.
/// Works 100% without login. Reads emergency helplines, launches calls directly,
/// and logs SOS events without using AI.
class SosView extends StatefulWidget {
  const SosView({super.key});

  static const route = '/safety-profile/sos';

  @override
  State<SosView> createState() => _SosViewState();
}

class _SosViewState extends State<SosView> {
  final _repo = SafetyProfileRepository();
  List<Map<String, String>> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _repo.fetchEmergencyContacts();
    if (!mounted) return;
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  Future<void> _callEmergency(String number) async {
    // Log SOS event with best effort GPS
    try {
      final pos = await Geolocator.getLastKnownPosition();
      await _repo.logSosEvent(lat: pos?.latitude, lng: pos?.longitude);
    } catch (_) {}

    final clean = number.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.red),
      child: UiScaffold(
        title: 'Emergency SOS',
        bottomButton: UiGhostButton(
          label: 'Alert urgent service providers',
          icon: Icons.flash_on_rounded,
          customAccent: UiColors.red,
          onPressed: () {
            Navigator.pushNamed(context, UrgentRequestView.route);
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Large 112 Call Card
              GestureDetector(
                onTap: () => _callEmergency('112'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [UiColors.redLight, UiColors.redDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: UiColors.red.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emergency_rounded, color: Colors.white, size: 36),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          uiText('Call 112 Helpline', size: 18, weight: FontWeight.w800, color: Colors.white),
                          const SizedBox(height: 2),
                          uiText('National All-in-One Emergency', size: 12, color: Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Policy notice tag: Works without login, No AI used here
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UiColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, size: 20, color: UiColors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: uiText(
                        'Works without login. No AI is used here. Direct operator telephone connection.',
                        size: 11.5,
                        color: UiColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              uiText('Emergency services nearby', size: 14, weight: FontWeight.w800),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else
                Column(
                  children: [
                    for (final c in _contacts)
                      UiListTile(
                        title: c['label']!,
                        subtitle: 'Dial: ${c['number']}',
                        icon: Icons.phone_in_talk_rounded,
                        customAccent: UiColors.red,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: UiColors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Call ${c['number']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: UiColors.red,
                            ),
                          ),
                        ),
                        onTap: () => _callEmergency(c['number']!),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
