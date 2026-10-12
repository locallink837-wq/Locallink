import 'package:flutter/widgets.dart';

import 'views/sos_view.dart';
import 'views/urgent_request_view.dart';
import 'views/profile_view.dart';
import 'views/edit_profile_view.dart';
import 'views/settings_view.dart';
import 'views/help_feedback_view.dart';
import 'views/guest_requests_profile_view.dart';

/// All routes of this feature. Only the owner (A) edits this file.
final Map<String, WidgetBuilder> safetyProfileRoutes = {
  SosView.route: (_) => const SosView(),
  UrgentRequestView.route: (_) => const UrgentRequestView(),
  ProfileView.route: (_) => const ProfileView(),
  EditProfileView.route: (_) => const EditProfileView(),
  SettingsView.route: (_) => const SettingsView(),
  HelpFeedbackView.route: (_) => const HelpFeedbackView(),
  GuestRequestsProfileView.route: (_) => const GuestRequestsProfileView(),
};
