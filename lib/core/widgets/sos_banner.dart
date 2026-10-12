import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// SOS Emergency Quick Banner (`.wn` from HTML spec).
/// Vibrant emergency banner with lightning icon and urgent drop shadow.
class SosBanner extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;

  const SosBanner({
    super.key,
    this.title = 'SOS Emergency',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: AppDecorations.sosGradient(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppDecorations.fontFamily,
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
