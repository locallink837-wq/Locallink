import 'package:flutter/material.dart';

import '../../features/safety_profile/views/profile_view.dart';
import '../../features/vendor/views/edit_listing_view.dart';
import '../../features/vendor/views/vendor_dashboard_view.dart';
import '../theme/app_theme.dart';

/// Shop / place owner bottom navigation: Dashboard, Listing, Me.
/// Corresponds to Module 7 for Shop & Place Owner Roles.
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});
  static const route = '/shell/vendor';

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  int _index = 0;
  static const _pages = <Widget>[
    VendorDashboardView(),
    EditListingView(),
    ProfileView(),
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
            indicatorColor: AppColors.amber.withValues(alpha: 0.15),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.amber),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront, color: AppColors.amber),
                label: 'Listing',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.amber),
                label: 'Me',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
