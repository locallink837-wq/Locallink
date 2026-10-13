import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'place_detail_view.dart';
import 'provider_detail_view.dart';
import 'shop_detail_view.dart';

/// Search results
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class SearchResultsView extends StatefulWidget {
  const SearchResultsView({super.key});

  static const route = '/browse/search-results';

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();
  final _controller = TextEditingController();

  String _searchQuery = '';
  String _selectedKind = 'all'; // all | service | place | shop
  bool _isLoading = false;
  List<Listing> _allListings = [];
  List<Listing> _results = [];

  final double _userLat = Env.defaultLatitude;
  final double _userLng = Env.defaultLongitude;

  final List<String> _suggestedTags = [
    'Electrician',
    'Hospital',
    'Pharmacy',
    'Plumber',
    'AC Repair',
    'Bakery',
    'College',
    'Locksmith',
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    final list = await _repository.fetchListings();
    if (mounted) {
      setState(() {
        _allListings = list;
        _isLoading = false;
        _performFilter();
      });
    }
  }

  void _performFilter() {
    final q = _searchQuery.trim().toLowerCase();

    var list = _allListings;
    if (_selectedKind != 'all') {
      list = list.where((l) => l.kind == _selectedKind).toList();
    }

    if (q.isNotEmpty) {
      list = list.where((l) {
        final matchName = l.name.toLowerCase().contains(q);
        final matchCat = l.category.toLowerCase().contains(q);
        final matchAddr = l.address.toLowerCase().contains(q);
        final matchTags = l.tags.any((t) => t.toLowerCase().contains(q));
        final matchHighlight = l.highlight.toLowerCase().contains(q);
        return matchName || matchCat || matchAddr || matchTags || matchHighlight;
      }).toList();
    }

    setState(() {
      _results = _locationService.sortByDistanceAndVerified(
        listings: list,
        userLat: _userLat,
        userLng: _userLng,
      );
    });
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
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (val) {
              setState(() => _searchQuery = val);
              _performFilter();
            },
            decoration: InputDecoration(
              hintText: 'Search services, places & shops...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _searchQuery = '');
                        _performFilter();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs (All, Services, Places, Shops)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildKindChip('all', 'All Results', AppColors.inkLight),
                  const SizedBox(width: 6),
                  _buildKindChip('service', 'Services', AppColors.teal),
                  const SizedBox(width: 6),
                  _buildKindChip('place', 'Places', AppColors.indigo),
                  const SizedBox(width: 6),
                  _buildKindChip('shop', 'Shops', AppColors.amber),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Suggested search pills when query is empty
          if (_searchQuery.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: const Text(
                'POPULAR SEARCHES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.secondaryMuteLight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _suggestedTags.map((tag) {
                  return ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 11.5)),
                    onPressed: () {
                      _controller.text = tag;
                      setState(() => _searchQuery = tag);
                      _performFilter();
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Results header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchQuery.isEmpty
                      ? 'Nearby (${_results.length})'
                      : 'Results (${_results.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muteLight,
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? EmptyState(
                        title: 'No matches found',
                        message: 'We couldn\'t find any listings matching "$_searchQuery".',
                        icon: Icons.search_off_rounded,
                        actionLabel: 'Clear Search',
                        onAction: () {
                          _controller.clear();
                          setState(() => _searchQuery = '');
                          _performFilter();
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final listing = _results[index];
                          return ListingCard(
                            listing: listing,
                            distanceLabel: _getDistance(listing),
                            onTap: () => _openDetail(listing),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildKindChip(String kind, String label, Color color) {
    final isSelected = _selectedKind == kind;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: isSelected ? color : AppColors.inkLight,
      ),
      side: BorderSide(
        color: isSelected ? color : AppColors.inputBorderLight,
      ),
      onSelected: (_) {
        setState(() => _selectedKind = kind);
        _performFilter();
      },
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
