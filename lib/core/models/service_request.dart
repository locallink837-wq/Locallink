import '../constants/enums.dart';

/// Service request document (`requests/{id}`).
class ServiceRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhone; // Unlocked after provider acceptance
  final String? providerId; // null until accepted
  final String? providerName;
  final String category;
  final String description;
  final List<String> photoUrls;
  final dynamic location; // GeoPoint or lat/lng map
  final double? latitude;
  final double? longitude;
  final String address; // Text description of location
  final String urgency; // now | today | schedule | sos
  final String status; // searching | accepted | on_the_way | in_progress | done | cancelled | no_provider
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.customerName = '',
    this.customerPhone,
    this.providerId,
    this.providerName,
    required this.category,
    this.description = '',
    this.photoUrls = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.address = '',
    this.urgency = 'now',
    this.status = 'searching',
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  RequestStatus get parsedStatus => RequestStatus.fromBackendString(status);

  Urgency get parsedUrgency => enumFromName(Urgency.values, urgency, Urgency.now);

  bool get isCompleted => status == 'done';
  bool get isCancelled => status == 'cancelled';
  bool get isSearching => status == 'searching';
  bool get isAccepted => status == 'accepted' || status == 'on_the_way' || status == 'in_progress';

  factory ServiceRequest.fromMap(String id, Map<String, dynamic> m) {
    double? lat;
    double? lng;
    final rawLoc = m['location'];
    if (rawLoc != null) {
      if (rawLoc is Map) {
        lat = (rawLoc['lat'] ?? rawLoc['latitude']) as double?;
        lng = (rawLoc['lng'] ?? rawLoc['longitude']) as double?;
      } else {
        try {
          lat = (rawLoc.latitude as num?)?.toDouble();
          lng = (rawLoc.longitude as num?)?.toDouble();
        } catch (_) {}
      }
    }

    return ServiceRequest(
      id: id,
      customerId: (m['customerId'] ?? '') as String,
      customerName: (m['customerName'] ?? '') as String,
      customerPhone: m['customerPhone'] as String?,
      providerId: m['providerId'] as String?,
      providerName: m['providerName'] as String?,
      category: (m['category'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      photoUrls: List<String>.from(m['photoUrls'] ?? const []),
      location: rawLoc,
      latitude: lat ?? (m['latitude'] as num?)?.toDouble(),
      longitude: lng ?? (m['longitude'] as num?)?.toDouble(),
      address: (m['address'] ?? '') as String,
      urgency: (m['urgency'] ?? 'now') as String,
      status: (m['status'] ?? 'searching') as String,
      createdAt: m['createdAt'] != null
          ? (m['createdAt'] is DateTime
              ? m['createdAt'] as DateTime
              : DateTime.tryParse(m['createdAt'].toString()))
          : null,
      acceptedAt: m['acceptedAt'] != null
          ? (m['acceptedAt'] is DateTime
              ? m['acceptedAt'] as DateTime
              : DateTime.tryParse(m['acceptedAt'].toString()))
          : null,
      completedAt: m['completedAt'] != null
          ? (m['completedAt'] is DateTime
              ? m['completedAt'] as DateTime
              : DateTime.tryParse(m['completedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'customerName': customerName,
        if (customerPhone != null) 'customerPhone': customerPhone,
        if (providerId != null) 'providerId': providerId,
        if (providerName != null) 'providerName': providerName,
        'category': category,
        'description': description,
        'photoUrls': photoUrls,
        if (location != null) 'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'address': address,
        'urgency': urgency,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (acceptedAt != null) 'acceptedAt': acceptedAt!.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      };

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? providerId,
    String? providerName,
    String? category,
    String? description,
    List<String>? photoUrls,
    dynamic location,
    double? latitude,
    double? longitude,
    String? address,
    String? urgency,
    String? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      category: category ?? this.category,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
