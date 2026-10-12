import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/lead.dart';
import '../../../core/widgets/ui_kit.dart';
import 'confirm_fee_sheet_view.dart';

/// Screen 6.7: Provider Lead Detail.
/// Displays summary, customer photo, approximate area location, and fee acceptance prompt.
/// Explicitly hides phone number and exact address before acceptance.
class LeadDetailView extends StatelessWidget {
  const LeadDetailView({super.key});

  static const route = '/provider/lead-detail';

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final lead = args['lead'] as Lead?;

    if (lead == null) {
      return const Scaffold(
        body: Center(child: Text('Lead details not available')),
      );
    }

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'New request',
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: 'Accept and pay ₹${lead.fee}',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  ConfirmFeeSheetView.route,
                  arguments: {'lead': lead},
                );
              },
            ),
            const SizedBox(height: 10),
            UiGhostButton(
              label: 'Ignore',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lead summary card with category chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UiChip(
                          label: lead.category.isNotEmpty ? lead.category : 'General',
                          isSelected: true,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: UiColors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Urgent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: UiColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    uiText(
                      lead.summary.isNotEmpty ? lead.summary : 'Customer reported an urgent issue requiring inspection.',
                      size: 15,
                      weight: FontWeight.w700,
                      height: 1.4,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined, size: 16, color: UiColors.muted),
                        const SizedBox(width: 4),
                        uiText('${lead.areaLabel} (${lead.formattedDistance})', size: 12, color: UiColors.muted),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Customer attached photo card
              uiText('Customer photo', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECEB),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image_rounded, size: 36, color: UiColors.muted),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Approximate area map placeholder
              uiText('Approx location', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),
              UiMapPlaceholder(
                label: lead.areaLabel.isNotEmpty ? lead.areaLabel : 'Approximate neighborhood',
                height: 130,
              ),
              const SizedBox(height: 12),

              // Privacy tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: UiColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 16, color: UiColors.indigo),
                    const SizedBox(width: 8),
                    Expanded(
                      child: uiText(
                        'Exact address & phone number unlock after acceptance.',
                        size: 11,
                        color: UiColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
