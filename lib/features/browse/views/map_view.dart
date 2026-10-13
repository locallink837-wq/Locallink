import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'listing_list_view.dart';
import 'place_detail_view.dart';
import 'provider_detail_view.dart';
import 'shop_detail_view.dart';

/// Interactive Radar & Map Explorer
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class MapView extends StatefulWidget {
  const MapView({super.key});

  static const route = '/browse/map';

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _repository = BrowseRepository();
  final _locationService = const LocationService();

  String _filterKind = 'all'; // all | service | place | shop
  List<Listing> _allListings = [];
  Listing? _selectedListing;
  bool _isLoading = true;

  final double _userLat = Env.defaultLatitude;
  final double _userLng = Env.defaultLongitude;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    final list = await _repository.fetchNearbyListings(
      userLat: _userLat,
      userLng: _userLng,
    );

    if (mounted) {
      setState(() {
        _allListings = list;
        _selectedListing = list.isNotEmpty ? list.first : null;
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filteredListings {
    if (_filterKind == 'all') return _allListings;
    return _allListings.where((l) => l.kind == _filterKind).toList();
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
        title: const Text('Map & Radar'),
        actions: [
          IconButton(
            tooltip: 'View as List',
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              Navigator.pushNamed(
                context,
                ListingListView.route,
                arguments: {'title': 'Nearby Map Listings', 'kind': _filterKind == 'all' ? null : _filterKind},
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : Stack(
              children: [
                // Radar Map Canvas
                Positioned.fill(
                  child: _RadarMapCanvas(
                    userLat: _userLat,
                    userLng: _userLng,
                    listings: _filteredListings,
                    selectedListing: _selectedListing,
                    onListingSelected: (listing) {
                      setState(() => _selectedListing = listing);
                    },
                  ),
                ),

                // Top Filter Chips Bar
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterTab('all', 'All (${_allListings.length})', AppColors.inkLight),
                          const SizedBox(width: 6),
                          _buildFilterTab(
                            'service',
                            'Services (${_allListings.where((l) => l.isService).length})',
                            AppColors.teal,
                          ),
                          const SizedBox(width: 6),
                          _buildFilterTab(
                            'place',
                            'Places (${_allListings.where((l) => l.isPlace).length})',
                            AppColors.indigo,
                          ),
                          const SizedBox(width: 6),
                          _buildFilterTab(
                            'shop',
                            'Shops (${_allListings.where((l) => l.isShop).length})',
                            AppColors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating Bottom Selected Card
                if (_selectedListing != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(_selectedListing!.id),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListingCard(
                          listing: _selectedListing!,
                          distanceLabel: _getDistance(_selectedListing!),
                          onTap: () => _openDetail(_selectedListing!),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildFilterTab(String kind, String label, Color color) {
    final isSelected = _filterKind == kind;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterKind = kind;
          final filtered = _filteredListings;
          if (filtered.isNotEmpty && (filtered.contains(_selectedListing) != true)) {
            _selectedListing = filtered.first;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.inkLight,
          ),
        ),
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

/// Custom radar canvas rendering concentric range circles, user center pin,
/// and interactive listing marker pins with real offset calculations.
class _RadarMapCanvas extends StatelessWidget {
  final double userLat;
  final double userLng;
  final List<Listing> listings;
  final Listing? selectedListing;
  final ValueChanged<Listing> onListingSelected;

  const _RadarMapCanvas({
    required this.userLat,
    required this.userLng,
    required this.listings,
    required this.selectedListing,
    required this.onListingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size.width / 2, size.height / 2 - 30);
        const maxRadiusMeters = 3000.0;
        final canvasRadius = math.min(size.width, size.height) * 0.44;

        return Stack(
          children: [
            // Background Grid and Rings
            CustomPaint(
              size: size,
              painter: _RadarBackgroundPainter(center: center, canvasRadius: canvasRadius),
            ),

            // User Center Pin
            Positioned(
              left: center.dx - 16,
              top: center.dy - 16,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.myLocation.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.myLocation,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Listing Markers
            ...listings.map((l) {
              if (l.latitude == null || l.longitude == null) return const SizedBox.shrink();

              // Compute offset in meters
              final dLat = (l.latitude! - userLat) * 111000.0;
              final dLng = (l.longitude! - userLng) * (111000.0 * math.cos(userLat * math.pi / 180.0));

              // Map to canvas coordinates
              final scale = canvasRadius / maxRadiusMeters;
              final pinX = center.dx + (dLng * scale).clamp(-canvasRadius, canvasRadius);
              final pinY = center.dy - (dLat * scale).clamp(-canvasRadius, canvasRadius);

              final isSelected = selectedListing?.id == l.id;
              final pinColor = l.isService
                  ? AppColors.teal
                  : (l.isPlace ? AppColors.indigo : AppColors.amber);

              return Positioned(
                left: pinX - 18,
                top: pinY - 18,
                child: GestureDetector(
                  onTap: () => onListingSelected(l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 40 : 34,
                    height: isSelected ? 40 : 34,
                    decoration: BoxDecoration(
                      color: isSelected ? pinColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: pinColor,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: pinColor.withValues(alpha: 0.35),
                          blurRadius: isSelected ? 10 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getCategoryIcon(l.category),
                      size: isSelected ? 20 : 16,
                      color: isSelected ? Colors.white : pinColor,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('electric')) return Icons.bolt;
    if (cat.contains('plumb')) return Icons.build;
    if (cat.contains('hospital') || cat.contains('pharmacy')) return Icons.local_hospital;
    if (cat.contains('college')) return Icons.school;
    if (cat.contains('shop') || cat.contains('market')) return Icons.storefront;
    return Icons.place;
  }
}

class _RadarBackgroundPainter extends CustomPainter {
  final Offset center;
  final double canvasRadius;

  _RadarBackgroundPainter({required this.center, required this.canvasRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = AppColors.lineLight.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = const Color(0xFFF7FAFA)
      ..style = PaintingStyle.fill;

    // Outer radar fill
    canvas.drawCircle(center, canvasRadius, fillPaint);

    // Range rings (500m, 1km, 2km, 3km)
    canvas.drawCircle(center, canvasRadius * 0.25, ringPaint);
    canvas.drawCircle(center, canvasRadius * 0.5, ringPaint);
    canvas.drawCircle(center, canvasRadius * 0.75, ringPaint);
    canvas.drawCircle(center, canvasRadius, ringPaint);

    // Crosshairs
    final linePaint = Paint()
      ..color = AppColors.lineLight.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(center.dx - canvasRadius, center.dy), Offset(center.dx + canvasRadius, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, center.dy - canvasRadius), Offset(center.dx, center.dy + canvasRadius), linePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarBackgroundPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.canvasRadius != canvasRadius;
  }
}
