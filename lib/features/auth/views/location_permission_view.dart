import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localink/features/auth/widgets/auth_widgets.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/auth_repository.dart';
import '../state/auth_flow.dart';

/// Location permission
/// Module 1 - Auth and onboarding  |  Owner: A
/// Customers are asked after sign-up. Saves area + lat/lng on users/{uid}.
class LocationPermissionView extends StatefulWidget {
  const LocationPermissionView({super.key});

  static const route = '/auth/location-permission';

  @override
  State<LocationPermissionView> createState() => _LocationPermissionViewState();
}

class _LocationPermissionViewState extends State<LocationPermissionView> {
  static const _repo = AuthRepository();
  bool _busy = false;

  void _finish() => AuthFlow.finishOnboarding(Navigator.of(context));

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _allow() async {
    setState(() => _busy = true);
    try {
      final loc = await _repo.detectLocation();
      if (!mounted) return;
      if (loc == null) {
        _snack('Location was not allowed. You can enter your area manually.');
        return;
      }
      final uid = _repo.currentUid;
      if (_repo.isRealUser && uid != null) {
        await _repo.saveLocation(uid: uid, area: loc.area, lat: loc.lat, lng: loc.lng);
      }
      if (mounted) _finish();
    } catch (e) {
      debugPrint('Location step failed: $e');
      if (mounted) _snack('Could not get your location. You can enter your area manually.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _manual() async {
    final area = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Theme(
        data: uiFeatureTheme(context, UiColors.teal),
        child: const _AreaSheet(),
      ),
    );
    if (area == null || area.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      final uid = _repo.currentUid;
      if (_repo.isRealUser && uid != null) {
        await _repo.saveLocation(uid: uid, area: area);
      }
    } catch (e) {
      debugPrint('Saving area failed: $e');
    }
    if (mounted) {
      setState(() => _busy = false);
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiCoverScreen(
        icon: Icons.location_on_rounded,
        title: 'Allow location to see what is nearby',
        subtitle: 'We use it only to sort results by distance and to show your position on the map.',
        primaryButtonText: _busy ? 'Please wait...' : 'Allow',
        onPrimaryPressed: _busy ? null : _allow,
        secondaryButtonText: 'Enter area manually',
        onSecondaryPressed: _busy ? null : _manual,
      ),
    );
  }
}

class _AreaSheet extends StatefulWidget {
  const _AreaSheet();

  @override
  State<_AreaSheet> createState() => _AreaSheetState();
}

class _AreaSheetState extends State<_AreaSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: UiBottomSheetFrame(
        title: 'Enter your area',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiTextInput(
              label: 'Area or locality',
              controller: _controller,
              hintText: 'e.g. Shivajinagar, Pune',
            ),
            AuthErrorBanner(_error),
            const SizedBox(height: 16),
            UiMainButton(
              label: 'Save area',
              onPressed: () {
                final v = _controller.text.trim();
                if (v.length < 2) {
                  setState(() => _error = 'Please enter your area.');
                  return;
                }
                Navigator.pop(context, v);
              },
            ),
          ],
        ),
      ),
    );
  }
}