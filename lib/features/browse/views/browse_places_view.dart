import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'place_detail_view.dart';

/// Browse Places
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class BrowsePlacesView extends StatefulWidget {
  const BrowsePlacesView({super.key});

  static const route = '/browse/browse-places';

  @override
  State<BrowsePlacesView> createState() => _BrowsePlacesViewState();
}

class _BrowsePlacesViewState extends State<BrowsePlacesView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();

  final List<String> _categories = [
    'All',
    'Hospital',
    'College',
    'Transport',
    'Police',
    'Park',
    'Bank & ATM',
  ];

  String _selectedCategory = 'All';
  bool _verifiedOnly = false;
  bool _open24x7Only = false;
  String _searchQuery = '';
  bool _isLoading = true;
  List<Listing> _places = [];

  final double _userLat = Env.defaultLatitude;
  final double _userLng = Env.defaultLongitude;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() => _isLoading = true);

    final categoryFilter = _selectedCategory == 'All' ? null : _selectedCategory;
    final results = await _repository.fetchListings(
      kind: 'place',
      category: categoryFilter,
      verifiedOnly: _verifiedOnly ? true : null,
    );

    var filtered = results;
    if (_open24x7Only) {
      filtered = filtered.where((p) => p.open24x7).toList();
    }

    final sorted = _locationService.sortByDistanceAndVerified(
      listings: filtered,
      userLat: _userLat,
      userLng: _userLng,
    );

    if (mounted) {
      setState(() {
        _places = sorted;
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filteredPlaces {
    if (_searchQuery.isEmpty) return _places;
    final q = _searchQuery.toLowerCase();
    return _places.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q)) ||
          p.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Places & Amenities'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppSearchBar(
              hintText: 'Search hospitals, colleges, parks...',
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
                          activeColor: AppColors.indigo,
                          onTap: () {
                            setState(() => _selectedCategory = cat);
                            _fetchPlaces();
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
                        label: const Text('Open 24x7', style: TextStyle(fontSize: 11)),
                        selected: _open24x7Only,
                        selectedColor: AppColors.indigo.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.indigo,
                        onSelected: (val) {
                          setState(() => _open24x7Only = val);
                          _fetchPlaces();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Verified Only', style: TextStyle(fontSize: 11)),
                        selected: _verifiedOnly,
                        selectedColor: AppColors.indigo.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.indigo,
                        onSelected: (val) {
                          setState(() => _verifiedOnly = val);
                          _fetchPlaces();
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
                ? const Center(child: CircularProgressIndicator(color: AppColors.indigo))
                : _filteredPlaces.isEmpty
                    ? EmptyState(
                        title: 'No places found',
                        message: 'No public places matched your filters in this area.',
                        icon: Icons.account_balance_outlined,
                        actionLabel: 'Reset Filters',
                        onAction: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _verifiedOnly = false;
                            _open24x7Only = false;
                            _searchQuery = '';
                          });
                          _fetchPlaces();
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchPlaces,
                        color: AppColors.indigo,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPlaces.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final listing = _filteredPlaces[index];
                            return ListingCard(
                              listing: listing,
                              distanceLabel: _getDistance(listing),
                              onTap: () => Navigator.pushNamed(
                                context,
                                PlaceDetailView.route,
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
