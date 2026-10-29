import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
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

  static CustomerShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<CustomerShellState>();

  @override
  State<CustomerShell> createState() => CustomerShellState();
}

class CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  void setTab(int index) {
    if (mounted) setState(() => _index = index);
  }

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
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home, color: AppColors.teal),
                label: AppLanguage.t('nav_home', defaultText: 'Home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map, color: AppColors.teal),
                label: AppLanguage.t('nav_map', defaultText: 'Map'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.auto_awesome_outlined),
                selectedIcon: const Icon(Icons.auto_awesome, color: AppColors.teal),
                label: AppLanguage.t('nav_ai', defaultText: 'AI'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.format_list_bulleted_outlined),
                selectedIcon: const Icon(Icons.format_list_bulleted, color: AppColors.teal),
                label: AppLanguage.t('nav_requests', defaultText: 'Requests'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person, color: AppColors.teal),
                label: AppLanguage.t('nav_me', defaultText: 'Me'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
