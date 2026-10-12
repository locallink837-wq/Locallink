import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(); // Firebase / Supabase setup lives in core/config/bootstrap.dart
  runApp(const LocaLinkApp());
}
