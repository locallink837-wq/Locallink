import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/core.dart';
import '../data/browse_repository.dart';

/// Report wrong info
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
class ReportWrongInfoView extends StatefulWidget {
  const ReportWrongInfoView({super.key});

  static const route = '/browse/report-wrong-info';

  @override
  State<ReportWrongInfoView> createState() => _ReportWrongInfoViewState();
}

class _ReportWrongInfoViewState extends State<ReportWrongInfoView> {
  final _repository = BrowseRepository();
  final _notesController = TextEditingController();

  Listing? _listing;
  String _selectedReason = 'Permanently Closed';
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Permanently Closed',
    'Incorrect Phone Number',
    'Wrong Location or Address',
    'Incorrect Operating Hours',
    'Duplicate or Fake Listing',
    'Inappropriate Content / Behavior',
    'Other Issue',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listing == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Listing) {
        _listing = args;
      } else {
        _listing = BrowseRepository.demoListings.first;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final listing = _listing;
    if (listing == null) return;

    setState(() => _isSubmitting = true);

    try {
      await _repository.reportWrongInfo(
        listingId: listing.id,
        listingName: listing.name,
        reason: _selectedReason,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your report has been submitted for verification.'),
            backgroundColor: AppColors.teal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = _listing;
    if (listing == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listing Info Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lineLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.report_problem_rounded, color: AppColors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.inkLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${listing.category} • ${listing.address}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muteLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'What issue did you encounter?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.inkLight,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select the category that best describes the problem with this listing.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muteLight,
              ),
            ),
            const SizedBox(height: 12),

            // Selectable Reasons
            ..._reasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedReason = reason),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.teal : AppColors.lineLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 20,
                            color: isSelected ? AppColors.teal : AppColors.secondaryMuteLight,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: AppColors.inkLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            const Text(
              'Additional Details (Optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.inkLight,
              ),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: _notesController,
              hintText: 'e.g., "The store moved two blocks down" or "Phone number doesn\'t ring"...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Submit Report',
              isLoading: _isSubmitting,
              onPressed: _submitReport,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
