import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../config/env.dart';
import '../models/listing.dart';

/// Geolocator-backed location service.
/// Provides permission handling, current coordinate lookup, distance calculation,
/// and list sorting by distance with verified-first priority.
class LocationService {
  const LocationService();
  static bool _permissionRequestAttempted = false;

  /// Check if location permissions are currently granted
  Future<bool> hasPermission() async {
    try {
      final status = await Geolocator.checkPermission();
      return status == LocationPermission.always ||
          status == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Request location permission from user
  Future<LocationPermission> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled on device.');
      }
      _permissionRequestAttempted = true;
      return await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Get current user device coordinates, falling back to default location on error
  Future<Position> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallbackPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!_permissionRequestAttempted) {
          _permissionRequestAttempted = true;
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return _fallbackPosition();
        }
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('Error getting current position, using fallback: $e');
      return _fallbackPosition();
    }
  }

  Position _fallbackPosition() {
    return Position(
      latitude: Env.defaultLatitude,
      longitude: Env.defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 100,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  /// Calculate distance between two coordinates in meters
  double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (_) {
      // Fallback Haversine formula
      return _haversineMeters(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    }
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Formats distance in meters into friendly strings e.g. "450 m", "1.4 km"
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Sorts listings according to UI/UX rule:
  /// Distance closest first, with verified listings prioritized.
  List<Listing> sortByDistanceAndVerified({
    required List<Listing> listings,
    required double userLat,
    required double userLng,
  }) {
    final sorted = List<Listing>.from(listings);
    sorted.sort((a, b) {
      // Verified first
      if (a.verified != b.verified) {
        return a.verified ? -1 : 1;
      }

      // Then by distance
      final distA = (a.latitude != null && a.longitude != null)
          ? calculateDistanceMeters(
              startLatitude: userLat,
              startLongitude: userLng,
              endLatitude: a.latitude!,
              endLongitude: a.longitude!,
            )
          : double.infinity;

      final distB = (b.latitude != null && b.longitude != null)
          ? calculateDistanceMeters(
              startLatitude: userLat,
              startLongitude: userLng,
              endLatitude: b.latitude!,
              endLongitude: b.longitude!,
            )
          : double.infinity;

      return distA.compareTo(distB);
    });
    return sorted;
  }
}
