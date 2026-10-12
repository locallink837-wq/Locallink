import 'package:flutter/widgets.dart';

import 'views/splash_view.dart';
import 'views/intro_view.dart';
import 'views/language_view.dart';
import 'views/role_choice_view.dart';
import 'views/sign_in_view.dart';
import 'views/verify_phone_view.dart';
import 'views/customer_info_view.dart';
import 'views/location_permission_view.dart';
import 'views/sign_up_gate_view.dart';
import 'views/login_to_book_view.dart';

/// All routes of this feature. Only the owner (A) edits this file.
final Map<String, WidgetBuilder> authRoutes = {
  SplashView.route: (_) => const SplashView(),
  IntroView.route: (_) => const IntroView(),
  LanguageView.route: (_) => const LanguageView(),
  RoleChoiceView.route: (_) => const RoleChoiceView(),
  SignInView.route: (_) => const SignInView(),
  VerifyPhoneView.route: (_) => const VerifyPhoneView(),
  CustomerInfoView.route: (_) => const CustomerInfoView(),
  LocationPermissionView.route: (_) => const LocationPermissionView(),
  SignUpGateView.route: (_) => const SignUpGateView(),
  LoginToBookView.route: (_) => const LoginToBookView(),
};
