import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';

/// Screen: Service Area (Tagged NEW in UI/UX E_F).
/// Allows provider to update their service radius (3 km, 5 km, 10 km) and location address.
class ServiceAreaView extends StatefulWidget {
  const ServiceAreaView({super.key});

  static const route = '/provider/service-area';

  @override
  State<ServiceAreaView> createState() => _ServiceAreaViewState();
}

class _ServiceAreaViewState extends State<ServiceAreaView> {
  final _repo = ProviderRepository();
  final _addressController = TextEditingController();

  double _radiusKm = 5.0;
  double _latitude = 18.5204;
  double _longitude = 73.8567;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  final List<double> _presetRadii = [3.0, 5.0, 10.0, 15.0];

  @override
  void initState() {
    super.initState();
    _loadCurrentArea();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentArea() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final provData = await _repo
          .streamProvider(uid)
          .first
          .timeout(const Duration(seconds: 2));
      if (provData != null) {
        _radiusKm = (provData['radiusKm'] as num?)?.toDouble() ?? 5.0;
        _addressController.text =
            provData['address']?.toString() ?? 'Kothrud, Pune';

        final loc = provData['serviceLocation'];
        if (loc != null) {
          try {
            _latitude = (loc.latitude as num).toDouble();
            _longitude = (loc.longitude as num).toDouble();
          } catch (_) {}
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _fetchCurrentGps() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

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
          ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
          _addressController.text = area.isNotEmpty
              ? area
              : '${p.name}, ${p.administrativeArea}';
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {});
    } catch (_) {}
  }

  Future<void> _saveArea() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(
        () => _errorMessage = 'Please specify your base service area / address',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _repo.updateServiceArea(
        uid: uid,
        radiusKm: _radiusKm,
        lat: _latitude,
        lng: _longitude,
        address: address,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service area updated successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to update service area: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Service area',
        bottomButton: UiMainButton(
          label: 'Save area',
          isLoading: _isSaving,
          onPressed: _saveArea,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      UiWarningBanner(text: _errorMessage!),
                      const SizedBox(height: 14),
                    ],

                    // Map pin area
                    UiMapPlaceholder(
                      label:
                          '${_radiusKm.toStringAsFixed(0)} km coverage radius',
                      height: 160,
                      onTap: _fetchCurrentGps,
                    ),
                    const SizedBox(height: 16),

                    // Quick radius preset chips
                    uiText(
                      'Operating radius',
                      size: 13.5,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final r in _presetRadii) ...[
                          Expanded(
                            child: UiChip(
                              label: '${r.toStringAsFixed(0)} km',
                              isSelected: (_radiusKm - r).abs() < 0.1,
                              onTap: () => setState(() => _radiusKm = r),
                            ),
                          ),
                          if (r != _presetRadii.last) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Manual area address field (embedded as per spec)
                    uiText(
                      'Base work address',
                      size: 13.5,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(height: 6),
                    UiTextInput(
                      label: '',
                      hintText: 'Enter area name (e.g. Kothrud, Pune)',
                      controller: _addressController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    UiGhostButton(
                      label: 'Use current GPS location',
                      icon: Icons.my_location_rounded,
                      onPressed: _fetchCurrentGps,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
