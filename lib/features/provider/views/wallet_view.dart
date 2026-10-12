import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/wallet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';

/// Screen 6.11: Provider Wallet and Transaction Ledger.
/// Strictly reads wallets/{uid} and wallets/{uid}/wallet_txns (never writes from client).
/// Calls Cloud Function addDemoCredits for top-up.
class WalletView extends StatefulWidget {
  const WalletView({super.key});

  static const route = '/provider/wallet';

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final _repo = ProviderRepository();
  bool _isToppingUp = false;

  Future<void> _handleTopUp() async {
    setState(() => _isToppingUp = true);

    final success = await _repo.addDemoCredits();

    if (!mounted) return;
    setState(() => _isToppingUp = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Added ₹100 demo credits to wallet.'
              : 'Top-up payment gateway is in test mode. Demo credits requested.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Wallet',
        showBackButton: Navigator.canPop(context),
        body: uid.isEmpty
            ? const EmptyState(
                title: 'Log in required',
                message: 'Please sign in to view your wallet balance and transactions.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  StreamBuilder<Wallet?>(
                    stream: _repo.streamWallet(uid),
                    builder: (context, snapshot) {
                      final wallet = snapshot.data;
                      final balance = wallet?.balance ?? 0;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              UiColors.indigo,
                              Color.lerp(UiColors.indigo, Colors.black, 0.35) ?? UiColors.indigo,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: UiColors.indigo.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            uiText('Current Balance', size: 13, weight: FontWeight.w600, color: Colors.white70),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹$balance',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.shield_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Top-up button
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: UiColors.indigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isToppingUp ? null : _handleTopUp,
                                child: _isToppingUp
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Add credits',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Recent Transactions Header
                  uiText('Recent transactions', size: 15, weight: FontWeight.w800),
                  const SizedBox(height: 10),

                  // Transactions Stream
                  Expanded(
                    child: StreamBuilder<List<WalletTransaction>>(
                      stream: _repo.streamWalletTransactions(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }

                        final txns = snapshot.data ?? [];
                        if (txns.isEmpty) {
                          return const EmptyState(
                            title: 'No transactions yet',
                            message: 'Credit top-ups and lead fee deductions will be listed here.',
                            icon: Icons.receipt_long_outlined,
                          );
                        }

                        return ListView.builder(
                          itemCount: txns.length,
                          itemBuilder: (context, index) {
                            final txn = txns[index];
                            final isCredit = txn.isCredit;

                            return UiListTile(
                              title: txn.description.isNotEmpty ? txn.description : (isCredit ? 'Top up' : 'Lead fee'),
                              subtitle: '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year}',
                              icon: isCredit ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                              trailing: Text(
                                '${isCredit ? "+" : "-"}₹${txn.amount}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isCredit ? const Color(0xFF2E7D32) : UiColors.red,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
