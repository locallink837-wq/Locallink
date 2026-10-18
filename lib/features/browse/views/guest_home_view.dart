import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'browse_places_view.dart';
import 'browse_shops_view.dart';
import 'place_detail_view.dart';
import 'search_results_view.dart';
import 'shop_detail_view.dart';

/// Guest Home
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class GuestHomeView extends StatefulWidget {
  const GuestHomeView({super.key});

  static const route = '/browse/guest-home';

  @override
  State<GuestHomeView> createState() => _GuestHomeViewState();
}

class _GuestHomeViewState extends State<GuestHomeView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();

  List<Listing> _places = [];
  List<Listing> _shops = [];
  bool _isLoading = true;

  double _userLat = Env.defaultLatitude;
  double _userLng = Env.defaultLongitude;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final position = await _locationService.getCurrentPosition();
    _userLat = position.latitude;
    _userLng = position.longitude;

    final allListings = await _repository.fetchNearbyListings(
      userLat: _userLat,
      userLng: _userLng,
    );

    if (mounted) {
      setState(() {
        _places = allListings.where((l) => l.isPlace).take(3).toList();
        _shops = allListings.where((l) => l.isShop).take(3).toList();
        _isLoading = false;
      });
    }
  }

  void _openDetail(Listing listing) {
    if (listing.isPlace) {
      Navigator.pushNamed(context, PlaceDetailView.route, arguments: listing);
    } else {
      Navigator.pushNamed(context, ShopDetailView.route, arguments: listing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore LocaLink'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/auth/sign-in'),
            icon: const Icon(
              Icons.login_rounded,
              size: 16,
              color: AppColors.teal,
            ),
            label: const Text(
              'Sign In',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.teal,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guest Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.teal.withValues(alpha: 0.1),
                      AppColors.indigo.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: AppColors.teal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Browsing in Guest Mode',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.inkLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Sign in anytime to book verified services or save favorites.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muteLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Search Bar
              AppSearchBar(
                hintText: 'Search places & shops...',
                readOnly: true,
                onTap: () =>
                    Navigator.pushNamed(context, SearchResultsView.route),
              ),
              const SizedBox(height: 16),

              // Modules row
              Row(
                children: [
                  _buildPillTab(
                    'Places',
                    Icons.account_balance_rounded,
                    AppColors.indigo,
                    () => Navigator.pushNamed(context, BrowsePlacesView.route),
                  ),
                  const SizedBox(width: 8),
                  _buildPillTab(
                    'Shops',
                    Icons.storefront_rounded,
                    AppColors.amber,
                    () => Navigator.pushNamed(context, BrowseShopsView.route),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Places
              _buildSectionTitle(
                'Public Amenities & Places',
                AppColors.indigo,
                () {
                  Navigator.pushNamed(context, BrowsePlacesView.route);
                },
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ..._places.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListingCard(
                      listing: l,
                      distanceLabel: _getDistance(l),
                      onTap: () => _openDetail(l),
                    ),
                  ),
                ),
              const SizedBox(height: 18),

              // Shops
              _buildSectionTitle(
                'Local Stores & Pharmacies',
                AppColors.amber,
                () {
                  Navigator.pushNamed(context, BrowseShopsView.route);
                },
              ),
              const SizedBox(height: 8),
              ..._shops.map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListingCard(
                    listing: l,
                    distanceLabel: _getDistance(l),
                    onTap: () => _openDetail(l),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillTab(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white,
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.inkLight,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'See all',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
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
