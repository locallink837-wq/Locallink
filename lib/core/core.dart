/// LocaLink Core Library Barrel.
/// Team members can import this single file to access all core constants,
/// models, services, utilities, and design system widgets.
library;

// Configuration & Environment
export 'config/bootstrap.dart';
export 'config/env.dart';

// Constants & Enums
export 'constants/enums.dart';
export 'constants/firestore_paths.dart';

// Domain Models
export 'models/app_user.dart';
export 'models/chat_message.dart';
export 'models/lead.dart';
export 'models/listing.dart';
export 'models/review.dart';
export 'models/ai_session.dart';
export 'models/relocation_plan.dart';
export 'models/service_request.dart';
export 'models/wallet.dart';

// Services
export 'services/auth_service.dart';
export 'services/location_service.dart';
export 'services/notification_service.dart';
export 'services/storage_service.dart';

// Utilities
export 'utils/formatters.dart';
export 'utils/image_compress.dart';

// Reusable Design System Widgets
export 'widgets/app_button.dart';
export 'widgets/app_text_field.dart';
export 'widgets/category_chip.dart';
export 'widgets/category_grid.dart';
export 'widgets/empty_state.dart';
export 'widgets/error_view.dart';
export 'widgets/listing_card.dart';
export 'widgets/open_now_badge.dart';
export 'widgets/sos_banner.dart';
export 'widgets/status_stepper.dart';
