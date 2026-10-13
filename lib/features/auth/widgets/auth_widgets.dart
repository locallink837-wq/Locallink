import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';

/// Centered icon + title + subtitle used at the top of auth screens.
class AuthHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const AuthHero({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34, color: accent),
        ),
        const SizedBox(height: 16),
        uiText(title, size: 22, weight: FontWeight.w800, align: TextAlign.center),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          uiText(
            subtitle!,
            size: 13.5,
            weight: FontWeight.w500,
            color: UiColors.muted,
            align: TextAlign.center,
            height: 1.4,
          ),
        ],
      ],
    );
  }
}

/// Red inline error box. Renders nothing when [message] is empty.
class AuthErrorBanner extends StatelessWidget {
  final String? message;
  const AuthErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: UiColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UiColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: UiColors.red),
          const SizedBox(width: 8),
          Expanded(
            child: uiText(message!, size: 12.5, weight: FontWeight.w600, color: UiColors.red),
          ),
        ],
      ),
    );
  }
}