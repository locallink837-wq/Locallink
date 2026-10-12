import 'package:flutter/material.dart';

/// Wallet
/// Module 6 - Service provider  |  Owner: C
/// Replace the body below with your real UI. Keep the class name and route.
class WalletView extends StatelessWidget {
  const WalletView({super.key});

  static const route = '/provider/wallet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: const Center(child: Text('TODO: Wallet')),
    );
  }
}
