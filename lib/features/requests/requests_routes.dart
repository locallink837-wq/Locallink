import 'package:flutter/widgets.dart';

import 'views/request_form_view.dart';
import 'views/finding_providers_view.dart';
import 'views/request_accepted_view.dart';
import 'views/live_tracking_view.dart';
import 'views/chat_view.dart';
import 'views/job_done_review_view.dart';
import 'views/request_history_view.dart';
import 'views/cancel_sheet_view.dart';
import 'views/no_provider_found_view.dart';

/// All routes of this feature. Only the owner (B) edits this file.
final Map<String, WidgetBuilder> requestsRoutes = {
  RequestFormView.route: (_) => const RequestFormView(),
  FindingProvidersView.route: (_) => const FindingProvidersView(),
  RequestAcceptedView.route: (_) => const RequestAcceptedView(),
  LiveTrackingView.route: (_) => const LiveTrackingView(),
  ChatView.route: (_) => const ChatView(),
  JobDoneReviewView.route: (_) => const JobDoneReviewView(),
  RequestHistoryView.route: (_) => const RequestHistoryView(),
  CancelSheetView.route: (_) => const CancelSheetView(),
  NoProviderFoundView.route: (_) => const NoProviderFoundView(),
};
