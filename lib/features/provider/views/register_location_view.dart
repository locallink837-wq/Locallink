import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/shells/provider_shell.dart';
import '../../../core/widgets/location_map_picker.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';

/// Screen 6.3: Provider Registration Step 3 - Location and Completion.
/// Uses geolocator to fetch GPS location, reverse geocodes to address, and submits registration.
class RegisterLocationView extends StatefulWidget {
  const RegisterLocationView({super.key});

  static const route = '/provider/register-location';

  @override
  State<RegisterLocationView> createState() => _RegisterLocationViewState();
}

class _RegisterLocationViewState extends State<RegisterLocationView> {
  final _addressController = TextEditingController();
  final _repo = ProviderRepository();
  double _latitude = 18.5204; // Default Pune fallback
  double _longitude = 73.8567;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onComplete() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(
        () => _errorMessage = 'Please provide an address or pin your location',
      );
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    final prevArgs =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'temp-provider-uid';

    try {
      await _repo.submitRegistration(
        uid: uid,
        name: (prevArgs['name'] ?? 'Provider').toString(),
        businessName: (prevArgs['businessName'] ?? '').toString(),
        phone: (prevArgs['phone'] ?? '').toString(),
        services: List<String>.from(prevArgs['services'] ?? ['Services']),
        experienceYears: (prevArgs['experienceYears'] as num?)?.toInt() ?? 1,
        radiusKm: (prevArgs['radiusKm'] as num?)?.toDouble() ?? 10.0,
        languages: List<String>.from(prevArgs['languages'] ?? ['English']),
        open24x7: (prevArgs['open24x7'] as bool?) ?? false,
        latitude: _latitude,
        longitude: _longitude,
        address: address,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        ProviderShell.route,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        ProviderShell.route,
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Register (3 of 3)',
        bottomButton: UiMainButton(
          label: _isSubmitting ? 'Registering...' : 'Complete Registration',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _onComplete,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper (3 of 3)
              const UiStepper(
                totalSteps: 3,
                currentStep: 3,
                stepLabels: ['Core', 'Details', 'Location'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              LocationMapPicker(
                initialLatitude: _latitude,
                initialLongitude: _longitude,
                accentColor: UiColors.indigo,
                height: 220,
                onLocationChanged: (data) {
                  setState(() {
                    _latitude = data.latitude;
                    _longitude = data.longitude;
                    _addressController.text = data.address;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Manual address fallback section (requirement from HTML 6.3 & note)
              uiText(
                'Or enter address manually',
                size: 13.5,
                weight: FontWeight.w600,
                color: UiColors.muted,
              ),
              const SizedBox(height: 8),

              UiTextInput(
                label: 'Work address / Area name',
                hintText: 'e.g. Kothrud, Pune - 411038',
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
