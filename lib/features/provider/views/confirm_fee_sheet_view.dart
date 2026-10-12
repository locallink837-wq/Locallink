import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/lead.dart';
import '../../../core/models/wallet.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'accepted_contact_view.dart';
import 'lead_already_taken_view.dart';
import 'lead_expired_view.dart';
import 'low_wallet_view.dart';

/// Screen: Confirm Fee Sheet (Tagged NEW in UI/UX E_F).
/// Shows wallet balance, lead fee, and calls Cloud Function acceptLead.
class ConfirmFeeSheetView extends StatefulWidget {
  final Lead? lead;

  const ConfirmFeeSheetView({super.key, this.lead});

  static const route = '/provider/confirm-fee-sheet';

  @override
  State<ConfirmFeeSheetView> createState() => _ConfirmFeeSheetViewState();
}

class _ConfirmFeeSheetViewState extends State<ConfirmFeeSheetView> {
  final _repo = ProviderRepository();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleAccept(Lead lead, int currentBalance) async {
    // If balance is too low, navigate straight to Low Wallet screen
    if (currentBalance < lead.fee) {
      Navigator.pushNamed(
        context,
        LowWalletView.route,
        arguments: {'balance': currentBalance, 'fee': lead.fee},
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repo.acceptLead(lead.id);

      if (!mounted) return;
      setState(() => _isLoading = false);

      switch (result) {
        case AcceptLeadResult.success:
          Navigator.pushReplacementNamed(
            context,
            AcceptedContactView.route,
            arguments: {'requestId': lead.requestId, 'leadId': lead.id},
          );
          break;
        case AcceptLeadResult.lowBalance:
          Navigator.pushNamed(
            context,
            LowWalletView.route,
            arguments: {'balance': currentBalance, 'fee': lead.fee},
          );
          break;
        case AcceptLeadResult.alreadyTaken:
          Navigator.pushReplacementNamed(context, LeadAlreadyTakenView.route);
          break;
        case AcceptLeadResult.expired:
          Navigator.pushReplacementNamed(context, LeadExpiredView.route);
          break;
        case AcceptLeadResult.error:
          setState(() => _errorMessage = 'Could not accept lead. Please try again.');
          break;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error accepting lead: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final lead = widget.lead ?? args['lead'] as Lead?;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (lead == null) {
      return const Scaffold(
        body: Center(child: Text('Lead details not found')),
      );
    }

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: SafeArea(
          child: StreamBuilder<Wallet?>(
            stream: uid.isNotEmpty ? _repo.streamWallet(uid) : const Stream.empty(),
            builder: (context, snapshot) {
              final wallet = snapshot.data;
              final balance = wallet?.balance ?? 0;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: UiColors.indigo.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 36,
                          color: UiColors.indigo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: uiText(
                        'Accept this lead?',
                        size: 22,
                        weight: FontWeight.w800,
                        align: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: uiText(
                        '₹${lead.fee} is deducted from your wallet balance. The customer\'s contact phone unlocks immediately after acceptance.',
                        size: 13,
                        color: UiColors.muted,
                        align: TextAlign.center,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_errorMessage != null) ...[
                      UiWarningBanner(text: _errorMessage!),
                      const SizedBox(height: 14),
                    ],

                    // Breakdown tile: Wallet balance
                    UiListTile(
                      title: 'Wallet balance',
                      subtitle: balance < lead.fee ? 'Low balance' : 'Available credits',
                      icon: Icons.account_balance_wallet_rounded,
                      trailing: uiText('₹$balance', size: 14, weight: FontWeight.w800, color: balance < lead.fee ? UiColors.red : UiColors.ink),
                    ),

                    // Breakdown tile: Lead fee
                    UiListTile(
                      title: 'Lead unlock fee',
                      subtitle: 'One-time connection fee',
                      icon: Icons.receipt_long_outlined,
                      trailing: uiText('₹${lead.fee}', size: 14, weight: FontWeight.w800, color: UiColors.indigo),
                    ),

                    const Spacer(),

                    // Action buttons
                    UiMainButton(
                      label: 'Pay ₹${lead.fee} and accept',
                      isLoading: _isLoading,
                      onPressed: () => _handleAccept(lead, balance),
                    ),
                    const SizedBox(height: 12),
                    UiGhostButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
