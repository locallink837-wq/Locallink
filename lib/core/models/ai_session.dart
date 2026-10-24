/// AI Diagnostic Session document (`ai_sessions/{sessionId}`).
/// Records user photo diagnosis, problem summary, estimated cost, and category.
class AiSession {
  final String id;
  final String userId;
  final String? photoUrl;
  final String problemTitle;
  final String category;
  final String diagnosis;
  final String safetyTips;
  final int estimatedCostMin;
  final int estimatedCostMax;
  final String urgency;
  final double confidence;
  final DateTime createdAt;

  const AiSession({
    required this.id,
    required this.userId,
    this.photoUrl,
    required this.problemTitle,
    required this.category,
    required this.diagnosis,
    this.safetyTips = '',
    this.estimatedCostMin = 200,
    this.estimatedCostMax = 500,
    this.urgency = 'today',
    this.confidence = 0.9,
    required this.createdAt,
  });

  String get priceRangeDisplay => '₹$estimatedCostMin - ₹$estimatedCostMax';

  factory AiSession.fromMap(String id, Map<String, dynamic> m) {
    return AiSession(
      id: id,
      userId: (m['userId'] ?? '') as String,
      photoUrl: m['photoUrl'] as String?,
      problemTitle: (m['problemTitle'] ?? m['title'] ?? 'Household Issue') as String,
      category: (m['category'] ?? 'Services') as String,
      diagnosis: (m['diagnosis'] ?? '') as String,
      safetyTips: (m['safetyTips'] ?? '') as String,
      estimatedCostMin: (m['estimatedCostMin'] ?? 200) as int,
      estimatedCostMax: (m['estimatedCostMax'] ?? 500) as int,
      urgency: (m['urgency'] ?? 'today') as String,
      confidence: ((m['confidence'] ?? 0.9) as num).toDouble(),
      createdAt: m['createdAt'] != null
          ? (m['createdAt'] is DateTime
              ? m['createdAt'] as DateTime
              : DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'problemTitle': problemTitle,
        'category': category,
        'diagnosis': diagnosis,
        'safetyTips': safetyTips,
        'estimatedCostMin': estimatedCostMin,
        'estimatedCostMax': estimatedCostMax,
        'urgency': urgency,
        'confidence': confidence,
        'createdAt': createdAt.toIso8601String(),
      };

  AiSession copyWith({
    String? id,
    String? userId,
    String? photoUrl,
    String? problemTitle,
    String? category,
    String? diagnosis,
    String? safetyTips,
    int? estimatedCostMin,
    int? estimatedCostMax,
    String? urgency,
    double? confidence,
    DateTime? createdAt,
  }) {
    return AiSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      photoUrl: photoUrl ?? this.photoUrl,
      problemTitle: problemTitle ?? this.problemTitle,
      category: category ?? this.category,
      diagnosis: diagnosis ?? this.diagnosis,
      safetyTips: safetyTips ?? this.safetyTips,
      estimatedCostMin: estimatedCostMin ?? this.estimatedCostMin,
      estimatedCostMax: estimatedCostMax ?? this.estimatedCostMax,
      urgency: urgency ?? this.urgency,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
