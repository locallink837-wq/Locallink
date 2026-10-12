import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/listing.dart';
import '../../../core/models/review.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';

/// Screen: My Reviews (Tagged NEW in UI/UX E_F).
/// Streams provider reviews from listings/{uid}/reviews and shows rating summary.
class MyReviewsView extends StatelessWidget {
  const MyReviewsView({super.key});

  static const route = '/provider/my-reviews';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repo = ProviderRepository();

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'My reviews',
        body: uid.isEmpty
            ? const Center(child: Text('Please log in'))
            : StreamBuilder<Listing?>(
                stream: repo.streamListing(uid),
                builder: (context, listingSnap) {
                  final listing = listingSnap.data;
                  final avgRating = listing?.averageRating ?? 0.0;
                  final reviewCount = listing?.reviewCount ?? 0;

                  return Column(
                    children: [
                      // Overall rating summary card
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  avgRating > 0 ? avgRating.toStringAsFixed(1) : '5.0',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: UiColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star_rounded, color: UiColors.star, size: 32),
                              ],
                            ),
                            const SizedBox(height: 4),
                            uiText(
                              'Average rating from $reviewCount customer reviews',
                              size: 12.5,
                              color: UiColors.muted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer reviews list stream
                      Expanded(
                        child: StreamBuilder<List<Review>>(
                          stream: repo.streamReviews(uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            }

                            final reviews = snapshot.data ?? [];
                            if (reviews.isEmpty) {
                              return const EmptyState(
                                title: 'No reviews yet',
                                message: 'Customer ratings and feedback after completed jobs will show up here.',
                                icon: Icons.star_outline_rounded,
                              );
                            }

                            return ListView.builder(
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                final r = reviews[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          uiText(r.authorName, size: 14, weight: FontWeight.w700),
                                          UiStarRating(rating: r.rating),
                                        ],
                                      ),
                                      if (r.comment.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        uiText(r.comment, size: 13, color: UiColors.ink, height: 1.4),
                                      ],
                                      if (r.createdAt != null) ...[
                                        const SizedBox(height: 6),
                                        uiText(
                                          '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}',
                                          size: 11,
                                          color: UiColors.muted,
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
