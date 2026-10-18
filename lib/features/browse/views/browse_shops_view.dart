import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'shop_detail_view.dart';

/// Browse Shops
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class BrowseShopsView extends StatefulWidget {
  const BrowseShopsView({super.key});

  static const route = '/browse/browse-shops';

  @override
  State<BrowseShopsView> createState() => _BrowseShopsViewState();
}

class _BrowseShopsViewState extends State<BrowseShopsView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();

  final List<String> _categories = [
    'All',
    'Pharmacy',
    'Bakery & Sweets',
    'Grocery',
    'Stationery',
    'Electronics',
    'Hardware',
  ];

  String _selectedCategory = 'All';
  bool _verifiedOnly = false;
  bool _openNowOnly = false;
  String _searchQuery = '';
  bool _isLoading = true;
  List<Listing> _shops = [];

  double _userLat = Env.defaultLatitude;
  double _userLng = Env.defaultLongitude;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    setState(() => _isLoading = true);

    final position = await _locationService.getCurrentPosition();
    _userLat = position.latitude;
    _userLng = position.longitude;

    final categoryFilter = _selectedCategory == 'All'
        ? null
        : _selectedCategory;
    final results = await _repository.fetchListings(
      kind: 'shop',
      category: categoryFilter,
      verifiedOnly: _verifiedOnly ? true : null,
      openNowOnly: _openNowOnly ? true : null,
    );

    final sorted = _locationService.sortByDistanceAndVerified(
      listings: results,
      userLat: _userLat,
      userLng: _userLng,
    );

    if (mounted) {
      setState(() {
        _shops = sorted;
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filteredShops {
    if (_searchQuery.isEmpty) return _shops;
    final q = _searchQuery.toLowerCase();
    return _shops.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q) ||
          s.tags.any((t) => t.toLowerCase().contains(q)) ||
          s.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Shops & Markets'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppSearchBar(
              hintText: 'Search pharmacies, groceries, stores...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: CategoryChip(
                          label: cat,
                          isSelected: isSelected,
                          activeColor: AppColors.amber,
                          onTap: () {
                            setState(() => _selectedCategory = cat);
                            _fetchShops();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text(
                          'Open Now',
                          style: TextStyle(fontSize: 11),
                        ),
                        selected: _openNowOnly,
                        selectedColor: AppColors.amber.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.amber,
                        onSelected: (val) {
                          setState(() => _openNowOnly = val);
                          _fetchShops();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text(
                          'Verified Only',
                          style: TextStyle(fontSize: 11),
                        ),
                        selected: _verifiedOnly,
                        selectedColor: AppColors.amber.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.amber,
                        onSelected: (val) {
                          setState(() => _verifiedOnly = val);
                          _fetchShops();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Listings List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.amber),
                  )
                : _filteredShops.isEmpty
                ? EmptyState(
                    title: 'No shops found',
                    message: 'Try clearing your filters to see more local stores and pharmacies.',
                    icon: Icons.storefront_outlined,
                    actionLabel: 'Reset Filters',
                    onAction: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _verifiedOnly = false;
                        _openNowOnly = false;
                        _searchQuery = '';
                      });
                      _fetchShops();
                    },
                  )
                : RefreshIndicator(
                    onRefresh: _fetchShops,
                    color: AppColors.amber,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredShops.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final listing = _filteredShops[index];
                        return ListingCard(
                          listing: listing,
                          distanceLabel: _getDistance(listing),
                          onTap: () => Navigator.pushNamed(
                            context,
                            ShopDetailView.route,
                            arguments: listing,
                          ),
                        );
                      },
                    ),
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
