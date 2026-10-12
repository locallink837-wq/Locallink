import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'provider_dashboard_view.dart';

/// Screen 6.10: Active Job and Live Location Tracking.
/// Updates request status ('on_the_way', 'in_progress', 'done') and writes live GPS coordinates
/// to requests/{id}/live/provider periodically every 15-20 seconds.
class ActiveJobView extends StatefulWidget {
  const ActiveJobView({super.key});

  static const route = '/provider/active-job';

  @override
  State<ActiveJobView> createState() => _ActiveJobViewState();
}

class _ActiveJobViewState extends State<ActiveJobView> {
  final _repo = ProviderRepository();
  Timer? _locationTimer;

  // Status progression: 1 = 'on_the_way', 2 = 'in_progress' (Arrived / Start job), 3 = 'done'
  int _currentStep = 1;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _startLiveLocationSharing();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  // Periodic GPS update to requests/{id}/live/provider every 18 seconds
  void _startLiveLocationSharing() {
    _locationTimer = Timer.periodic(const Duration(seconds: 18), (timer) async {
      final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
      final requestId = (args['requestId'] ?? '').toString();
      if (requestId.isEmpty || _currentStep == 3) {
        timer.cancel();
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );

        await _repo.updateLiveLocation(
          requestId: requestId,
          lat: position.latitude,
          lng: position.longitude,
        );
      } catch (_) {
        // Location update error ignored silently in background loop
      }
    });
  }

  Future<void> _handleNextStatusStep(String requestId) async {
    setState(() => _isUpdating = true);

    try {
      if (_currentStep == 1) {
        // Arrived -> set status 'in_progress'
        await _repo.updateRequestStatus(requestId, 'in_progress');
        if (!mounted) return;
        setState(() {
          _currentStep = 2;
          _isUpdating = false;
        });
      } else if (_currentStep == 2) {
        // Done -> set status 'done' and cancel timer
        _locationTimer?.cancel();
        await _repo.updateRequestStatus(requestId, 'done');
        if (!mounted) return;
        setState(() {
          _currentStep = 3;
          _isUpdating = false;
        });

        // Prompt celebration & return to provider dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job completed successfully! Customer can now rate the service.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, ProviderDashboardView.route, (r) => false);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final requestId = (args['requestId'] ?? '').toString();
    final contact = args['contact'] as Map<String, dynamic>?;

    final customerName = contact?['name']?.toString() ?? 'Customer';
    final customerAddress = contact?['address']?.toString() ?? 'Address location';

    final buttonLabel = _currentStep == 1 ? 'Arrived (Start job)' : 'Mark done';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Active job',
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: buttonLabel,
              isLoading: _isUpdating,
              onPressed: () => _handleNextStatusStep(requestId),
            ),
            const SizedBox(height: 10),
            UiGhostButton(
              label: 'Chat with customer',
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening live chat...')),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Status: On the way > Arrived > Done
              UiStepper(
                totalSteps: 3,
                currentStep: _currentStep,
                stepLabels: const ['On the way', 'In progress', 'Done'],
              ),
              const SizedBox(height: 18),

              // Live Location Sharing Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UiColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: uiText(
                        'Live GPS location sharing is active with customer.',
                        size: 12,
                        weight: FontWeight.w700,
                        color: UiColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive / Live Map Placeholder
              UiMapPlaceholder(
                label: 'Navigating to $customerName',
                height: 170,
              ),
              const SizedBox(height: 18),

              // Job Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_pin_circle_rounded, color: UiColors.indigo, size: 24),
                        const SizedBox(width: 8),
                        uiText(customerName, size: 15, weight: FontWeight.w800),
                      ],
                    ),
                    const SizedBox(height: 8),
                    uiText(customerAddress, size: 13, color: UiColors.muted, height: 1.4),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
