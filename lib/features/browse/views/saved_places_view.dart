import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import '../state/saved_listings_notifier.dart';
import 'place_detail_view.dart';
import 'provider_detail_view.dart';
import 'shop_detail_view.dart';

/// Saved places
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class SavedPlacesView extends StatefulWidget {
  const SavedPlacesView({super.key});

  static const route = '/browse/saved-places';

  @override
  State<SavedPlacesView> createState() => _SavedPlacesViewState();
}

class _SavedPlacesViewState extends State<SavedPlacesView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();
  final _savedNotifier = SavedListingsNotifier();

  String _filterKind = 'all'; // all | service | place | shop
  List<Listing> _savedListings = [];
  bool _isLoading = true;

  final double _userLat = Env.defaultLatitude;
  final double _userLng = Env.defaultLongitude;

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _savedNotifier.addListener(_loadSaved);
  }

  @override
  void dispose() {
    _savedNotifier.removeListener(_loadSaved);
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final ids = _savedNotifier.savedIds;
    final listings = await _repository.fetchSavedListings(ids);

    if (mounted) {
      setState(() {
        _savedListings = _locationService.sortByDistanceAndVerified(
          listings: listings,
          userLat: _userLat,
          userLng: _userLng,
        );
        _isLoading = false;
      });
    }
  }

  List<Listing> get _displayListings {
    if (_filterKind == 'all') return _savedListings;
    return _savedListings.where((l) => l.kind == _filterKind).toList();
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
        title: const Text('Saved Places'),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildKindChip('all', 'All (${_savedListings.length})', AppColors.inkLight),
                  const SizedBox(width: 6),
                  _buildKindChip(
                    'service',
                    'Services (${_savedListings.where((l) => l.isService).length})',
                    AppColors.teal,
                  ),
                  const SizedBox(width: 6),
                  _buildKindChip(
                    'place',
                    'Places (${_savedListings.where((l) => l.isPlace).length})',
                    AppColors.indigo,
                  ),
                  const SizedBox(width: 6),
                  _buildKindChip(
                    'shop',
                    'Shops (${_savedListings.where((l) => l.isShop).length})',
                    AppColors.amber,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayListings.isEmpty
                    ? EmptyState(
                        title: 'No saved places yet',
                        message: 'Tap the bookmark icon on any shop, service, or landmark to save it here for fast access.',
                        icon: Icons.bookmark_border_rounded,
                        actionLabel: 'Explore Nearby',
                        onAction: () => Navigator.pop(context),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _displayListings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final listing = _displayListings[index];
                          return Dismissible(
                            key: ValueKey(listing.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              _savedNotifier.remove(listing.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed ${listing.name} from saved places')),
                              );
                            },
                            child: ListingCard(
                              listing: listing,
                              distanceLabel: _getDistance(listing),
                              onTap: () => _openDetail(listing),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildKindChip(String kind, String label, Color color) {
    final isSelected = _filterKind == kind;
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
      onSelected: (_) => setState(() => _filterKind = kind),
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
