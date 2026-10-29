import 'package:flutter/widgets.dart';

import 'views/accepted_contact_view.dart';
import 'views/active_job_view.dart';
import 'views/confirm_fee_sheet_view.dart';
import 'views/documents_status_view.dart';
import 'views/edit_services_view.dart';
import 'views/lead_already_taken_view.dart';
import 'views/lead_detail_view.dart';
import 'views/lead_expired_view.dart';
import 'views/lead_inbox_view.dart';
import 'views/low_wallet_view.dart';
import 'views/my_reviews_view.dart';
import 'views/pending_view.dart';
import 'views/provider_dashboard_view.dart';
import 'views/provider_profile_view.dart';
import 'views/register_core_view.dart';
import 'views/register_details_view.dart';
import 'views/register_documents_view.dart';
import 'views/register_location_view.dart';
import 'views/service_area_view.dart';
import 'views/verification_rejected_view.dart';
import 'views/wallet_view.dart';

/// All routes of the provider feature (Module 6 - Service Provider).
/// Strictly registered here without modifying lib/app/routes.dart.
final Map<String, WidgetBuilder> providerRoutes = {
  // Registration flow (6.1 to 6.5 + verification_rejected)
  RegisterCoreView.route: (_) => const RegisterCoreView(),
  RegisterDetailsView.route: (_) => const RegisterDetailsView(),
  RegisterLocationView.route: (_) => const RegisterLocationView(),
  RegisterDocumentsView.route: (_) => const RegisterDocumentsView(),
  PendingView.route: (_) => const PendingView(),
  VerificationRejectedView.route: (_) => const VerificationRejectedView(),
  '/provider/rejected': (_) => const VerificationRejectedView(),

  // Leads and job management (6.6 to 6.10 + outcome screens)
  LeadInboxView.route: (_) => const LeadInboxView(),
  LeadDetailView.route: (_) => const LeadDetailView(),
  ConfirmFeeSheetView.route: (_) => const ConfirmFeeSheetView(),
  '/provider/confirm-fee': (_) => const ConfirmFeeSheetView(),
  LeadAlreadyTakenView.route: (_) => const LeadAlreadyTakenView(),
  LeadExpiredView.route: (_) => const LeadExpiredView(),
  LowWalletView.route: (_) => const LowWalletView(),
  AcceptedContactView.route: (_) => const AcceptedContactView(),
  ActiveJobView.route: (_) => const ActiveJobView(),

  // Wallet, Dashboard, and Profile (6.11 to 6.13 + sub-screens)
  WalletView.route: (_) => const WalletView(),
  ProviderDashboardView.route: (_) => const ProviderDashboardView(),
  '/provider/dashboard': (_) => const ProviderDashboardView(),
  ProviderProfileView.route: (_) => const ProviderProfileView(),
  '/provider/profile': (_) => const ProviderProfileView(),
  EditServicesView.route: (_) => const EditServicesView(),
  ServiceAreaView.route: (_) => const ServiceAreaView(),
  DocumentsStatusView.route: (_) => const DocumentsStatusView(),
  MyReviewsView.route: (_) => const MyReviewsView(),
};
