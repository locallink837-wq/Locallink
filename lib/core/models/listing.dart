import '../constants/enums.dart';

/// Represents a Service, Place, or Shop in Firestore (`listings/{id}`).
class Listing {
  final String id;
  final String kind; // service | place | shop
  final String name;
  final String category;
  final String phone;
  final String address;
  final String city;
  final String highlight;
  final List<String> tags;
  final dynamic location; // GeoPoint or Map with lat/lng
  final double? latitude;
  final double? longitude;
  final bool open24x7;
  final String? opensAt; // HH:mm format, e.g. "09:00"
  final String? closesAt; // HH:mm format, e.g. "21:00"
  final List<int> weeklyOff; // 1 = Monday ... 7 = Sunday
  final bool verified;
  final String status; // pending | active | blocked
  final List<String> photoUrls;
  final num ratingSum;
  final int reviewCount;
  final String ownerId;

  const Listing({
    required this.id,
    required this.kind,
    required this.name,
    required this.category,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.highlight = '',
    this.tags = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.open24x7 = false,
    this.opensAt,
    this.closesAt,
    this.weeklyOff = const [],
    this.verified = false,
    this.status = 'pending',
    this.photoUrls = const [],
    this.ratingSum = 0,
    this.reviewCount = 0,
    this.ownerId = '',
  });

  bool get isActive => status == 'active';

  double get averageRating => reviewCount == 0 ? 0 : (ratingSum / reviewCount);

  ListingKind get parsedKind => enumFromName(ListingKind.values, kind, ListingKind.shop);

  bool get isService {
    final k = kind.toLowerCase().trim();
    return k == 'service' || k == 'services' || k == 'provider';
  }

  bool get isPlace {
    final k = kind.toLowerCase().trim();
    return k == 'place' || k == 'places';
  }

  bool get isShop {
    final k = kind.toLowerCase().trim();
    return k == 'shop' || k == 'shops' || k == 'vendor';
  }

  /// Determines whether this establishment is currently open based on local system time.
  bool get isOpenNow {
    if (open24x7) return true;
    final now = DateTime.now();
    if (weeklyOff.contains(now.weekday)) return false;
    if (opensAt == null || closesAt == null) return true;

    try {
      final openParts = opensAt!.split(':');
      final closeParts = closesAt!.split(':');
      final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
      final closeMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);
      final currentMinutes = now.hour * 60 + now.minute;

      if (closeMinutes >= openMinutes) {
        return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
      } else {
        // Crosses midnight, e.g., 18:00 to 02:00
        return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
      }
    } catch (_) {
      return true;
    }
  }

  factory Listing.fromMap(String id, Map<String, dynamic> m) {
    double? lat;
    double? lng;

    final rawLat = m['latitude'];
    final rawLng = m['longitude'];
    if (rawLat is num) lat = rawLat.toDouble();
    if (rawLng is num) lng = rawLng.toDouble();

    final rawLoc = m['location'];
    if (rawLoc != null) {
      if (rawLoc is Map) {
        final mLat = rawLoc['lat'] ?? rawLoc['latitude'];
        final mLng = rawLoc['lng'] ?? rawLoc['longitude'];
        if (mLat is num) lat ??= mLat.toDouble();
        if (mLng is num) lng ??= mLng.toDouble();
      } else {
        try {
          lat ??= (rawLoc.latitude as num?)?.toDouble();
          lng ??= (rawLoc.longitude as num?)?.toDouble();
        } catch (_) {}
      }
    }

    List<String> parseStringList(dynamic v) {
      if (v is List) {
        return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    List<int> parseIntList(dynamic v) {
      if (v is List) {
        return v
            .map((e) => e is num ? e.toInt() : int.tryParse(e?.toString() ?? ''))
            .whereType<int>()
            .toList();
      }
      return const [];
    }

    bool parseBool(dynamic v, {bool fallback = false}) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return fallback;
    }

    num parseNum(dynamic v, {num fallback = 0}) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? fallback;
      return fallback;
    }

    int parseInt(dynamic v, {int fallback = 0}) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    return Listing(
      id: id,
      kind: (m['kind'] ?? 'shop').toString(),
      name: (m['name'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString(),
      address: (m['address'] ?? '').toString(),
      city: (m['city'] ?? m['area'] ?? '').toString(),
      highlight: (m['highlight'] ?? '').toString(),
      tags: parseStringList(m['tags']),
      location: rawLoc,
      latitude: lat,
      longitude: lng,
      open24x7: parseBool(m['open24x7']),
      opensAt: m['opensAt']?.toString(),
      closesAt: m['closesAt']?.toString(),
      weeklyOff: parseIntList(m['weeklyOff']),
      verified: parseBool(m['verified'], fallback: true),
      status: (m['status'] ?? 'active').toString(),
      photoUrls: parseStringList(m['photoUrls']),
      ratingSum: parseNum(m['ratingSum']),
      reviewCount: parseInt(m['reviewCount']),
      ownerId: (m['ownerId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'kind': kind,
        'name': name,
        'category': category,
        'phone': phone,
        'address': address,
        'city': city,
        'isActive': isActive,
        'highlight': highlight,
        'tags': tags,
        if (location != null) 'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'open24x7': open24x7,
        'opensAt': opensAt,
        'closesAt': closesAt,
        'weeklyOff': weeklyOff,
        'verified': verified,
        'status': status,
        'photoUrls': photoUrls,
        'ratingSum': ratingSum,
        'reviewCount': reviewCount,
        'ownerId': ownerId,
      };

  Listing copyWith({
    String? id,
    String? kind,
    String? name,
    String? category,
    String? phone,
    String? address,
    String? highlight,
    List<String>? tags,
    dynamic location,
    double? latitude,
    double? longitude,
    bool? open24x7,
    String? opensAt,
    String? closesAt,
    List<int>? weeklyOff,
    bool? verified,
    String? status,
    List<String>? photoUrls,
    num? ratingSum,
    int? reviewCount,
    String? ownerId,
  }) {
    return Listing(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      highlight: highlight ?? this.highlight,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      open24x7: open24x7 ?? this.open24x7,
      opensAt: opensAt ?? this.opensAt,
      closesAt: closesAt ?? this.closesAt,
      weeklyOff: weeklyOff ?? this.weeklyOff,
      verified: verified ?? this.verified,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls,
      ratingSum: ratingSum ?? this.ratingSum,
      reviewCount: reviewCount ?? this.reviewCount,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
