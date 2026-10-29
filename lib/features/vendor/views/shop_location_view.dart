import 'package:flutter/material.dart';

import '../../../core/widgets/location_map_picker.dart';
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
        () => _errorMessage =
            'Please provide an address or pin your shop location',
      );
      return;
    }

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
      ShopHoursPhotoView.route,
      arguments: combinedData,
    );
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

              LocationMapPicker(
                initialLatitude: _latitude,
                initialLongitude: _longitude,
                accentColor: UiColors.amber,
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

              uiText(
                'Or enter address manually',
                size: 13.5,
                weight: FontWeight.w600,
                color: UiColors.muted,
              ),
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
