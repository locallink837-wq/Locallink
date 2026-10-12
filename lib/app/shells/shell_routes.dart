import 'package:flutter/widgets.dart';

import 'customer_shell.dart';
import 'provider_shell.dart';
import 'vendor_shell.dart';

final Map<String, WidgetBuilder> shellRoutes = {
  CustomerShell.route: (_) => const CustomerShell(),
  ProviderShell.route: (_) => const ProviderShell(),
  VendorShell.route: (_) => const VendorShell(),
};
