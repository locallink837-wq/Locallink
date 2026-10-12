import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import 'request_form_view.dart';

/// Screen 3.10: No Provider Found State.
/// Displayed when providers in initial radius are unavailable or requests expire.
class NoProviderFoundView extends StatelessWidget {
  const NoProviderFoundView({super.key});

  static const route = '/requests/no-provider-found';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: UiColors.teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    size: 44,
                    color: UiColors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                uiText('No provider accepted yet', size: 22, weight: FontWeight.w800, align: TextAlign.center),
                const SizedBox(height: 10),
                uiText(
                  'Nearby professionals might be busy on another job right now. You can widen the search distance or contact verified listings directly.',
                  size: 13.5,
                  color: UiColors.muted,
                  align: TextAlign.center,
                  height: 1.4,
                ),
                const Spacer(),

                UiMainButton(
                  label: 'Widen search to 6 km',
                  customAccent: UiColors.teal,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, RequestFormView.route);
                  },
                ),
                const SizedBox(height: 12),
                UiGhostButton(
                  label: 'Browse listings instead',
                  customAccent: UiColors.teal,
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
