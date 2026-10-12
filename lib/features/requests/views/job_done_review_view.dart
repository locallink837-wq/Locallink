import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';
import 'request_history_view.dart';

/// Screen 3.7: Job Done and Review.
/// Allows customer to rate completed job 1 to 5 stars and writes review to listings/{providerId}/reviews/{customerUid}.
class JobDoneReviewView extends StatefulWidget {
  const JobDoneReviewView({super.key});

  static const route = '/requests/job-done-review';

  @override
  State<JobDoneReviewView> createState() => _JobDoneReviewViewState();
}

class _JobDoneReviewViewState extends State<JobDoneReviewView> {
  final _commentController = TextEditingController();
  final _repo = RequestsRepository();

  double _rating = 5.0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(String providerId, String providerName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Please sign in to submit a review.');
      return;
    }

    if (providerId.isEmpty) {
      setState(() => _errorMessage = 'Provider not found.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _repo.submitReview(
        providerId: providerId,
        customerUid: user.uid,
        customerName: user.displayName ?? 'Customer',
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your review has been published.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, RequestHistoryView.route, (r) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Could not submit review: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final providerId = (args['providerId'] ?? '').toString();
    final providerName = (args['providerName'] ?? 'Provider').toString();

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Rate $providerName',
        bottomButton: UiMainButton(
          label: 'Submit review',
          customAccent: UiColors.teal,
          isLoading: _isSubmitting,
          onPressed: () => _submitReview(providerId, providerName),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 40),
              ),
              const SizedBox(height: 14),
              uiText('Job completed!', size: 20, weight: FontWeight.w800, align: TextAlign.center),
              const SizedBox(height: 4),
              uiText(
                'How was your experience with $providerName?',
                size: 13,
                color: UiColors.muted,
                align: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              // Interactive 1-5 Star selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 5; i++)
                    GestureDetector(
                      onTap: () => setState(() => _rating = i.toDouble()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Icon(
                          i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 38,
                          color: UiColors.star,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              UiTextInput(
                label: 'Share your feedback (optional)',
                hintText: 'e.g. Arrived quickly, professional work and fair pricing.',
                controller: _commentController,
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
