import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import '../widgets/rating_badge.dart';
import '../widgets/write_review_sheet.dart';

/// Reviews list
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class ReviewsListView extends StatefulWidget {
  const ReviewsListView({super.key});

  static const route = '/browse/reviews-list';

  @override
  State<ReviewsListView> createState() => _ReviewsListViewState();
}

class _ReviewsListViewState extends State<ReviewsListView> {
  final _repository = BrowseRepository();

  Listing? _listing;
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listing == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Listing) {
        _listing = args;
      } else if (args is String) {
        _fetchListingById(args);
        return;
      } else {
        _listing = BrowseRepository.demoListings.first;
      }
      _loadReviews();
    }
  }

  Future<void> _fetchListingById(String id) async {
    final fetched = await _repository.fetchListingById(id);
    if (mounted) {
      setState(() => _listing = fetched ?? BrowseRepository.demoListings.first);
      _loadReviews();
    }
  }

  Future<void> _loadReviews() async {
    if (_listing == null) return;
    setState(() => _isLoading = true);
    final list = await _repository.fetchReviews(_listing!.id);
    if (mounted) {
      setState(() {
        _reviews = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = _listing;
    if (listing == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${listing.name} Reviews'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () {
          WriteReviewSheet.show(
            context,
            listingId: listing.id,
            listingName: listing.name,
            onReviewSubmitted: _loadReviews,
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        color: AppColors.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
                  border: Border.all(color: AppColors.lineLight),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Big Average Rating
                    Column(
                      children: [
                        Text(
                          listing.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: AppColors.inkLight,
                            letterSpacing: -1,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            final isFilled = (index + 1) <= listing.averageRating.round();
                            return Icon(
                              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: isFilled ? AppColors.star : AppColors.lineLight,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${listing.reviewCount} reviews',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muteLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Star distribution bars
                    Expanded(
                      child: Column(
                        children: [
                          _buildRatingBar(5, 0.75),
                          _buildRatingBar(4, 0.18),
                          _buildRatingBar(3, 0.05),
                          _buildRatingBar(2, 0.01),
                          _buildRatingBar(1, 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Community Feedback',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkLight,
                ),
              ),
              const SizedBox(height: 10),

              // Reviews List
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_reviews.isEmpty)
                EmptyState(
                  title: 'No reviews yet',
                  message: 'Be the first person in your neighborhood to share feedback for ${listing.name}.',
                  icon: Icons.rate_review_outlined,
                  actionLabel: 'Write Review',
                  onAction: () {
                    WriteReviewSheet.show(
                      context,
                      listingId: listing.id,
                      listingName: listing.name,
                      onReviewSubmitted: _loadReviews,
                    );
                  },
                )
              else
                ..._reviews.map((r) => _buildReviewTile(r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, double pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muteLight),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: AppColors.lineLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.star),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(Review r) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                child: Text(
                  r.authorName.isNotEmpty ? r.authorName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.teal, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.authorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkLight,
                      ),
                    ),
                    if (r.createdAt != null)
                      Text(
                        '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryMuteLight,
                        ),
                      ),
                  ],
                ),
              ),
              RatingBadge(rating: r.rating, showCount: false),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.comment,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.inkLight,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
