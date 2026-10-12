import 'package:flutter/material.dart';

import '../../features/assistant/views/assistant_view.dart';
import '../../features/browse/views/home_view.dart';
import '../../features/browse/views/map_view.dart';
import '../../features/requests/views/request_history_view.dart';
import '../../features/safety_profile/views/profile_view.dart';
import '../theme/app_theme.dart';

/// Customer bottom navigation shell: Home, Map, AI, Requests, Me.
/// Corresponds to Module 2/UX Shell for Customer Role.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});
  static const route = '/shell/customer';

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;
  static const _pages = <Widget>[
    HomeView(),
    MapView(),
    AssistantView(),
    RequestHistoryView(),
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
            indicatorColor: AppColors.teal.withValues(alpha: 0.15),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.teal),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map, color: AppColors.teal),
                label: 'Map',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome, color: AppColors.teal),
                label: 'AI',
              ),
              NavigationDestination(
                icon: Icon(Icons.format_list_bulleted_outlined),
                selectedIcon: Icon(Icons.format_list_bulleted, color: AppColors.teal),
                label: 'Requests',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.teal),
                label: 'Me',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
