import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/widgets/ui_kit.dart';
import 'shop_hours_photo_view.dart';

/// Screen 7.2: Shop Location (2 of 3).
/// Pins shop location using GPS with manual address entry fallback.
class ShopLocationView extends StatefulWidget {
  const ShopLocationView({super.key});

  static const route = '/vendor/shop-location';

  @override
  State<ShopLocationView> createState() => _ShopLocationViewState();
}

class _ShopLocationViewState extends State<ShopLocationView> {
  final _addressController = TextEditingController();
  double _latitude = 18.5204;
  double _longitude = 73.8567;
  bool _isLocating = false;
  bool _hasLocation = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLocating = false;
          _errorMessage = 'Location services disabled. Please enable GPS.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _isLocating = false;
            _errorMessage = 'Location permission denied. Enter address manually below.';
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      _hasLocation = true;

      try {
        final placemarks = await Geocoding().placemarkFromCoordinates(_latitude, _longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final area = [p.subLocality, p.locality, p.postalCode]
              .where((e) => e != null && e.toString().isNotEmpty)
              .join(', ');
          _addressController.text = area.isNotEmpty ? area : '${p.name}, ${p.administrativeArea}';
        }
      } catch (_) {
        _addressController.text = 'Shop pinned (${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)})';
      }

      if (!mounted) return;
      setState(() => _isLocating = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _errorMessage = 'GPS unavailable. Please type address manually.';
      });
    }
  }

  void _onNext() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() => _errorMessage = 'Please provide an address or pin your shop location');
      return;
    }

    final prevArgs = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final combinedData = Map<String, dynamic>.from(prevArgs)
      ..addAll({
        'latitude': _latitude,
        'longitude': _longitude,
        'address': address,
      });

    Navigator.pushNamed(context, ShopHoursPhotoView.route, arguments: combinedData);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'Shop location (2 of 3)',
        bottomButton: UiMainButton(
          label: 'Next',
          customAccent: UiColors.amber,
          onPressed: _onNext,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UiStepper(
                totalSteps: 3,
                currentStep: 2,
                customAccent: UiColors.amber,
                stepLabels: ['Shop info', 'Location', 'Hours & photo'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              UiMapPlaceholder(
                label: _hasLocation ? 'Shop pinned' : 'Tap to pin shop GPS',
                height: 150,
                onTap: _fetchCurrentLocation,
              ),
              const SizedBox(height: 14),

              UiMainButton(
                label: _hasLocation ? 'Update current location' : 'Allow location',
                icon: Icons.my_location_rounded,
                customAccent: UiColors.amber,
                isLoading: _isLocating,
                onPressed: _fetchCurrentLocation,
              ),
              const SizedBox(height: 16),

              uiText('Or enter address manually', size: 13.5, weight: FontWeight.w600, color: UiColors.muted),
              const SizedBox(height: 8),

              UiTextInput(
                label: 'Shop Address / Market name',
                hintText: 'e.g. Shop 12, Main Market, Kothrud',
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
