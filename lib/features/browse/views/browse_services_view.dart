import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'provider_detail_view.dart';

/// Browse Services
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class BrowseServicesView extends StatefulWidget {
  const BrowseServicesView({super.key});

  static const route = '/browse/browse-services';

  @override
  State<BrowseServicesView> createState() => _BrowseServicesViewState();
}

class _BrowseServicesViewState extends State<BrowseServicesView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();

  final List<String> _categories = [
    'All',
    'Electrician',
    'Plumber',
    'Appliance',
    'Cleaning',
    'Carpenter',
    'Locksmith',
  ];

  String _selectedCategory = 'All';
  bool _verifiedOnly = false;
  bool _openNowOnly = false;
  String _searchQuery = '';
  bool _isLoading = true;
  List<Listing> _services = [];

  double _userLat = Env.defaultLatitude;
  double _userLng = Env.defaultLongitude;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);

    if (!_repository.hasRealUser) {
      if (mounted) {
        setState(() {
          _services = [];
          _isLoading = false;
        });
      }
      return;
    }

    final position = await _locationService.getCurrentPosition();
    _userLat = position.latitude;
    _userLng = position.longitude;

    final categoryFilter = _selectedCategory == 'All'
        ? null
        : _selectedCategory;
    final results = await _repository.fetchListings(
      kind: 'service',
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
        _services = sorted;
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    final q = _searchQuery.toLowerCase();
    return _services.where((s) {
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
        title: const Text('Local Services'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppSearchBar(
              hintText: 'Search electricians, plumbers...',
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
                          activeColor: AppColors.teal,
                          onTap: () {
                            setState(() => _selectedCategory = cat);
                            _fetchServices();
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
                        selectedColor: AppColors.teal.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.teal,
                        onSelected: (val) {
                          setState(() => _openNowOnly = val);
                          _fetchServices();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text(
                          'Verified Only',
                          style: TextStyle(fontSize: 11),
                        ),
                        selected: _verifiedOnly,
                        selectedColor: AppColors.teal.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.teal,
                        onSelected: (val) {
                          setState(() => _verifiedOnly = val);
                          _fetchServices();
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
            child: !_repository.hasRealUser
                ? EmptyState(
                    title: 'Sign in to browse services',
                    message: 'Verified service listings are available to signed-in customers.',
                    icon: Icons.lock_outline_rounded,
                    actionLabel: 'Sign In',
                    onAction: () =>
                        Navigator.pushNamed(context, '/auth/sign-in'),
                  )
                : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  )
                : _filteredServices.isEmpty
                ? EmptyState(
                    title: 'No services found',
                    message: 'Try clearing your filters or search terms to find more providers.',
                    icon: Icons.handyman_outlined,
                    actionLabel: 'Reset Filters',
                    onAction: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _verifiedOnly = false;
                        _openNowOnly = false;
                        _searchQuery = '';
                      });
                      _fetchServices();
                    },
                  )
                : RefreshIndicator(
                    onRefresh: _fetchServices,
                    color: AppColors.teal,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredServices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final listing = _filteredServices[index];
                        return ListingCard(
                          listing: listing,
                          distanceLabel: _getDistance(listing),
                          onTap: () => Navigator.pushNamed(
                            context,
                            ProviderDetailView.route,
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
