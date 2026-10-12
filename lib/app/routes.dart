import 'package:flutter/widgets.dart';

import '../features/assistant/assistant_routes.dart';
import '../features/auth/auth_routes.dart';
import '../features/browse/browse_routes.dart';
import '../features/provider/provider_routes.dart';
import '../features/requests/requests_routes.dart';
import '../features/safety_profile/safety_profile_routes.dart';
import '../features/vendor/vendor_routes.dart';
import 'shells/shell_routes.dart';

/// Every route in the app, grouped by module.
/// To add new routes, register them in `features/<name>/<name>_routes.dart`.
final Map<String, Map<String, WidgetBuilder>> featureRoutes = {
  'Module 1 - Auth and onboarding': authRoutes,
  'Module 2 - Browse (home, lists, detail, map)': browseRoutes,
  'Module 3 - Service request': requestsRoutes,
  'Module 4 - AI assistant and New to City': assistantRoutes,
  'Module 5 - SOS and profile': safetyProfileRoutes,
  'Module 6 - Service provider': providerRoutes,
  'Module 7 - Shop and place owner': vendorRoutes,
  'Bottom-nav shells': shellRoutes,
};

Map<String, WidgetBuilder> get allRoutes => {
  for (final m in featureRoutes.values) ...m,
};
