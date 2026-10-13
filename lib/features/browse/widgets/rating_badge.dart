import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// Compact star rating badge with review count
class RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool showCount;

  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.star.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.inkLight,
            ),
          ),
          if (showCount && reviewCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.muteLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
