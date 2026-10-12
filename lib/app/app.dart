import 'package:flutter/material.dart';

import '../core/config/env.dart';
import '../dev/dev_menu_view.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

class LocaLinkApp extends StatelessWidget {
  const LocaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocaLink',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.light, // Uses curated light palette by default
      routes: {
        ...allRoutes,
        DevMenuView.route: (_) => const DevMenuView(),
      },
      initialRoute: Env.startWithDevMenu ? DevMenuView.route : '/auth/splash',
    );
  }
}
