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
    try {
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
    } catch (_) {
      return {};
    }
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

  // In-memory dynamic listings cache: bridges new providers registered in the current session
  static final List<Listing> _dynamicCustomListings = [];

  static void registerCustomListing(Listing listing) {
    _dynamicCustomListings.removeWhere((l) => l.id == listing.id);
    _dynamicCustomListings.insert(0, listing);
  }

  static List<Listing> get dynamicCustomListings => List.unmodifiable(_dynamicCustomListings);

  static Listing? fetchListingByIdSync(String id) {
    for (final l in _dynamicCustomListings) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Fetch active Firestore listings; seamlessly merges demo listings and any newly registered providers.
  Future<List<Listing>> fetchListings({
    String? kind,
    String? category,
    bool? verifiedOnly,
    bool? openNowOnly,
    int limit = 50,
  }) async {
    List<Listing> results = [];
    final firestore = _firestore;

    if (firestore != null) {
      try {
        Query<Map<String, dynamic>> query = firestore.collection(FsPaths.listings);

        if (kind != null && kind.isNotEmpty) {
          query = query.where('kind', isEqualTo: kind);
        }
        if (verifiedOnly == true) {
          query = query.where('verified', isEqualTo: true);
        }

        final snapshot = await query.limit(limit).get();
        results = snapshot.docs
            .map((doc) => Listing.fromMap(doc.id, doc.data()))
            .where((l) => l.status != 'blocked')
            .toList();
      } catch (e) {
        debugPrint('Firestore fetchListings error: $e');
        try {
          final rawSnap = await firestore.collection(FsPaths.listings).limit(limit).get();
          results = rawSnap.docs
              .map((doc) => Listing.fromMap(doc.id, doc.data()))
              .where((l) => (kind == null || l.kind == kind) && l.status != 'blocked')
              .toList();
        } catch (_) {}
      }
    }

    // Merge in-memory dynamic custom listings (created by provider in this session)
    final allListingsMap = <String, Listing>{};
    // 1. Add Firestore listings
    for (final l in results) {
      allListingsMap[l.id] = l;
    }
    // 2. Add dynamic custom registered listings (highest precedence)
    for (final l in _dynamicCustomListings) {
      allListingsMap[l.id] = l;
    }

    var list = allListingsMap.values.toList();

    // Filter by kind
    if (kind != null && kind.isNotEmpty) {
      list = list.where((l) => l.kind == kind).toList();
    }

    // Filter by category (case-insensitive, matching either category OR tags)
    if (category != null && category.isNotEmpty && category != 'All') {
      final catLower = category.toLowerCase();
      list = list.where((l) {
        final matchCat = l.category.toLowerCase().contains(catLower);
        final matchTags = l.tags.any((t) => t.toLowerCase().contains(catLower));
        return matchCat || matchTags;
      }).toList();
    }

    if (verifiedOnly == true) {
      list = list.where((l) => l.verified).toList();
    }
    if (openNowOnly == true) {
      list = list.where((l) => l.isOpenNow).toList();
    }

    return list;
  }

  /// Real-time stream of listings from Firestore
  Stream<List<Listing>> streamListings({
    String? kind,
    String? category,
    int limit = 50,
  }) async* {
    final firestore = _firestore;
    if (firestore == null) {
      yield _filterMockListings(kind, category);
      return;
    }

    try {
      Query<Map<String, dynamic>> query = firestore.collection(FsPaths.listings);
      query = query.where('status', isEqualTo: 'active');
      if (kind != null && kind.isNotEmpty) {
        query = query.where('kind', isEqualTo: kind);
      }

      await for (final snapshot in query.limit(limit).snapshots()) {
        final listMap = <String, Listing>{};
        for (final doc in snapshot.docs) {
          final l = Listing.fromMap(doc.id, doc.data());
          listMap[l.id] = l;
        }
        for (final l in _dynamicCustomListings) {
          listMap[l.id] = l;
        }
        var list = listMap.values.toList();
        if (kind != null && kind.isNotEmpty) {
          list = list.where((l) => l.kind == kind).toList();
        }
        if (category != null && category.isNotEmpty && category != 'All') {
          final catLower = category.toLowerCase();
          list = list.where((l) {
            final matchCat = l.category.toLowerCase().contains(catLower);
            final matchTags = l.tags.any((t) => t.toLowerCase().contains(catLower));
            return matchCat || matchTags;
          }).toList();
        }
        yield list;
      }
    } catch (e) {
      debugPrint('Stream listings error: $e');
      yield _filterMockListings(kind, category);
    }
  }

  List<Listing> _filterMockListings(
    String? kind,
    String? category, {
    bool? verifiedOnly,
    bool? openNowOnly,
  }) {
    final allListingsMap = <String, Listing>{};
    for (final l in _dynamicCustomListings) {
      allListingsMap[l.id] = l;
    }

    var list = allListingsMap.values.toList();
    if (kind != null && kind.isNotEmpty) {
      list = list.where((l) => l.kind == kind).toList();
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      final catLower = category.toLowerCase();
      list = list
          .where(
            (l) =>
                l.category.toLowerCase().contains(catLower) ||
                l.tags.any((t) => t.toLowerCase().contains(catLower)),
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
    // 1. Check in-memory custom listings first
    for (final l in _dynamicCustomListings) {
      if (l.id == id) return l;
    }

    final firestore = _firestore;
    if (firestore != null) {
      try {
        final doc = await firestore.collection(FsPaths.listings).doc(id).get();
        if (doc.exists && doc.data() != null) {
          final listing = Listing.fromMap(doc.id, doc.data()!);
          if (listing.status == 'active') {
            return listing;
          }
        }
      } catch (e) {
        debugPrint('Firestore fetchListingById error: $e');
      }
    }

    return null;
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

  /// Fetch nearby listings sorted by distance with verified listings prioritized.
  /// Strictly filters to listings within [maxRadiusMeters] (default 50km) when nearby results exist.
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

  // Real Firestore dataset is used; no hardcoded dummy city data
  static final List<Listing> demoListings = const [];
}
