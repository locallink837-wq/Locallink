import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/listing.dart';

/// Centralized utility for handling external phone calls and map directions.
class ExternalActions {
  ExternalActions._();

  /// Launch phone call dialer with sanitized phone number.
  static Future<void> callPhone(
    BuildContext context, {
    required String phone,
    String? name,
  }) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No phone number available${name != null ? ' for $name' : ''}.',
          ),
        ),
      );
      return;
    }

    final uri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open phone dialer for $phone')),
        );
      }
    }
  }

  /// Launch Google Maps navigation or search for directions.
  static Future<void> openDirections(
    BuildContext context,
    Listing listing,
  ) async {
    Uri url;
    if (listing.latitude != 0.0 && listing.longitude != 0.0) {
      url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}&travelmode=driving',
      );
    } else if (listing.address.trim().isNotEmpty) {
      final query = Uri.encodeComponent(
        listing.name.isNotEmpty
            ? '${listing.name}, ${listing.address}'
            : listing.address,
      );
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No location or address available for directions.'),
        ),
      );
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map directions: $e')),
        );
      }
    }
  }
}
