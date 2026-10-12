/// Chat message for in-app service communication (`requests/{id}/messages/{messageId}`).
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final bool isProvider;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.isProvider = false,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) => ChatMessage(
        id: id,
        senderId: (m['senderId'] ?? '') as String,
        senderName: (m['senderName'] ?? '') as String,
        text: (m['text'] ?? '') as String,
        isProvider: (m['isProvider'] ?? false) as bool,
        createdAt: m['createdAt'] != null
            ? (m['createdAt'] is DateTime
                ? m['createdAt'] as DateTime
                : DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now())
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isProvider': isProvider,
        'createdAt': createdAt.toIso8601String(),
      };
}
