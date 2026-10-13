import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'place_detail_view.dart';
import 'provider_detail_view.dart';
import 'shop_detail_view.dart';

/// Listing list
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class ListingListView extends StatefulWidget {
  const ListingListView({super.key});

  static const route = '/browse/listing-list';

  @override
  State<ListingListView> createState() => _ListingListViewState();
}

class _ListingListViewState extends State<ListingListView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();

  String _title = 'Listings';
  String? _kind;
  String? _category;
  String? _tag;

  bool _initialized = false;
  bool _isLoading = true;
  bool _verifiedOnly = false;
  bool _openNowOnly = false;
  bool _sortByRating = false;
  String _searchQuery = '';

  List<Listing> _listings = [];

  final double _userLat = Env.defaultLatitude;
  final double _userLng = Env.defaultLongitude;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _title = args['title'] as String? ?? 'Listings';
        _kind = args['kind'] as String?;
        _category = args['category'] as String?;
        _tag = args['tag'] as String?;
      }
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final raw = await _repository.fetchListings(
      kind: _kind,
      category: _category,
      verifiedOnly: _verifiedOnly ? true : null,
      openNowOnly: _openNowOnly ? true : null,
    );

    var list = raw;
    if (_tag != null && _tag!.isNotEmpty) {
      list = list.where((l) => l.tags.contains(_tag)).toList();
    }

    if (_sortByRating) {
      list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    } else {
      list = _locationService.sortByDistanceAndVerified(
        listings: list,
        userLat: _userLat,
        userLng: _userLng,
      );
    }

    if (mounted) {
      setState(() {
        _listings = list;
        _isLoading = false;
      });
    }
  }

  List<Listing> get _displayListings {
    if (_searchQuery.isEmpty) return _listings;
    final q = _searchQuery.toLowerCase();
    return _listings.where((l) {
      return l.name.toLowerCase().contains(q) ||
          l.category.toLowerCase().contains(q) ||
          l.address.toLowerCase().contains(q) ||
          l.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  void _openDetail(Listing listing) {
    if (listing.isService) {
      Navigator.pushNamed(context, ProviderDetailView.route, arguments: listing);
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
        title: Text(_title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppSearchBar(
              hintText: 'Search within $_title...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Open Now', style: TextStyle(fontSize: 11)),
                  selected: _openNowOnly,
                  onSelected: (val) {
                    setState(() => _openNowOnly = val);
                    _fetchData();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Verified', style: TextStyle(fontSize: 11)),
                  selected: _verifiedOnly,
                  onSelected: (val) {
                    setState(() => _verifiedOnly = val);
                    _fetchData();
                  },
                ),
                const Spacer(),
                ActionChip(
                  avatar: Icon(
                    _sortByRating ? Icons.star_rounded : Icons.near_me_rounded,
                    size: 14,
                    color: AppColors.teal,
                  ),
                  label: Text(
                    _sortByRating ? 'Top Rated' : 'Nearest',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    setState(() => _sortByRating = !_sortByRating);
                    _fetchData();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                : _displayListings.isEmpty
                    ? EmptyState(
                        title: 'No listings found',
                        message: 'No places match the active criteria in this category.',
                        icon: Icons.list_alt_rounded,
                        actionLabel: 'Reset Filters',
                        onAction: () {
                          setState(() {
                            _verifiedOnly = false;
                            _openNowOnly = false;
                            _searchQuery = '';
                            _sortByRating = false;
                          });
                          _fetchData();
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        color: AppColors.teal,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _displayListings.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final listing = _displayListings[index];
                            return ListingCard(
                              listing: listing,
                              distanceLabel: _getDistance(listing),
                              onTap: () => _openDetail(listing),
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
