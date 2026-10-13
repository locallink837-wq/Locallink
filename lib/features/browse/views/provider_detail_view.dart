import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import '../state/saved_listings_notifier.dart';
import '../widgets/rating_badge.dart';
import '../widgets/write_review_sheet.dart';
import 'report_wrong_info_view.dart';
import 'reviews_list_view.dart';

/// Provider detail
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class ProviderDetailView extends StatefulWidget {
  const ProviderDetailView({super.key});

  static const route = '/browse/provider-detail';

  @override
  State<ProviderDetailView> createState() => _ProviderDetailViewState();
}

class _ProviderDetailViewState extends State<ProviderDetailView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();
  final _savedNotifier = SavedListingsNotifier();

  Listing? _listing;
  List<Review> _reviews = [];
  bool _isLoading = true;

  final double _userLat = Env.defaultLatitude;
  final double _userLng = Env.defaultLongitude;

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
        // Fallback demo service for direct dev menu access
        _listing = BrowseRepository.demoListings.firstWhere((l) => l.isService);
      }
      _loadReviews();
    }
  }

  Future<void> _fetchListingById(String id) async {
    final fetched = await _repository.fetchListingById(id);
    if (mounted) {
      setState(() => _listing = fetched ?? BrowseRepository.demoListings.firstWhere((l) => l.isService));
      _loadReviews();
    }
  }

  Future<void> _loadReviews() async {
    if (_listing == null) return;
    final revs = await _repository.fetchReviews(_listing!.id);
    if (mounted) {
      setState(() {
        _reviews = revs;
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

    final distanceLabel = _getDistance(listing);

    return ListenableBuilder(
      listenable: _savedNotifier,
      builder: (context, _) {
        final isSaved = _savedNotifier.isSaved(listing.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(listing.name),
            actions: [
              IconButton(
                tooltip: isSaved ? 'Remove Bookmark' : 'Save Provider',
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.teal : AppColors.inkLight,
                ),
                onPressed: () {
                  _savedNotifier.toggle(listing.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                        isSaved ? 'Removed from saved places' : 'Saved to your places',
                      ),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'report') {
                    Navigator.pushNamed(
                      context,
                      ReportWrongInfoView.route,
                      arguments: listing,
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report_problem_outlined, size: 18, color: AppColors.red),
                        SizedBox(width: 8),
                        Text('Report Wrong Info'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
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
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.handyman_rounded, color: AppColors.teal, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        listing.name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.inkLight,
                                        ),
                                      ),
                                    ),
                                    if (listing.verified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified, color: AppColors.teal, size: 18),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  listing.category,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muteLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                RatingBadge(
                                  rating: listing.averageRating,
                                  reviewCount: listing.reviewCount,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (listing.highlight.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tealLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing.highlight,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Request / Booking Callout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Need service right away?',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.inkLight,
                            ),
                          ),
                          OpenNowBadge(
                            open24x7: listing.open24x7,
                            openNow: listing.isOpenNow,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Request Service Now',
                        icon: const Icon(Icons.bolt, size: 18, color: Colors.white),
                        color: AppColors.teal,
                        onPressed: () {
                          // Route directly to service request flow
                          Navigator.pushNamed(
                            context,
                            '/requests/form',
                            arguments: {
                              'category': listing.category,
                              'providerId': listing.id,
                              'providerName': listing.name,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Location & Area Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
                    border: Border.all(color: AppColors.lineLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Service Location & Reach',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.inkLight,
                            ),
                          ),
                          if (distanceLabel.isNotEmpty)
                            Text(
                              distanceLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teal,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place_outlined, size: 18, color: AppColors.muteLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              listing.address,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (listing.phone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: AppColors.muteLight),
                            const SizedBox(width: 6),
                            Text(
                              listing.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Specializations & Tags
                if (listing.tags.isNotEmpty) ...[
                  const Text(
                    'Specializations & Services Offered',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: listing.tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Buttons Bar (Call & Directions)
                Row(
                  children: [
                    if (listing.phone.isNotEmpty) ...[
                      Expanded(
                        child: AppOutlineButton(
                          label: 'Call Direct',
                          icon: const Icon(Icons.call, size: 16, color: AppColors.teal),
                          color: AppColors.teal,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${listing.name}: ${listing.phone}'),
                                backgroundColor: AppColors.teal,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: AppOutlineButton(
                        label: 'Directions',
                        icon: const Icon(Icons.directions, size: 16, color: AppColors.teal),
                        color: AppColors.teal,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Directions to ${listing.address} ($distanceLabel)'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // Customer Reviews Preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Reviews (${_reviews.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        ReviewsListView.route,
                        arguments: listing,
                      ),
                      child: const Text(
                        'View all',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_reviews.isEmpty)
                  const Text('No reviews yet. Be the first to review!', style: TextStyle(color: AppColors.muteLight))
                else
                  ..._reviews.take(3).map((r) => _buildReviewCard(r)),

                const SizedBox(height: 12),
                AppOutlineButton(
                  label: 'Write a Review',
                  icon: const Icon(Icons.rate_review_outlined, size: 16, color: AppColors.teal),
                  color: AppColors.teal,
                  onPressed: () {
                    WriteReviewSheet.show(
                      context,
                      listingId: listing.id,
                      listingName: listing.name,
                      onReviewSubmitted: _loadReviews,
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(Review r) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.authorName,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkLight,
                ),
              ),
              RatingBadge(rating: r.rating, showCount: false),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            r.comment,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muteLight,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getDistance(Listing listing) {
    if (listing.latitude == null || listing.longitude == null) return '';
    final meters = _locationService.calculateDistanceMeters(
      startLatitude: _userLat,
      startLongitude: _userLng,
      endLatitude: listing.latitude!,
      endLongitude: listing.longitude!,
    );
    return _locationService.formatDistance(meters);
  }
}
