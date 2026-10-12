import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Primary solid gradient button (`.bt` from HTML spec).
/// Styled with a smooth top-left to bottom-right gradient, subtle drop shadow,
/// 12px border radius, and minimum 48px touch target.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.teal,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      height: AppDecorations.minTouchTarget,
      width: double.infinity,
      child: DecoratedBox(
        decoration: isEnabled
            ? AppDecorations.primaryGradient(startColor: color)
            : BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
              ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: AppDecorations.fontFamily,
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.01,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline / Ghost button (`.bg` from HTML spec).
/// White background with colored border and colored text.
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Widget? icon;

  const AppOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.teal,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDecorations.minTouchTarget,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: Color.lerp(color, Colors.white, 0.4) ?? color,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppDecorations.fontFamily,
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Urgent SOS Emergency button (`.wn` from HTML spec).
/// Deep red gradient with alert glow and lightning icon.
class AppSosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppSosButton({
    super.key,
    this.label = 'SOS Emergency',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDecorations.minTouchTarget,
      width: double.infinity,
      child: DecoratedBox(
        decoration: AppDecorations.sosGradient(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(13),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppDecorations.fontFamily,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
