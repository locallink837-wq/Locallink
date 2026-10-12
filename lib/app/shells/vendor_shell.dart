import 'package:flutter/material.dart';

import '../../features/safety_profile/views/profile_view.dart';
import '../../features/vendor/views/edit_listing_view.dart';
import '../../features/vendor/views/vendor_dashboard_view.dart';

/// Shop / place owner bottom navigation: Dashboard, Listing, Me.
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});
  static const route = '/shell/vendor';

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  int _index = 0;
  static const _pages = <Widget>[
    VendorDashboardView(), EditListingView(), ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Listing'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
    );
  }
}
