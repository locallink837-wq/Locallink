/// leads/{requestId_providerId}
class Lead {
  final String id;
  final String requestId;
  final String providerId;
  final String category;
  final String summary;
  final String areaLabel; // rough, no phone
  final num distanceM;
  final int fee; // credits
  final String status; // new | viewed | accepted | declined | expired

  const Lead({
    required this.id,
    required this.requestId,
    required this.providerId,
    this.category = '',
    this.summary = '',
    this.areaLabel = '',
    this.distanceM = 0,
    this.fee = 0,
    this.status = 'new',
  });

  factory Lead.fromMap(String id, Map<String, dynamic> m) => Lead(
        id: id,
        requestId: (m['requestId'] ?? '') as String,
        providerId: (m['providerId'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        summary: (m['summary'] ?? '') as String,
        areaLabel: (m['areaLabel'] ?? '') as String,
        distanceM: (m['distanceM'] ?? 0) as num,
        fee: (m['fee'] ?? 0) as int,
        status: (m['status'] ?? 'new') as String,
      );
}
