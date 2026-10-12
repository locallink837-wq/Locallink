/// Review document (`listings/{id}/reviews/{reviewId}`).
class Review {
  final String id;
  final String listingId;
  final String authorId;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.listingId,
    required this.authorId,
    this.authorName = 'Anonymous',
    this.rating = 5.0,
    this.comment = '',
    this.createdAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> m) => Review(
        id: id,
        listingId: (m['listingId'] ?? '') as String,
        authorId: (m['authorId'] ?? '') as String,
        authorName: (m['authorName'] ?? 'Anonymous') as String,
        rating: (m['rating'] ?? 5.0).toDouble(),
        comment: (m['comment'] ?? '') as String,
        createdAt: m['createdAt'] != null
            ? (m['createdAt'] is DateTime
                ? m['createdAt'] as DateTime
                : DateTime.tryParse(m['createdAt'].toString()))
            : null,
      );

  Map<String, dynamic> toMap() => {
        'listingId': listingId,
        'authorId': authorId,
        'authorName': authorName,
        'rating': rating,
        'comment': comment,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}
