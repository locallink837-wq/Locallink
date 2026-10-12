import 'package:flutter/widgets.dart';

import 'views/lead_inbox_view.dart';
import 'views/lead_detail_view.dart';
import 'views/low_wallet_view.dart';
import 'views/accepted_contact_view.dart';
import 'views/active_job_view.dart';
import 'views/wallet_view.dart';
import 'views/provider_dashboard_view.dart';
import 'views/provider_profile_view.dart';
// TODO: import your existing views: register_core_view.dart, register_details_view.dart, register_location_view.dart, register_documents_view.dart, pending_view.dart

/// All routes of this feature. Only the owner (C) edits this file.
final Map<String, WidgetBuilder> providerRoutes = {
  LeadInboxView.route: (_) => const LeadInboxView(),
  LeadDetailView.route: (_) => const LeadDetailView(),
  LowWalletView.route: (_) => const LowWalletView(),
  AcceptedContactView.route: (_) => const AcceptedContactView(),
  ActiveJobView.route: (_) => const ActiveJobView(),
  WalletView.route: (_) => const WalletView(),
  ProviderDashboardView.route: (_) => const ProviderDashboardView(),
  ProviderProfileView.route: (_) => const ProviderProfileView(),

  // TODO (owner C): register your EXISTING views here, e.g.
  //   RegisterCoreView.route: (_) => const RegisterCoreView(),
  //   RegisterDetailsView.route: (_) => const RegisterDetailsView(),
  //   RegisterLocationView.route: (_) => const RegisterLocationView(),
  //   RegisterDocumentsView.route: (_) => const RegisterDocumentsView(),
  //   PendingView.route: (_) => const PendingView(),
};
