import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../models/listing.dart';
import 'open_now_badge.dart';

/// Listing card item matching the HTML design specification (`.li` element).
/// Shows category avatar, title, distance / open status, verified badge, and navigation chevron.
class ListingCard extends StatelessWidget {
  final Listing listing;
  final String? distanceLabel;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.distanceLabel,
    this.onTap,
  });

  Color _getKindColor() {
    if (listing.isService) return AppColors.teal;
    if (listing.isPlace) return AppColors.indigo;
    return AppColors.amber;
  }

  IconData _getCategoryIcon() {
    final cat = listing.category.toLowerCase();
    if (cat.contains('electric') || cat.contains('urgent')) return Icons.bolt;
    if (cat.contains('plumb') || cat.contains('repair') || cat.contains('hardware')) return Icons.build;
    if (cat.contains('clean')) return Icons.auto_awesome;
    if (cat.contains('hospital') || cat.contains('medical')) return Icons.local_hospital;
    if (cat.contains('college') || cat.contains('coaching')) return Icons.school;
    if (cat.contains('bank') || cat.contains('atm')) return Icons.account_balance;
    if (cat.contains('pg') || cat.contains('hostel')) return Icons.home;
    if (cat.contains('grocery') || cat.contains('shop')) return Icons.storefront;
    return Icons.place;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getKindColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.lineLight),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              // Category Icon Avatar
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getCategoryIcon(), size: 18, color: themeColor),
              ),
              const SizedBox(width: 10),

              // Title and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            listing.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (listing.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: AppColors.teal),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (distanceLabel != null && distanceLabel!.isNotEmpty) ...[
                          Text(
                            distanceLabel!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muteLight,
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: AppColors.lineLight)),
                        ],
                        Text(
                          listing.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muteLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badges & Chevron
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OpenNowBadge(
                    open24x7: listing.open24x7,
                    openNow: listing.isOpenNow,
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9AA9AB)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
