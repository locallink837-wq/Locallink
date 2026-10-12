import 'package:flutter/material.dart';

import '../../features/assistant/views/assistant_view.dart';
import '../../features/browse/views/home_view.dart';
import '../../features/browse/views/map_view.dart';
import '../../features/requests/views/request_history_view.dart';
import '../../features/safety_profile/views/profile_view.dart';

/// Customer bottom navigation: Home, Map, AI, Requests, Me.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});
  static const route = '/shell/customer';

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;
  static const _pages = <Widget>[
    HomeView(), MapView(), AssistantView(), RequestHistoryView(), ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
    );
  }
}
