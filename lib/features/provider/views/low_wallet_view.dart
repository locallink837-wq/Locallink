import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';

/// Screen 6.8: Low Wallet Balance Alert.
/// Informs provider of insufficient balance to unlock a lead, and provides demo credit top-up.
class LowWalletView extends StatefulWidget {
  const LowWalletView({super.key});

  static const route = '/provider/low-wallet';

  @override
  State<LowWalletView> createState() => _LowWalletViewState();
}

class _LowWalletViewState extends State<LowWalletView> {
  final _repo = ProviderRepository();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  Future<void> _addDemoCredits() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final success = await _repo.addDemoCredits();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSuccess = success;
      _statusMessage = success
          ? 'Demo credits (₹100) added successfully to your wallet!'
          : 'Top-up service is currently in test mode. Please contact admin.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final balance = args['balance'] ?? 0;
    final fee = args['fee'] ?? 25;

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Warning icon container
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: UiColors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 44,
                    color: UiColors.red,
                  ),
                ),
                const SizedBox(height: 20),

                // Warning Banner
                const UiWarningBanner(
                  text: 'Not enough balance',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 16),

                // Details Text
                uiText(
                  'Current balance: ₹$balance\nRequired lead fee: ₹$fee',
                  size: 15,
                  weight: FontWeight.w700,
                  align: TextAlign.center,
                  height: 1.5,
                ),
                const SizedBox(height: 10),
                uiText(
                  'Please top up your wallet credits to accept new incoming leads and unlock customer contact info.',
                  size: 13,
                  color: UiColors.muted,
                  align: TextAlign.center,
                  height: 1.4,
                ),
                const SizedBox(height: 18),

                if (_statusMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _isSuccess ? const Color(0xFF2E7D32) : UiColors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Spacer(),

                // Add demo credits button
                UiMainButton(
                  label: 'Add demo credits',
                  isLoading: _isLoading,
                  onPressed: _addDemoCredits,
                ),
                const SizedBox(height: 12),

                // Back button
                UiGhostButton(
                  label: 'Back',
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
