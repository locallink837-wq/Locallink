import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';

/// Screen 3.6: Live Request Chat.
/// Streams messages from requests/{requestId}/messages and posts new replies.
class ChatView extends StatefulWidget {
  const ChatView({super.key});

  static const route = '/requests/chat';

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final _repo = RequestsRepository();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String requestId, String uid) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      await _repo.sendMessage(
        requestId: requestId,
        senderId: uid,
        text: text,
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final requestId = (args['requestId'] ?? '').toString();
    final recipientName = (args['recipientName'] ?? 'Provider').toString();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Chat with $recipientName',
        padding: EdgeInsets.zero,
        body: Column(
          children: [
            // Messages list stream
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: requestId.isNotEmpty ? _repo.streamMessages(requestId) : const Stream.empty(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const EmptyState(
                      title: 'Start conversation',
                      message: 'Send a message to coordinate timing, location, or directions.',
                      icon: Icons.chat_bubble_outline_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == uid;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? UiColors.teal : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isMe ? Colors.white : UiColors.ink,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Text input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: UiColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: UiColors.line),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(requestId, uid),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: UiColors.teal),
                    onPressed: () => _sendMessage(requestId, uid),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
