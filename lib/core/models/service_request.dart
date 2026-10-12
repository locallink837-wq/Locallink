/// requests/{id}
class ServiceRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String? providerId; // null until a provider accepts
  final String category;
  final String description;
  final List<String> photoUrls;
  final dynamic location; // GeoPoint
  final String address; // rough text only
  final String urgency; // now | today | schedule | sos
  final String status; // searching | accepted | on_the_way | in_progress | done | cancelled | no_provider

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.customerName = '',
    this.providerId,
    required this.category,
    this.description = '',
    this.photoUrls = const [],
    this.location,
    this.address = '',
    this.urgency = 'now',
    this.status = 'searching',
  });

  factory ServiceRequest.fromMap(String id, Map<String, dynamic> m) => ServiceRequest(
        id: id,
        customerId: (m['customerId'] ?? '') as String,
        customerName: (m['customerName'] ?? '') as String,
        providerId: m['providerId'] as String?,
        category: (m['category'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        photoUrls: List<String>.from(m['photoUrls'] ?? const []),
        location: m['location'],
        address: (m['address'] ?? '') as String,
        urgency: (m['urgency'] ?? 'now') as String,
        status: (m['status'] ?? 'searching') as String,
      );
}
