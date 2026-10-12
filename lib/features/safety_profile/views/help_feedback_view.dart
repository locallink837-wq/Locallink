import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/safety_profile_repository.dart';

/// Screen 5.6: Help, Support FAQs, and Feedback Submission.
class HelpFeedbackView extends StatefulWidget {
  const HelpFeedbackView({super.key});

  static const route = '/safety-profile/help-feedback';

  @override
  State<HelpFeedbackView> createState() => _HelpFeedbackViewState();
}

class _HelpFeedbackViewState extends State<HelpFeedbackView> {
  final _feedbackController = TextEditingController();
  final _repo = SafetyProfileRepository();

  bool _isSending = false;
  String? _statusMessage;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
      _statusMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      await _repo.submitFeedback(userId: uid, message: text);

      _feedbackController.clear();
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _statusMessage = 'Thank you for your feedback! Our engineering team will review it.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Help and feedback',
        bottomButton: UiMainButton(
          label: 'Send feedback',
          customAccent: UiColors.teal,
          isLoading: _isSending,
          onPressed: _sendFeedback,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: uiText(_statusMessage!, size: 12.5, color: const Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 14),
              ],

              uiText('Frequently asked questions', size: 14, weight: FontWeight.w800),
              const SizedBox(height: 10),

              UiListTile(
                title: 'How do service requests work?',
                subtitle: 'Requests broadcast to nearby verified providers',
                icon: Icons.lightbulb_outline_rounded,
                customAccent: UiColors.teal,
                onTap: () {},
              ),

              UiListTile(
                title: 'Contact support team',
                subtitle: 'support@localink.app',
                icon: Icons.mail_outline_rounded,
                customAccent: UiColors.teal,
                onTap: () {},
              ),
              const SizedBox(height: 18),

              uiText('Send your feedback', size: 14, weight: FontWeight.w800),
              const SizedBox(height: 8),

              UiTextInput(
                label: '',
                hintText: 'Share any issues, ideas, or suggestions to improve LocaLink...',
                controller: _feedbackController,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
