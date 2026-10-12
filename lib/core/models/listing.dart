/// listings/{id}  (service provider, place or shop)
class Listing {
  final String id;
  final String kind; // service | place | shop
  final String name;
  final String category;
  final String phone;
  final String address;
  final String highlight;
  final List<String> tags;
  final dynamic location; // GeoPoint (kept dynamic so this file needs no Firebase import)
  final bool open24x7;
  final String? opensAt; // HH:mm
  final String? closesAt;
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
    this.highlight = '',
    this.tags = const [],
    this.location,
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

  double get averageRating => reviewCount == 0 ? 0 : ratingSum / reviewCount;

  factory Listing.fromMap(String id, Map<String, dynamic> m) => Listing(
        id: id,
        kind: (m['kind'] ?? 'shop') as String,
        name: (m['name'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        address: (m['address'] ?? '') as String,
        highlight: (m['highlight'] ?? '') as String,
        tags: List<String>.from(m['tags'] ?? const []),
        location: m['location'],
        open24x7: (m['open24x7'] ?? false) as bool,
        opensAt: m['opensAt'] as String?,
        closesAt: m['closesAt'] as String?,
        weeklyOff: List<int>.from(m['weeklyOff'] ?? const []),
        verified: (m['verified'] ?? false) as bool,
        status: (m['status'] ?? 'pending') as String,
        photoUrls: List<String>.from(m['photoUrls'] ?? const []),
        ratingSum: (m['ratingSum'] ?? 0) as num,
        reviewCount: (m['reviewCount'] ?? 0) as int,
        ownerId: (m['ownerId'] ?? '') as String,
      );
}
