import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';

/// Modal bottom sheet allowing users to rate and review a listing.
class WriteReviewSheet extends StatefulWidget {
  final String listingId;
  final String listingName;
  final VoidCallback? onReviewSubmitted;

  const WriteReviewSheet({
    super.key,
    required this.listingId,
    required this.listingName,
    this.onReviewSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required String listingId,
    required String listingName,
    VoidCallback? onReviewSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewSheet(
        listingId: listingId,
        listingName: listingName,
        onReviewSubmitted: onReviewSubmitted,
      ),
    );
  }

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  final _repository = BrowseRepository();

  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a brief comment.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repository.addReview(
        listingId: widget.listingId,
        rating: _rating,
        comment: comment,
        authorName: _nameController.text.trim(),
        authorId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your review has been submitted.'),
            backgroundColor: AppColors.teal,
          ),
        );
        widget.onReviewSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lineLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Write a Review',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              widget.listingName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.muteLight,
              ),
            ),
            const SizedBox(height: 18),

            // Star selector
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starValue = (index + 1).toDouble();
                  final isFilled = starValue <= _rating;

                  return IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFilled ? AppColors.star : AppColors.lineLight,
                    ),
                    onPressed: () => setState(() => _rating = starValue),
                  );
                }),
              ),
            ),
            Center(
              child: Text(
                '$_rating / 5.0 Stars',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkLight,
                ),
              ),
            ),
            const SizedBox(height: 18),

            AppTextField(
              controller: _nameController,
              hintText: 'Your name (optional)',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
            ),
            const SizedBox(height: 12),

            AppTextField(
              controller: _commentController,
              hintText: 'Share details of your experience...',
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            AppButton(
              label: 'Submit Review',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
