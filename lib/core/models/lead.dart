import '../constants/enums.dart';

/// Provider Lead document (`leads/{requestId_providerId}`).
class Lead {
  final String id;
  final String requestId;
  final String providerId;
  final String category;
  final String summary;
  final String areaLabel; // Rough location without sensitive customer contact
  final num distanceM;
  final int fee; // Credits required to unlock
  final String status; // new | viewed | accepted | declined | expired
  final DateTime? createdAt;

  const Lead({
    required this.id,
    required this.requestId,
    required this.providerId,
    this.category = '',
    this.summary = '',
    this.areaLabel = '',
    this.distanceM = 0,
    this.fee = 25,
    this.status = 'new',
    this.createdAt,
  });

  LeadStatus get parsedStatus => LeadStatus.fromBackendString(status);

  String get formattedDistance {
    if (distanceM <= 0) return 'Nearby';
    if (distanceM < 1000) return '${distanceM.round()} m';
    return '${(distanceM / 1000).toStringAsFixed(1)} km';
  }

  factory Lead.fromMap(String id, Map<String, dynamic> m) => Lead(
        id: id,
        requestId: (m['requestId'] ?? '') as String,
        providerId: (m['providerId'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        summary: (m['summary'] ?? '') as String,
        areaLabel: (m['areaLabel'] ?? '') as String,
        distanceM: (m['distanceM'] ?? 0) as num,
        fee: (m['fee'] ?? 25) as int,
        status: (m['status'] ?? 'new') as String,
        createdAt: m['createdAt'] != null
            ? (m['createdAt'] is DateTime
                ? m['createdAt'] as DateTime
                : DateTime.tryParse(m['createdAt'].toString()))
            : null,
      );

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'providerId': providerId,
        'category': category,
        'summary': summary,
        'areaLabel': areaLabel,
        'distanceM': distanceM,
        'fee': fee,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  Lead copyWith({
    String? id,
    String? requestId,
    String? providerId,
    String? category,
    String? summary,
    String? areaLabel,
    num? distanceM,
    int? fee,
    String? status,
    DateTime? createdAt,
  }) {
    return Lead(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      providerId: providerId ?? this.providerId,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      areaLabel: areaLabel ?? this.areaLabel,
      distanceM: distanceM ?? this.distanceM,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
