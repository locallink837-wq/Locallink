import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Badge chip indicating business operating status ('24x7', 'Open now', or 'Closed').
class OpenNowBadge extends StatelessWidget {
  final bool open24x7;
  final bool openNow;
  final bool showClosed;

  const OpenNowBadge({
    super.key,
    this.open24x7 = false,
    this.openNow = false,
    this.showClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (open24x7) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          '24x7',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          ),
        ),
      );
    }

    if (openNow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Open now',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
      );
    }

    if (showClosed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Closed',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.muteLight,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
