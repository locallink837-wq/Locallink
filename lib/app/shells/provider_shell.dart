import 'package:flutter/material.dart';

import '../../features/provider/views/active_job_view.dart';
import '../../features/provider/views/lead_inbox_view.dart';
import '../../features/provider/views/provider_profile_view.dart';
import '../../features/provider/views/wallet_view.dart';

/// Provider bottom navigation: Inbox, Jobs, Wallet, Me.
class ProviderShell extends StatefulWidget {
  const ProviderShell({super.key});
  static const route = '/shell/provider';

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _index = 0;
  static const _pages = <Widget>[
    LeadInboxView(), ActiveJobView(), WalletView(), ProviderProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
    );
  }
}
