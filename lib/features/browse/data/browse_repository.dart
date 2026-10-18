import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/listing.dart';
import '../../../core/models/review.dart';
import '../../../core/services/location_service.dart';

/// Module 2 - Browse (home, lists, detail, map)
/// ALL Firestore / Supabase calls for this feature go here (screens never call Firebase directly).
/// Collection names come from core/constants/firestore_paths.dart.
class BrowseRepository {
  final FirebaseFirestore? _customFirestore;
  final LocationService _locationService;

  BrowseRepository({
    FirebaseFirestore? firestore,
    LocationService? locationService,
  }) : _customFirestore = firestore,
       _locationService = locationService ?? const LocationService();

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  bool get _isRealUser {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user != null && !user.isAnonymous;
    } catch (_) {
      return false;
    }
  }

  String? get _currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  bool get hasRealUser => _isRealUser;
  String? get currentAccountId => _isRealUser ? _currentUserId : null;

  Future<Set<String>> fetchSavedListingIds() async {
    if (!_isRealUser) return {};
    final firestore = _firestore;
    final userId = _currentUserId;
    if (firestore == null || userId == null) return {};

    final snapshot = await firestore
        .collection(FsPaths.users)
        .doc(userId)
        .get();
    final values = snapshot.data()?['savedListingIds'];
    return values is Iterable
        ? Set<String>.from(values.whereType<String>())
        : {};
  }

  Future<void> saveListingIds(Iterable<String> ids) async {
    if (!_isRealUser) {
      throw StateError('Sign in to save places to your account.');
    }
    final firestore = _firestore;
    final userId = _currentUserId;
    if (firestore == null || userId == null) {
      throw StateError('Saved places are unavailable right now.');
    }

    await firestore.collection(FsPaths.users).doc(userId).update({
      'savedListingIds': ids.toList(),
    });
  }

  // In-memory fallback reviews cache so newly added reviews appear immediately in mock mode
  static final Map<String, List<Review>> _fallbackReviewsCache = {};

  /// Fetch active Firestore listings; use demo data only when Firebase is unavailable in debug mode.
  Future<List<Listing>> fetchListings({
    String? kind,
    String? category,
    bool? verifiedOnly,
    bool? openNowOnly,
    int limit = 50,
  }) async {
    final firestore = _firestore;
    if (firestore != null) {
      if (!_isRealUser && kind == 'service') return [];
      try {
        Query query = firestore.collection(FsPaths.listings);
        query = query.where('status', isEqualTo: 'active');

        if (kind != null && kind.isNotEmpty) {
          query = query.where('kind', isEqualTo: kind);
        } else if (!_isRealUser) {
          query = query.where('kind', whereIn: const ['place', 'shop']);
        }
        if (category != null && category.isNotEmpty) {
          query = query.where('category', isEqualTo: category);
        }
        if (verifiedOnly == true) {
          query = query.where('verified', isEqualTo: true);
        }

        final snapshot = await query.limit(limit).get();
        var results = snapshot.docs.map((doc) {
          return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        if (openNowOnly == true) {
          results = results.where((l) => l.isOpenNow).toList();
        }
        return results;
      } catch (e) {
        debugPrint('Firestore fetchListings error: $e');
        return [];
      }
    }

    return kDebugMode
        ? _filterMockListings(
            kind,
            category,
            verifiedOnly: verifiedOnly,
            openNowOnly: openNowOnly,
          )
        : [];
  }

  /// Real-time stream of listings from Firestore
  Stream<List<Listing>> streamListings({
    String? kind,
    String? category,
    int limit = 50,
  }) async* {
    final firestore = _firestore;
    if (firestore == null) {
      yield kDebugMode ? _filterMockListings(kind, category) : [];
      return;
    }
    if (!_isRealUser && kind == 'service') {
      yield [];
      return;
    }

    try {
      Query query = firestore.collection(FsPaths.listings);
      query = query.where('status', isEqualTo: 'active');
      if (kind != null && kind.isNotEmpty) {
        query = query.where('kind', isEqualTo: kind);
      } else if (!_isRealUser) {
        query = query.where('kind', whereIn: const ['place', 'shop']);
      }
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      await for (final snapshot in query.limit(limit).snapshots()) {
        yield snapshot.docs.map((doc) {
          return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
      }
    } catch (e) {
      debugPrint('Stream listings error: $e');
      yield [];
    }
  }

  List<Listing> _filterMockListings(
    String? kind,
    String? category, {
    bool? verifiedOnly,
    bool? openNowOnly,
  }) {
    if (!_isRealUser && kind == 'service') return [];
    var list = List<Listing>.from(demoListings);
    if (!_isRealUser && kind == null) {
      list = list.where((l) => l.isPlace || l.isShop).toList();
    }
    if (kind != null && kind.isNotEmpty) {
      list = list.where((l) => l.kind == kind).toList();
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      list = list
          .where(
            (l) => l.category.toLowerCase().contains(category.toLowerCase()),
          )
          .toList();
    }
    if (verifiedOnly == true) {
      list = list.where((l) => l.verified).toList();
    }
    if (openNowOnly == true) {
      list = list.where((l) => l.isOpenNow).toList();
    }
    return list;
  }

  /// Fetch a single listing by its document ID
  Future<Listing?> fetchListingById(String id) async {
    final firestore = _firestore;
    if (firestore != null) {
      if (!_isRealUser &&
          demoListings.any(
            (listing) => listing.id == id && listing.isService,
          )) {
        return null;
      }
      try {
        final doc = await firestore.collection(FsPaths.listings).doc(id).get();
        if (doc.exists && doc.data() != null) {
          final listing = Listing.fromMap(doc.id, doc.data()!);
          if (listing.status == 'active' &&
              (_isRealUser || !listing.isService)) {
            return listing;
          }
        }
      } catch (e) {
        debugPrint('Firestore fetchListingById error: $e');
        return null;
      }
      return null;
    }

    if (!kDebugMode) return null;
    return demoListings.cast<Listing?>().firstWhere(
      (listing) => listing?.id == id && (_isRealUser || !listing!.isService),
      orElse: () => null,
    );
  }

  /// Search listings across name, category, highlight, address, and tags
  Future<List<Listing>> searchListings(
    String query, {
    String? kind,
    String? category,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    final allListings = await fetchListings(kind: kind, category: category);

    if (cleanQuery.isEmpty) return allListings;

    return allListings.where((l) {
      final matchName = l.name.toLowerCase().contains(cleanQuery);
      final matchCat = l.category.toLowerCase().contains(cleanQuery);
      final matchAddr = l.address.toLowerCase().contains(cleanQuery);
      final matchHighlight = l.highlight.toLowerCase().contains(cleanQuery);
      final matchTags = l.tags.any((t) => t.toLowerCase().contains(cleanQuery));
      return matchName || matchCat || matchAddr || matchHighlight || matchTags;
    }).toList();
  }

  /// Fetch nearby listings sorted by distance with verified listings prioritized
  Future<List<Listing>> fetchNearbyListings({
    required double userLat,
    required double userLng,
    String? kind,
  }) async {
    final listings = await fetchListings(kind: kind);
    return _locationService.sortByDistanceAndVerified(
      listings: listings,
      userLat: userLat,
      userLng: userLng,
    );
  }

  /// Fetch reviews for a specific listing from `listings/{id}/reviews`
  Future<List<Review>> fetchReviews(String listingId) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final snapshot = await firestore
            .collection(FsPaths.listingReviews(listingId))
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs
            .map((doc) => Review.fromMap(doc.id, doc.data()))
            .toList();
      } catch (e) {
        debugPrint('Firestore fetchReviews error: $e');
        return [];
      }
    }

    // Return cached/demo reviews
    if (_fallbackReviewsCache.containsKey(listingId)) {
      return _fallbackReviewsCache[listingId]!;
    }
    return kDebugMode ? _getDemoReviewsFor(listingId) : [];
  }

  /// Stream reviews for real-time updates
  Stream<List<Review>> streamReviews(String listingId) async* {
    final firestore = _firestore;
    if (firestore == null) {
      yield kDebugMode
          ? (_fallbackReviewsCache[listingId] ?? _getDemoReviewsFor(listingId))
          : [];
      return;
    }

    try {
      await for (final snapshot
          in firestore
              .collection(FsPaths.listingReviews(listingId))
              .orderBy('createdAt', descending: true)
              .snapshots()) {
        yield snapshot.docs
            .map((doc) => Review.fromMap(doc.id, doc.data()))
            .toList();
      }
    } catch (e) {
      debugPrint('Stream reviews error: $e');
      yield [];
    }
  }

  /// Add a review to `listings/{id}/reviews`.
  Future<void> addReview({
    required String listingId,
    required double rating,
    required String comment,
    required String authorName,
  }) async {
    final firestore = _firestore;
    if (firestore != null && !_isRealUser) {
      throw StateError('Sign in to submit a review.');
    }
    if (firestore == null && !kDebugMode) {
      throw StateError(
        'Reviews are unavailable right now. Please try again later.',
      );
    }

    final newReview = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      authorId: _currentUserId ?? 'local-user',
      authorName: authorName.isEmpty ? 'Local Resident' : authorName,
      rating: rating.roundToDouble(),
      comment: comment,
      createdAt: DateTime.now(),
    );

    if (firestore == null) {
      _cacheReview(newReview);
      return;
    }

    final reviewerId = _currentUserId!;
    try {
      await firestore
          .collection(FsPaths.listingReviews(listingId))
          .doc(reviewerId)
          .set(newReview.toMap());
      _cacheReview(newReview);
    } catch (e) {
      debugPrint('Firestore addReview error: $e');
      rethrow;
    }
  }

  void _cacheReview(Review review) {
    final list =
        _fallbackReviewsCache[review.listingId] ??
        List<Review>.from(_getDemoReviewsFor(review.listingId));
    list.removeWhere((cached) => cached.authorId == review.authorId);
    list.insert(0, review);
    _fallbackReviewsCache[review.listingId] = list;
  }

  /// Submit a user report for wrong listing information to `reports` collection
  Future<void> reportWrongInfo({
    required String listingId,
    required String listingName,
    required String reason,
    required String notes,
    String? reporterId,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError(
        'Reports are unavailable right now. Please try again later.',
      );
    }

    final reportData = {
      'listingId': listingId,
      'listingName': listingName,
      'reason': reason,
      'notes': notes,
      'reporterId': _currentUserId ?? reporterId ?? 'anonymous',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    try {
      await firestore.collection(FsPaths.reports).add(reportData);
    } catch (e) {
      debugPrint('Firestore reportWrongInfo error: $e');
      rethrow;
    }
  }

  /// Fetch full listings for a set of saved IDs
  Future<List<Listing>> fetchSavedListings(Iterable<String> ids) async {
    if (ids.isEmpty) return [];
    final firestore = _firestore;
    if (firestore != null && _isRealUser) {
      final results = <Listing>[];
      final snapshots = await Future.wait(
        ids.map((id) async {
          try {
            return await firestore.collection(FsPaths.listings).doc(id).get();
          } catch (e) {
            debugPrint('Firestore saved listing fetch error for $id: $e');
            return null;
          }
        }),
      );
      for (final snapshot in snapshots) {
        final data = snapshot?.data();
        if (snapshot?.exists == true &&
            data != null &&
            data['status'] == 'active') {
          results.add(Listing.fromMap(snapshot!.id, data));
        }
      }
      return results;
    }

    final all = await fetchListings();
    return all.where((listing) => ids.contains(listing.id)).toList();
  }

  List<Review> _getDemoReviewsFor(String listingId) {
    return [
      Review(
        id: 'rev-1',
        listingId: listingId,
        authorId: 'usr-1',
        authorName: 'Rohan Deshmukh',
        rating: 5.0,
        comment: 'Very prompt and courteous service. Arrived on time and solved the issue quickly.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'rev-2',
        listingId: listingId,
        authorId: 'usr-2',
        authorName: 'Priya Kulkarni',
        rating: 4.5,
        comment: 'Clean work and transparent pricing. Highly recommended for everyone in the area.',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Review(
        id: 'rev-3',
        listingId: listingId,
        authorId: 'usr-3',
        authorName: 'Amit Joshi',
        rating: 4.0,
        comment: 'Good experience overall. Would definitely use again.',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ];
  }

  // -------------------------------------------------------------
  // Comprehensive, realistic demo dataset for Pune/Shivajinagar
  // -------------------------------------------------------------
  static final List<Listing> demoListings = [
    // 1. Services (Teal)
    const Listing(
      id: 'serv-1',
      kind: 'service',
      name: 'Shinde Electricals & Wiring',
      category: 'Electrician',
      phone: '+91 98220 12345',
      address: 'FC Road, Shivajinagar, Pune',
      highlight: 'Licensed Wireman • 8+ Years Experience',
      tags: [
        'House Wiring',
        'Fan & Geyser Repair',
        'Emergency Callout',
        'Switchboard Fixing',
      ],
      latitude: 18.5246,
      longitude: 73.8425,
      open24x7: false,
      opensAt: '08:00',
      closesAt: '21:00',
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 163.2,
      reviewCount: 34,
      ownerId: 'p-1',
    ),
    const Listing(
      id: 'serv-2',
      kind: 'service',
      name: 'Pawar Plumbing & Sanitary Services',
      category: 'Plumber',
      phone: '+91 98221 23456',
      address: 'JM Road, Deccan Gymkhana, Pune',
      highlight: '24x7 Emergency Leaks • Fast Arrival',
      tags: [
        'Pipe Leakage',
        'Tap Repair',
        'Motor Installation',
        'Bathroom Fitting',
      ],
      latitude: 18.5196,
      longitude: 73.8430,
      open24x7: true,
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 128.8,
      reviewCount: 28,
      ownerId: 'p-2',
    ),
    const Listing(
      id: 'serv-3',
      kind: 'service',
      name: 'CoolCare AC & Refrigerator Repair',
      category: 'Appliance',
      phone: '+91 98222 34567',
      address: 'Model Colony, Pune',
      highlight: 'Same Day Service • 90 Days Warranty',
      tags: ['AC Servicing', 'Gas Refill', 'Fridge Repair', 'Washing Machine'],
      latitude: 18.5332,
      longitude: 73.8375,
      open24x7: false,
      opensAt: '09:00',
      closesAt: '20:00',
      weeklyOff: [7], // Sunday off
      verified: true,
      status: 'active',
      ratingSum: 230.3,
      reviewCount: 47,
      ownerId: 'p-3',
    ),
    const Listing(
      id: 'serv-4',
      kind: 'service',
      name: 'Sparkle Clean Home & Sofa Deep Cleaning',
      category: 'Cleaning',
      phone: '+91 98223 45678',
      address: 'Senapati Bapat Road, Pune',
      highlight: 'Eco-friendly Chemicals • Trained Staff',
      tags: [
        'Deep Cleaning',
        'Sofa Shampooing',
        'Kitchen Degreasing',
        'Bathroom Cleaning',
      ],
      latitude: 18.5350,
      longitude: 73.8295,
      open24x7: false,
      opensAt: '08:30',
      closesAt: '19:30',
      weeklyOff: [],
      verified: false,
      status: 'active',
      ratingSum: 89.3,
      reviewCount: 19,
      ownerId: 'p-4',
    ),
    const Listing(
      id: 'serv-5',
      kind: 'service',
      name: 'Jadhav Wood Works & Furniture Repair',
      category: 'Carpenter',
      phone: '+91 98224 56789',
      address: 'Ghole Road, Shivajinagar, Pune',
      highlight: 'Custom Furniture & Quick Hinge Fixes',
      tags: [
        'Door Lock Fitting',
        'Furniture Repair',
        'Custom Cabinets',
        'Bed Assembly',
      ],
      latitude: 18.5280,
      longitude: 73.8460,
      open24x7: false,
      opensAt: '09:30',
      closesAt: '20:30',
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 67.5,
      reviewCount: 15,
      ownerId: 'p-5',
    ),
    const Listing(
      id: 'serv-6',
      kind: 'service',
      name: 'QuickLock 24x7 Emergency Locksmith',
      category: 'Locksmith',
      phone: '+91 98225 67890',
      address: 'Camp, MG Road, Pune',
      highlight: 'Car & Home Lockout Specialist',
      tags: [
        '24x7 Key Maker',
        'Door Unlocking',
        'Car Key Duplicate',
        'Digital Lock Setup',
      ],
      latitude: 18.5170,
      longitude: 73.8780,
      open24x7: true,
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 254.8,
      reviewCount: 52,
      ownerId: 'p-6',
    ),

    // 2. Places (Indigo)
    const Listing(
      id: 'place-1',
      kind: 'place',
      name: 'Sassoon General Hospital & Trauma Centre',
      category: 'Hospital',
      phone: '020 2612 8000',
      address: 'Near Pune Railway Station, Pune',
      highlight: '24x7 Emergency • Trauma ICU • Blood Bank',
      tags: [
        'Trauma ICU',
        '24x7 Emergency',
        'Government Hospital',
        'Blood Bank',
        'Free OPD',
      ],
      latitude: 18.5262,
      longitude: 73.8742,
      open24x7: true,
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 540.0,
      reviewCount: 120,
      ownerId: 'gov-1',
    ),
    const Listing(
      id: 'place-2',
      kind: 'place',
      name: 'Fergusson College Campus & Library',
      category: 'College',
      phone: '020 6765 6000',
      address: 'FC Road, Shivajinagar, Pune',
      highlight: 'Heritage Campus founded in 1885',
      tags: [
        'Historic Campus',
        'Amphitheatre',
        'Botanical Garden',
        'Central Library',
      ],
      latitude: 18.5236,
      longitude: 73.8412,
      open24x7: false,
      opensAt: '07:00',
      closesAt: '19:00',
      weeklyOff: [7], // Sunday closed
      verified: true,
      status: 'active',
      ratingSum: 1519.0,
      reviewCount: 310,
      ownerId: 'edu-1',
    ),
    const Listing(
      id: 'place-3',
      kind: 'place',
      name: 'Pune Junction Railway Station',
      category: 'Transport',
      phone: '139',
      address: 'Agarkar Nagar, Pune',
      highlight: 'Major Rail Terminal • Metro Connected',
      tags: [
        'Metro Connected',
        'Cloak Room',
        '24x7 Food Court',
        'Prepaid Taxi Stand',
      ],
      latitude: 18.5284,
      longitude: 73.8743,
      open24x7: true,
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 1935.0,
      reviewCount: 450,
      ownerId: 'rail-1',
    ),
    const Listing(
      id: 'place-4',
      kind: 'place',
      name: 'Shivajinagar Police Station',
      category: 'Police',
      phone: '020 2553 6263',
      address: 'Near Simla Office, Shivajinagar, Pune',
      highlight: '24x7 Public Assistance & Women Safety Cell',
      tags: ['24x7 Help Desk', 'Women Safety Cell', 'Emergency Dispatch'],
      latitude: 18.5308,
      longitude: 73.8502,
      open24x7: true,
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 167.2,
      reviewCount: 38,
      ownerId: 'pol-1',
    ),
    const Listing(
      id: 'place-5',
      kind: 'place',
      name: 'Saras Baug & Peshwe Park',
      category: 'Park',
      phone: '',
      address: 'Sadashiv Peth, Pune',
      highlight: 'Famous Talyatla Ganpati Temple & Lush Garden',
      tags: [
        'Ganpati Temple',
        'Jogging Track',
        'Lake Garden',
        'Street Food Stalls',
      ],
      latitude: 18.5020,
      longitude: 73.8540,
      open24x7: false,
      opensAt: '06:00',
      closesAt: '21:00',
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 987.0,
      reviewCount: 210,
      ownerId: 'pmc-1',
    ),
    const Listing(
      id: 'place-6',
      kind: 'place',
      name: 'State Bank of India Main Branch & ATM',
      category: 'Bank & ATM',
      phone: '1800 1234',
      address: 'Deccan Gymkhana, Pune',
      highlight: '24x7 Cash Deposit Machine & Locker Facility',
      tags: [
        '24x7 Cash Deposit Machine',
        'Currency Exchange',
        'Wheelchair Access',
      ],
      latitude: 18.5175,
      longitude: 73.8415,
      open24x7: true,
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 357.0,
      reviewCount: 85,
      ownerId: 'sbi-1',
    ),

    // 3. Shops (Amber)
    const Listing(
      id: 'shop-1',
      kind: 'shop',
      name: 'Apollo Pharmacy & 24x7 Meds',
      category: 'Pharmacy',
      phone: '+91 20 2567 1122',
      address: 'FC Road, Near Goodluck Cafe, Pune',
      highlight: '24x7 Open • Free Home Delivery for Rx',
      tags: [
        '24x7 Open',
        'Home Delivery',
        'Generic Medicines',
        'Surgical Items',
      ],
      latitude: 18.5220,
      longitude: 73.8405,
      open24x7: true,
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 427.2,
      reviewCount: 89,
      ownerId: 's-1',
    ),
    const Listing(
      id: 'shop-2',
      kind: 'shop',
      name: 'Chitale Bandhu Mithaiwale',
      category: 'Bakery & Sweets',
      phone: '+91 20 2447 3297',
      address: 'Bajirao Road, Sadashiv Peth, Pune',
      highlight: 'Legendary Pune Bakarwadi & Mango Barfi',
      tags: ['Bakarwadi', 'Mango Barfi', 'Fresh Dairy', 'Famous Pune Special'],
      latitude: 18.5135,
      longitude: 73.8520,
      open24x7: false,
      opensAt: '08:30',
      closesAt: '20:30',
      weeklyOff: [1], // Monday closed
      verified: true,
      status: 'active',
      ratingSum: 2058.0,
      reviewCount: 420,
      ownerId: 's-2',
    ),
    const Listing(
      id: 'shop-3',
      kind: 'shop',
      name: 'Dorabjee\'s Supermarket',
      category: 'Grocery',
      phone: '+91 20 2614 0000',
      address: 'Moledina Road, Camp, Pune',
      highlight: 'Premium Gourmet & Everyday Grocery',
      tags: [
        'Imported Goods',
        'Organic Produce',
        'Fresh Bakery',
        'UPI & Cards',
      ],
      latitude: 18.5185,
      longitude: 73.8805,
      open24x7: false,
      opensAt: '09:00',
      closesAt: '22:00',
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 916.5,
      reviewCount: 195,
      ownerId: 's-3',
    ),
    const Listing(
      id: 'shop-4',
      kind: 'shop',
      name: 'Venus Traders Art & Stationery',
      category: 'Stationery',
      phone: '+91 20 2553 4567',
      address: 'FC Road, Opposite Modern High School, Pune',
      highlight: 'Pune\'s Premier Art, Architecture & Office Supplies',
      tags: [
        'Art Supplies',
        'Office Stationery',
        'Architecture Paper',
        'Book Binding',
      ],
      latitude: 18.5270,
      longitude: 73.8440,
      open24x7: false,
      opensAt: '10:00',
      closesAt: '20:30',
      weeklyOff: [7], // Sunday closed
      verified: true,
      status: 'active',
      ratingSum: 537.6,
      reviewCount: 112,
      ownerId: 's-4',
    ),
    const Listing(
      id: 'shop-5',
      kind: 'shop',
      name: 'Vijay Sales Electronics & Mobile',
      category: 'Electronics',
      phone: '+91 20 2551 2233',
      address: 'JM Road, Shivajinagar, Pune',
      highlight: 'Authorized Dealer • Genuine Warranty',
      tags: ['Smartphones', 'Laptops', 'AC & TVs', 'Instant EMI'],
      latitude: 18.5240,
      longitude: 73.8470,
      open24x7: false,
      opensAt: '10:30',
      closesAt: '21:30',
      weeklyOff: [],
      verified: true,
      status: 'active',
      ratingSum: 644.0,
      reviewCount: 140,
      ownerId: 's-5',
    ),
    const Listing(
      id: 'shop-6',
      kind: 'shop',
      name: 'Bharat Hardware & Sanitary Supplies',
      category: 'Hardware',
      phone: '+91 20 2445 6789',
      address: 'Raviwar Peth, Pune',
      highlight: 'Wholesale & Retail Hardware & Paints',
      tags: [
        'Plumbing Pipes',
        'Power Tools',
        'Paints & Adhesives',
        'Wholesale & Retail',
      ],
      latitude: 18.5180,
      longitude: 73.8590,
      open24x7: false,
      opensAt: '09:00',
      closesAt: '20:00',
      weeklyOff: [7], // Sunday closed
      verified: true,
      status: 'active',
      ratingSum: 288.0,
      reviewCount: 64,
      ownerId: 's-6',
    ),
  ];
}
