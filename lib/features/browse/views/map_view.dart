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

/// Real Interactive Google-Maps-Style Map Explorer
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
  int _mapStyleIndex = 0; // 0 = CartoDB Voyager (Google style), 1 = OSM Standard

  final double _userLat = Env.defaultLatitude;
  final double _userLng = Env.defaultLongitude;

  // Real world high quality street map tile layers
  static const List<Map<String, String>> _tileProviders = [
    {
      'name': 'Google Style',
      'url': 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    },
    {
      'name': 'OpenStreetMap',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
  ];

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

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18) {
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
    _mapController.move(LatLng(_userLat, _userLng), 15.0);
  }

  void _toggleMapStyle() {
    setState(() {
      _mapStyleIndex = (_mapStyleIndex + 1) % _tileProviders.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched map style to ${_tileProviders[_mapStyleIndex]['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Interactive Real Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_userLat, _userLng),
                    initialZoom: 14.5,
                    minZoom: 4,
                    maxZoom: 19,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: (_, _) {
                      setState(() => _selectedListing = null);
                    },
                  ),
                  children: [
                    // Street Map Tiles
                    TileLayer(
                      urlTemplate: _tileProviders[_mapStyleIndex]['url']!,
                      userAgentPackageName: 'com.localink.app',
                      maxZoom: 19,
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

                    // Google Maps Style Markers
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
                            width: isSelected ? 48 : 38,
                            height: isSelected ? 56 : 46,
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedListing = listing);
                                _mapController.move(
                                  LatLng(listing.latitude!, listing.longitude!),
                                  15.5,
                                );
                              },
                              child: _buildGoogleStyleMarker(listing, isSelected),
                            ),
                          );
                        }).whereType<Marker>(),

                        // Current User Location Marker
                        Marker(
                          point: LatLng(_userLat, _userLng),
                          width: 30,
                          height: 30,
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
                      // Map Layer Style Switcher
                      _buildFloatingBtn(
                        icon: Icons.layers_outlined,
                        tooltip: 'Switch Map Style',
                        onTap: _toggleMapStyle,
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

  Widget _buildGoogleStyleMarker(Listing listing, bool isSelected) {
    final pinColor = _getKindColor(listing);

    return AnimatedScale(
      scale: isSelected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
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
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(listing.category),
                size: isSelected ? 18 : 14,
                color: Colors.white,
              ),
            ),
          ),
          CustomPaint(
            size: const Size(10, 6),
            painter: _PinTipPainter(color: pinColor),
          ),
        ],
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.myLocation.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
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
