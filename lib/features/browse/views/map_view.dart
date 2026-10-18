import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';
import 'listing_list_view.dart';
import 'place_detail_view.dart';
import 'provider_detail_view.dart';
import 'shop_detail_view.dart';

/// Real Interactive Google Maps Explorer
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
  final MapController _mapController = MapController();

  String _filterKind = 'all'; // all | service | place | shop
  List<Listing> _allListings = [];
  Listing? _selectedListing;
  bool _isLoading = true;
  int _mapStyleIndex = 0; // 0 = Default, 1 = Satellite, 2 = Terrain

  double _userLat = Env.defaultLatitude;
  double _userLng = Env.defaultLongitude;

  // Real Google Maps Tile Servers
  // lyrs=m: Standard Google Roadmap
  // lyrs=y: Google Hybrid Satellite (imagery + roads + labels)
  // lyrs=p: Google Terrain (contours + roads + labels)
  static const List<Map<String, dynamic>> _tileProviders = [
    {
      'name': 'Default',
      'subtitle': 'Google Roadmap',
      'icon': Icons.map_outlined,
      'url': 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
      'subdomains': ['0', '1', '2', '3'],
    },
    {
      'name': 'Satellite',
      'subtitle': 'Google Satellite Hybrid',
      'icon': Icons.satellite_alt_outlined,
      'url': 'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
      'subdomains': ['0', '1', '2', '3'],
    },
    {
      'name': 'Terrain',
      'subtitle': 'Google Topo Terrain',
      'icon': Icons.terrain_outlined,
      'url': 'https://mt{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
      'subdomains': ['0', '1', '2', '3'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);

    try {
      final pos = await _locationService.getCurrentPosition();
      _userLat = pos.latitude;
      _userLng = pos.longitude;
    } catch (_) {}

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
      _mapController.move(LatLng(_userLat, _userLng), 14.5);
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

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 19) {
      _mapController.move(_mapController.camera.center, currentZoom + 1);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 4) {
      _mapController.move(_mapController.camera.center, currentZoom - 1);
    }
  }

  void _recenterOnUser() {
    _mapController.move(LatLng(_userLat, _userLng), 15.5);
  }

  void _showLayerSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lineLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Map type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkLight,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tileProviders.length, (idx) {
                    final item = _tileProviders[idx];
                    final isSelected = _mapStyleIndex == idx;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _mapStyleIndex = idx);
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.teal.withValues(alpha: 0.12)
                                  : const Color(0xFFF1F5F5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.teal : AppColors.lineLight,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: 32,
                              color: isSelected ? AppColors.teal : AppColors.secondaryMuteLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.teal : AppColors.inkLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTile = _tileProviders[_mapStyleIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Explorer'),
        actions: [
          IconButton(
            tooltip: 'View as List',
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              Navigator.pushNamed(
                context,
                ListingListView.route,
                arguments: {
                  'title': 'Nearby Map Listings',
                  'kind': _filterKind == 'all' ? null : _filterKind,
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : Stack(
              children: [
                // Real Google Maps Engine
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_userLat, _userLng),
                    initialZoom: 14.5,
                    minZoom: 4,
                    maxZoom: 20,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: (_, _) {
                      setState(() => _selectedListing = null);
                    },
                  ),
                  children: [
                    // Official Google Maps Tiles
                    TileLayer(
                      key: ValueKey(activeTile['url']),
                      urlTemplate: activeTile['url'] as String,
                      subdomains: (activeTile['subdomains'] as List<String>),
                      userAgentPackageName: 'com.google.android.apps.maps',
                      maxZoom: 20,
                    ),

                    // User Location Accuracy Radius
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(_userLat, _userLng),
                          radius: 180,
                          useRadiusInMeter: true,
                          color: AppColors.myLocation.withValues(alpha: 0.12),
                          borderColor: AppColors.myLocation.withValues(alpha: 0.35),
                          borderStrokeWidth: 1.5,
                        ),
                      ],
                    ),

                    // Google Maps Markers
                    MarkerLayer(
                      markers: [
                        // Listings Pins
                        ..._filteredListings.map((listing) {
                          if (listing.latitude == null || listing.longitude == null) {
                            return null;
                          }
                          final isSelected = _selectedListing?.id == listing.id;

                          return Marker(
                            point: LatLng(listing.latitude!, listing.longitude!),
                            width: isSelected ? 48 : 36,
                            height: isSelected ? 56 : 44,
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedListing = listing);
                                _mapController.move(
                                  LatLng(listing.latitude!, listing.longitude!),
                                  16.0,
                                );
                              },
                              child: _buildGoogleStyleMarker(listing, isSelected),
                            ),
                          );
                        }).whereType<Marker>(),

                        // Current User Location Marker (Google Blue Dot)
                        Marker(
                          point: LatLng(_userLat, _userLng),
                          width: 32,
                          height: 32,
                          child: _buildUserLocationMarker(),
                        ),
                      ],
                    ),
                  ],
                ),

                // Top Category Filter Chips Bar
                Positioned(
                  top: 12,
                  left: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lineLight),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterTab(
                            'all',
                            'All (${_allListings.length})',
                            AppColors.inkLight,
                          ),
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

                // Right Google Maps Style Floating Action Controls
                Positioned(
                  right: 14,
                  bottom: _selectedListing != null ? 180 : 30,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Google Maps Layer Style Switcher
                      _buildFloatingBtn(
                        icon: Icons.layers_outlined,
                        tooltip: 'Layers (Map, Satellite, Terrain)',
                        onTap: _showLayerSelector,
                      ),
                      const SizedBox(height: 10),

                      // Re-center on My Location GPS Button
                      _buildFloatingBtn(
                        icon: Icons.my_location_rounded,
                        tooltip: 'Recenter on My Location',
                        iconColor: AppColors.myLocation,
                        onTap: _recenterOnUser,
                      ),
                      const SizedBox(height: 10),

                      // Zoom In (+)
                      _buildFloatingBtn(
                        icon: Icons.add_rounded,
                        tooltip: 'Zoom In',
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 4),

                      // Zoom Out (-)
                      _buildFloatingBtn(
                        icon: Icons.remove_rounded,
                        tooltip: 'Zoom Out',
                        onTap: _zoomOut,
                      ),
                    ],
                  ),
                ),

                // Google Attribution Logo (Bottom Left)
                Positioned(
                  left: 14,
                  bottom: _selectedListing != null ? 180 : 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Google',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5F6368),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),

                // Bottom Floating Selected Listing Card
                if (_selectedListing != null)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 20,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(_selectedListing!.id),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lineLight),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with Close Button
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _getKindColor(_selectedListing!).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(_selectedListing!.category),
                                    size: 18,
                                    color: _getKindColor(_selectedListing!),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _selectedListing!.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.inkLight,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (_selectedListing!.verified) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified, size: 14, color: AppColors.teal),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            _selectedListing!.category,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.muteLight,
                                            ),
                                          ),
                                          const Text(' • ', style: TextStyle(color: AppColors.lineLight)),
                                          Text(
                                            _getDistance(_selectedListing!),
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.teal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                OpenNowBadge(
                                  open24x7: _selectedListing!.open24x7,
                                  openNow: _selectedListing!.isOpenNow,
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: AppColors.muteLight),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => setState(() => _selectedListing = null),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Address row
                            Row(
                              children: [
                                const Icon(Icons.place_outlined, size: 14, color: AppColors.secondaryMuteLight),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _selectedListing!.address,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.secondaryMuteLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    label: 'View Details',
                                    color: _getKindColor(_selectedListing!),
                                    onPressed: () => _openDetail(_selectedListing!),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppOutlineButton(
                                    label: 'Directions',
                                    color: _getKindColor(_selectedListing!),
                                    icon: const Icon(Icons.directions, size: 16),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Directions to ${_selectedListing!.name} (${_getDistance(_selectedListing!)})',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildFloatingBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor ?? AppColors.inkLight),
          ),
        ),
      ),
    );
  }

  /// Authentic Google Maps Teardrop Pin Marker
  Widget _buildGoogleStyleMarker(Listing listing, bool isSelected) {
    final pinColor = _getKindColor(listing);

    return AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Drop Shadow below tip
          Positioned(
            bottom: 0,
            child: Container(
              width: 14,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: const BorderRadius.all(Radius.elliptical(14, 5)),
              ),
            ),
          ),
          // Pin Body
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isSelected ? 38 : 30,
                  height: isSelected ? 38 : 30,
                  decoration: BoxDecoration(
                    color: pinColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: isSelected ? 24 : 18,
                      height: isSelected ? 24 : 18,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(listing.category),
                        size: isSelected ? 14 : 11,
                        color: pinColor,
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  size: const Size(10, 6),
                  painter: _PinTipPainter(color: pinColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Google Maps Signature Blue Dot
  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.myLocation.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.myLocation,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getKindColor(Listing listing) {
    if (listing.isService) return AppColors.teal;
    if (listing.isPlace) return AppColors.indigo;
    return AppColors.amber;
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

class _PinTipPainter extends CustomPainter {
  final Color color;
  _PinTipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTipPainter oldDelegate) => oldDelegate.color != color;
}
