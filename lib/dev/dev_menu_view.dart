import 'package:flutter/material.dart';

import '../app/routes.dart';

/// Developer launcher: open ANY screen of the app in one tap.
/// Great for demos and for testing your screen without finishing the whole flow.
/// Turn it off with Env.startWithDevMenu = false.
class DevMenuView extends StatelessWidget {
  const DevMenuView({super.key});
  static const route = '/dev';

  @override
  Widget build(BuildContext context) {
    final groups = featureRoutes.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('LocaLink - all screens')),
      body: ListView(
        children: [
          for (final g in groups)
            ExpansionTile(
              title: Text(g.key),
              subtitle: Text('${g.value.length} screens'),
              children: [
                for (final r in g.value.keys)
                  ListTile(
                    dense: true,
                    title: Text(r),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(r),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
