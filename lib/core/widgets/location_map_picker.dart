import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import 'ui_kit.dart';

/// Interactive Map Location Picker using FlutterMap.
/// Allows tapping on the map to place/move the pin,
/// centers on current GPS, and reverse-geocodes address.
class LocationMapPicker extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double height;
  final Color accentColor;
  final ValueChanged<({double latitude, double longitude, String address})> onLocationChanged;

  const LocationMapPicker({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.height = 240,
    this.accentColor = UiColors.amber,
    required this.onLocationChanged,
  });

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  late final MapController _mapController;
  late double _latitude;
  late double _longitude;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _updateLocation(double lat, double lng) async {
    setState(() {
      _latitude = lat;
      _longitude = lng;
    });

    String address = '';
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.name, p.subLocality, p.locality, p.postalCode]
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s != p.postalCode)
            .toList();
        if (parts.isNotEmpty) {
          address = parts.join(', ');
        }
      }
    } catch (_) {}

    if (address.isEmpty) {
      address = 'Pinned location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    }

    widget.onLocationChanged((latitude: lat, longitude: lng, address: address));
  }

  Future<void> _locateMe() async {
    setState(() => _isLocating = true);
    try {
      const service = LocationService();
      final pos = await service.getCurrentPosition();
      _mapController.move(LatLng(pos.latitude, pos.longitude), 16);
      await _updateLocation(pos.latitude, pos.longitude);
    } catch (_) {} finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_latitude, _longitude),
              initialZoom: 15,
              minZoom: 4,
              maxZoom: 19,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, point) {
                _updateLocation(point.latitude, point.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                subdomains: const ['0', '1', '2', '3'],
                userAgentPackageName: 'com.localink.app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_latitude, _longitude),
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top instructions chip
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded, size: 14, color: widget.accentColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Tap anywhere on map to move pin',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating GPS button
          Positioned(
            bottom: 12,
            right: 12,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _locateMe,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLocating)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(Icons.my_location_rounded, size: 16, color: widget.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Locate me',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
