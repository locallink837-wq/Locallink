import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';

/// Screen 3.9: Cancel Request Confirmation Sheet.
/// Allows customer to select a reason and updates request status to 'cancelled'.
class CancelSheetView extends StatefulWidget {
  const CancelSheetView({super.key});

  static const route = '/requests/cancel-sheet';

  @override
  State<CancelSheetView> createState() => _CancelSheetViewState();
}

class _CancelSheetViewState extends State<CancelSheetView> {
  final _repo = RequestsRepository();
  String _selectedReason = 'Found someone else';
  bool _isCancelling = false;

  final List<String> _reasons = [
    'Found someone else',
    'Not needed anymore',
    'Taking too long',
    'Entered wrong address',
    'Other reason',
  ];

  Future<void> _handleCancel(String requestId) async {
    setState(() => _isCancelling = true);

    try {
      await _repo.cancelRequest(
        requestId: requestId,
        reason: _selectedReason,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled successfully.')),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final requestId = (args['requestId'] ?? '').toString();

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: UiColors.red.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined, size: 36, color: UiColors.red),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: uiText('Cancel request?', size: 22, weight: FontWeight.w800, align: TextAlign.center),
                ),
                const SizedBox(height: 8),
                Center(
                  child: uiText(
                    'Please tell us why you want to cancel this request:',
                    size: 13,
                    color: UiColors.muted,
                    align: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Reasons Chips
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final r in _reasons)
                        UiChip(
                          label: r,
                          customAccent: UiColors.teal,
                          isSelected: _selectedReason == r,
                          onTap: () => setState(() => _selectedReason = r),
                        ),
                    ],
                  ),
                ),
                const Spacer(),

                UiMainButton(
                  label: 'Confirm cancel',
                  customAccent: UiColors.red,
                  isLoading: _isCancelling,
                  onPressed: () => _handleCancel(requestId),
                ),
                const SizedBox(height: 10),
                UiGhostButton(
                  label: 'Keep request',
                  customAccent: UiColors.teal,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
