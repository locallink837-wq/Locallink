import 'package:flutter/material.dart';

import '../../features/provider/views/active_job_view.dart';
import '../../features/provider/views/lead_inbox_view.dart';
import '../../features/provider/views/provider_profile_view.dart';
import '../../features/provider/views/wallet_view.dart';
import '../theme/app_theme.dart';

/// Provider bottom navigation shell: Inbox, Jobs, Wallet, Me.
/// Corresponds to Module 6 for Service Provider Role.
class ProviderShell extends StatefulWidget {
  const ProviderShell({super.key});
  static const route = '/shell/provider';

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _index = 0;
  static const _pages = <Widget>[
    LeadInboxView(),
    ActiveJobView(),
    WalletView(),
    ProviderProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            indicatorColor: AppColors.indigo.withValues(alpha: 0.15),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.inbox_outlined),
                selectedIcon: Icon(Icons.inbox, color: AppColors.indigo),
                label: 'Inbox',
              ),
              NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build, color: AppColors.indigo),
                label: 'Jobs',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.indigo),
                label: 'Wallet',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.indigo),
                label: 'Me',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
