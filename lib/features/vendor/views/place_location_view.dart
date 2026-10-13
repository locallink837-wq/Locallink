import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';
import 'verification_status_view.dart';

/// Screen 7.6: Place Location (2 of 2).
/// Pins location of hospital, college, PG, or bank and commits registration atomically.
class PlaceLocationView extends StatefulWidget {
  const PlaceLocationView({super.key});

  static const route = '/vendor/place-location';

  @override
  State<PlaceLocationView> createState() => _PlaceLocationViewState();
}

class _PlaceLocationViewState extends State<PlaceLocationView> {
  final _addressController = TextEditingController();
  final _repo = VendorRepository();

  double _latitude = 18.5204;
  double _longitude = 73.8567;
  bool _isLocating = false;
  bool _hasLocation = false;
  bool _isSubmitting = false;
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
            'Pinned (${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)})';
      }

      if (!mounted) return;
      setState(() => _isLocating = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _errorMessage = 'GPS unavailable. Please enter address manually below.';
      });
    }
  }

  Future<void> _onSubmit() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(
        () => _errorMessage =
            'Please provide the physical address of this place.',
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      setState(() => _errorMessage = 'Please sign in to register a place.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final args =
          (ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?) ??
          {};
      final listingId =
          args['listingId'] as String? ?? _repo.generateListingId();

      await _repo.submitPlaceRegistration(
        listingId: listingId,
        uid: uid,
        name: (args['name'] ?? 'Place').toString(),
        category: (args['category'] ?? 'Hospital').toString(),
        categoryDetails: (args['categoryDetails'] ?? '').toString(),
        phone: (args['phone'] ?? '').toString(),
        address: address,
        latitude: _latitude,
        longitude: _longitude,
        open24x7: true,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        VerificationStatusView.route,
        (route) => false,
        arguments: {'listingId': listingId},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Error submitting place: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'Place location (2 of 2)',
        bottomButton: UiMainButton(
          label: 'Submit place for review',
          customAccent: UiColors.amber,
          isLoading: _isSubmitting,
          onPressed: _onSubmit,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UiStepper(
                totalSteps: 2,
                currentStep: 2,
                customAccent: UiColors.amber,
                stepLabels: ['Place details', 'Location'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              UiMapPlaceholder(
                label: _hasLocation
                    ? 'Place pinned'
                    : 'Tap to pin place on map',
                height: 150,
                onTap: _fetchCurrentLocation,
              ),
              const SizedBox(height: 14),

              UiMainButton(
                label: _hasLocation
                    ? 'Update current GPS location'
                    : 'Allow location',
                icon: Icons.my_location_rounded,
                customAccent: UiColors.amber,
                isLoading: _isLocating,
                onPressed: _fetchCurrentLocation,
              ),
              const SizedBox(height: 16),

              uiText('Physical Address', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),

              UiTextInput(
                label: '',
                hintText: 'e.g. Near City Bus Stand, College Road, Pune',
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
