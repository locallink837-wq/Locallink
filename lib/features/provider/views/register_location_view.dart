import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
  bool _isLocating = false;
  bool _hasLocation = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // Request GPS location permission and fetch current coordinate
  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _errorMessage = null;
    });

    try {
      // Check location service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLocating = false;
          _errorMessage = 'Location services are disabled on your device. Please enable GPS.';
        });
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _isLocating = false;
            _errorMessage = 'Location permission was denied. You can enter your address manually below.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLocating = false;
          _errorMessage = 'Location permission is permanently denied. Please enter your address manually.';
        });
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      _hasLocation = true;

      // Reverse geocode to get street name and area
      try {
        final placemarks = await placemarkFromCoordinates(
          _latitude,
          _longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final area = [
            p.subLocality,
            p.locality,
            p.postalCode,
          ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
          _addressController.text = area.isNotEmpty
              ? area
              : '${p.name}, ${p.administrativeArea}';
        }
      } catch (_) {
        _addressController.text =
            'Location pinned (${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)})';
      }

      if (!mounted) return;
      setState(() {
        _isLocating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _errorMessage = 'Could not fetch GPS automatically. Please enter your address manually.';
      });
    }
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

              // Map illustration placeholder with pinned status
              UiMapPlaceholder(
                label: _hasLocation
                    ? 'Pinned area'
                    : 'Tap allow to pin location',
                height: 150,
                onTap: _fetchCurrentLocation,
              ),
              const SizedBox(height: 16),

              // Button to allow and fetch location
              UiMainButton(
                label: _hasLocation
                    ? 'Update current location'
                    : 'Allow location',
                icon: Icons.my_location_rounded,
                isLoading: _isLocating,
                onPressed: _fetchCurrentLocation,
              ),
              const SizedBox(height: 14),

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
