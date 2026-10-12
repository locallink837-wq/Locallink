import 'package:flutter/widgets.dart';

import 'views/assistant_view.dart';
import 'views/photo_consent_view.dart';
import 'views/ai_result_view.dart';
import 'views/follow_up_question_view.dart';
import 'views/ai_unavailable_view.dart';
import 'views/new_to_city_form_view.dart';
import 'views/plan_loading_view.dart';
import 'views/checklist_view.dart';
import 'views/task_detail_view.dart';

/// All routes of this feature. Only the owner (A) edits this file.
final Map<String, WidgetBuilder> assistantRoutes = {
  AssistantView.route: (_) => const AssistantView(),
  PhotoConsentView.route: (_) => const PhotoConsentView(),
  AiResultView.route: (_) => const AiResultView(),
  FollowUpQuestionView.route: (_) => const FollowUpQuestionView(),
  AiUnavailableView.route: (_) => const AiUnavailableView(),
  NewToCityFormView.route: (_) => const NewToCityFormView(),
  PlanLoadingView.route: (_) => const PlanLoadingView(),
  ChecklistView.route: (_) => const ChecklistView(),
  TaskDetailView.route: (_) => const TaskDetailView(),
};
