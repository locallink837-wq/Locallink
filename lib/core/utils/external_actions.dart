import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/browse/views/map_view.dart';
import '../models/listing.dart';

/// Centralized utility for handling phone calls and in-app map directions.
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
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open phone dialer for $phone')),
          );
        }
      }
    }
  }

  /// Navigates directly to the in-app Map Explorer section centered on this listing.
  static void openDirections(
    BuildContext context,
    Listing listing,
  ) {
    Navigator.pushNamed(
      context,
      MapView.route,
      arguments: listing,
    );
  }
}

