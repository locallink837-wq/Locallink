import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/widgets/location_map_picker.dart';
import '../../../core/widgets/ui_kit.dart';
import 'register_documents_view.dart';

/// Screen 6.3: Provider Registration Step 3 - Location and Service Center.
/// Uses geolocator to fetch GPS location, reverse geocodes to address, and includes manual address input.
class RegisterLocationView extends StatefulWidget {
  const RegisterLocationView({super.key});

  static const route = '/provider/register-location';

  @override
  State<RegisterLocationView> createState() => _RegisterLocationViewState();
}

class _RegisterLocationViewState extends State<RegisterLocationView> {
  final _addressController = TextEditingController();
  double _latitude = 18.5204; // Default Pune fallback
  double _longitude = 73.8567;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _onNext() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(
        () => _errorMessage = 'Please provide an address or pin your location',
      );
      return;
    }

    setState(() => _errorMessage = null);

    final prevArgs =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};
    final combinedData = Map<String, dynamic>.from(prevArgs)
      ..addAll({
        'latitude': _latitude,
        'longitude': _longitude,
        'address': address,
      });

    Navigator.pushNamed(
      context,
      RegisterDocumentsView.route,
      arguments: combinedData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Register (3 of 4)',
        bottomButton: UiMainButton(label: 'Next', onPressed: _onNext),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper (3 of 4)
              const UiStepper(
                totalSteps: 4,
                currentStep: 3,
                stepLabels: ['Core', 'Details', 'Area', 'Docs'],
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
                    _hasLocation = true;
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
