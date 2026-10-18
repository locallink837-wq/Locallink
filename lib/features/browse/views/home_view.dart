import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'browse_places_view.dart';
import 'browse_services_view.dart';
import 'browse_shops_view.dart';
import 'listing_list_view.dart';
import 'place_detail_view.dart';
import 'provider_detail_view.dart';
import 'saved_places_view.dart';
import 'search_results_view.dart';
import 'shop_detail_view.dart';

/// Home
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const route = '/browse/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();

  List<Listing> _services = [];
  List<Listing> _places = [];
  List<Listing> _shops = [];
  bool _isLoading = true;
  String _currentArea = Env.defaultAreaLabel;

  double _userLat = Env.defaultLatitude;
  double _userLng = Env.defaultLongitude;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final pos = await _locationService.getCurrentPosition();
      _userLat = pos.latitude;
      _userLng = pos.longitude;
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final area =
            [place.subLocality, place.locality, place.administrativeArea]
                .whereType<String>()
                .where((value) => value.trim().isNotEmpty)
                .take(2)
                .join(', ');
        if (area.isNotEmpty && mounted) {
          setState(() => _currentArea = area);
        }
      }
    } catch (_) {}

    final allListings = await _repository.fetchNearbyListings(
      userLat: _userLat,
      userLng: _userLng,
    );

    if (mounted) {
      setState(() {
        _services = allListings.where((l) => l.isService).take(4).toList();
        _places = allListings.where((l) => l.isPlace).take(4).toList();
        _shops = allListings.where((l) => l.isShop).take(4).toList();
        _isLoading = false;
      });
    }
  }

  void _openDetail(Listing listing) {
    if (listing.isService) {
      Navigator.pushNamed(
        context,
        ProviderDetailView.route,
        arguments: listing,
      );
    } else if (listing.isPlace) {
      Navigator.pushNamed(context, PlaceDetailView.route, arguments: listing);
    } else {
      Navigator.pushNamed(context, ShopDetailView.route, arguments: listing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 18,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.secondaryMuteLight,
                    ),
                  ),
                  Text(
                    _currentArea,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saved Places',
            icon: const Icon(
              Icons.bookmark_outline_rounded,
              color: AppColors.inkLight,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, SavedPlacesView.route),
          ),
          const SizedBox(width: 4),
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
              // Search Bar
              AppSearchBar(
                hintText: 'Search services, places & shops...',
                readOnly: true,
                onTap: () =>
                    Navigator.pushNamed(context, SearchResultsView.route),
              ),
              const SizedBox(height: 12),

              // SOS Emergency Quick Banner
              SosBanner(
                title: 'Emergency SOS • Need immediate help?',
                onTap: () => Navigator.pushNamed(context, '/safety/sos'),
              ),
              const SizedBox(height: 20),

              // Hero Category Cards (Services, Places, Shops)
              Row(
                children: [
                  _buildModuleCard(
                    context,
                    title: 'Services',
                    count: '${_services.length}+ Nearby',
                    color: AppColors.teal,
                    icon: Icons.handyman_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, BrowseServicesView.route),
                  ),
                  const SizedBox(width: 8),
                  _buildModuleCard(
                    context,
                    title: 'Places',
                    count: '${_places.length}+ Nearby',
                    color: AppColors.indigo,
                    icon: Icons.account_balance_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, BrowsePlacesView.route),
                  ),
                  const SizedBox(width: 8),
                  _buildModuleCard(
                    context,
                    title: 'Shops',
                    count: '${_shops.length}+ Nearby',
                    color: AppColors.amber,
                    icon: Icons.storefront_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, BrowseShopsView.route),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Quick Service Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Services',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkLight,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, BrowseServicesView.route),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CategoryGrid(
                crossAxisCount: 3,
                spacing: 8,
                defaultColor: AppColors.teal,
                items: [
                  CategoryGridItem(
                    label: 'Electrician',
                    icon: Icons.bolt_rounded,
                    onTap: () => _openCategoryList('Electrician', 'service'),
                  ),
                  CategoryGridItem(
                    label: 'Plumber',
                    icon: Icons.build_rounded,
                    onTap: () => _openCategoryList('Plumber', 'service'),
                  ),
                  CategoryGridItem(
                    label: 'Appliance',
                    icon: Icons.kitchen_rounded,
                    onTap: () => _openCategoryList('Appliance', 'service'),
                  ),
                  CategoryGridItem(
                    label: 'Cleaning',
                    icon: Icons.auto_awesome_rounded,
                    onTap: () => _openCategoryList('Cleaning', 'service'),
                  ),
                  CategoryGridItem(
                    label: 'Carpenter',
                    icon: Icons.carpenter_rounded,
                    onTap: () => _openCategoryList('Carpenter', 'service'),
                  ),
                  CategoryGridItem(
                    label: 'Locksmith',
                    icon: Icons.key_rounded,
                    onTap: () => _openCategoryList('Locksmith', 'service'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nearby Services Section
              _buildSectionHeader(
                title: 'Top Services Nearby',
                color: AppColors.teal,
                onViewAll: () => Navigator.pushNamed(
                  context,
                  ListingListView.route,
                  arguments: const {'title': 'All Services', 'kind': 'service'},
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                )
              else
                ..._services.map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListingCard(
                      listing: listing,
                      distanceLabel: _getDistance(listing),
                      onTap: () => _openDetail(listing),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Essential Places Section
              _buildSectionHeader(
                title: 'Public Places & Essentials',
                color: AppColors.indigo,
                onViewAll: () =>
                    Navigator.pushNamed(context, BrowsePlacesView.route),
              ),
              const SizedBox(height: 8),
              ..._places.map(
                (listing) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListingCard(
                    listing: listing,
                    distanceLabel: _getDistance(listing),
                    onTap: () => _openDetail(listing),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Popular Shops Section
              _buildSectionHeader(
                title: 'Daily Shops & Markets',
                color: AppColors.amber,
                onViewAll: () =>
                    Navigator.pushNamed(context, BrowseShopsView.route),
              ),
              const SizedBox(height: 8),
              ..._shops.map(
                (listing) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListingCard(
                    listing: listing,
                    distanceLabel: _getDistance(listing),
                    onTap: () => _openDetail(listing),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryMuteLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required Color color,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.inkLight,
              ),
            ),
          ],
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

  void _openCategoryList(String category, String kind) {
    Navigator.pushNamed(
      context,
      ListingListView.route,
      arguments: {'title': category, 'kind': kind, 'category': category},
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
