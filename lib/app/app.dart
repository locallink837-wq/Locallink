import 'package:flutter/material.dart';

import '../core/localization/app_language.dart';
import '../dev/dev_menu_view.dart';
import 'routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class LocaLinkApp extends StatelessWidget {
  const LocaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.instance.currentLanguage,
      builder: (context, currentLang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.instance.themeMode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'LocaLink',
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(),
              darkTheme: buildDarkTheme(),
              themeMode: themeMode,
              routes: {
                ...allRoutes,
                DevMenuView.route: (_) => const DevMenuView(),
              },
              initialRoute: DevMenuView.route,
            );
          },
        );
      },
    );
  }
}
