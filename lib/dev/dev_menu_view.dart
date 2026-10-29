import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../app/theme/theme_controller.dart';
import '../core/localization/app_language.dart';

/// Comprehensive Screen Testing Gallery & Dev Harness for LocaLink.
/// Lists every single view across all modules for instant one-tap testing.
class DevMenuView extends StatefulWidget {
  const DevMenuView({super.key});
  static const route = '/dev';

  @override
  State<DevMenuView> createState() => _DevMenuViewState();
}

class _ScreenItem {
  final String title;
  final String route;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? mockArgs;

  const _ScreenItem({
    required this.title,
    required this.route,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    this.mockArgs,
  });
}

class _DevMenuViewState extends State<DevMenuView> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<_ScreenItem> _allScreens = [
    // -------------------------------------------------------------------------
    // MODULE 1: AUTH & ONBOARDING
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'Splash Screen',
      route: '/auth/splash',
      category: 'Auth & Onboarding',
      description: 'App logo, session check, and automated redirect routing',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'Intro Onboarding Carousel',
      route: '/auth/intro',
      category: 'Auth & Onboarding',
      description: 'Value props, animations, and get started button',
      icon: Icons.view_carousel_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'Language Selection',
      route: '/auth/language',
      category: 'Auth & Onboarding',
      description: 'Select English, Hindi, or Marathi with real-time switch',
      icon: Icons.translate_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'Role Choice',
      route: '/auth/role-choice',
      category: 'Auth & Onboarding',
      description: 'Choose Customer, Service Provider, or Shop/Place Owner',
      icon: Icons.people_alt_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'Sign In / Sign Up',
      route: '/auth/sign-in',
      category: 'Auth & Onboarding',
      description: 'Phone OTP, Email password, Google Sign-in',
      icon: Icons.login_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'Verify Phone OTP',
      route: '/auth/verify-phone',
      category: 'Auth & Onboarding',
      description: '6-digit OTP code verification keypad',
      icon: Icons.pin_rounded,
      color: Color(0xFF6C5CE7),
      mockArgs: {'phoneNumber': '+91 98765 43210', 'verificationId': 'mock-verif-id'},
    ),
    _ScreenItem(
      title: 'Customer Info Profile Setup',
      route: '/auth/customer-info',
      category: 'Auth & Onboarding',
      description: 'First name, area, and primary city setup',
      icon: Icons.person_outline_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'GPS Location Permission',
      route: '/auth/location-permission',
      category: 'Auth & Onboarding',
      description: 'High-accuracy GPS location request and auto-detect',
      icon: Icons.my_location_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'Sign Up Gate Bottom Sheet',
      route: '/auth/sign-up-gate',
      category: 'Auth & Onboarding',
      description: 'Encourages guest users to register with quick benefits',
      icon: Icons.lock_outline_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _ScreenItem(
      title: 'Login To Book Interstitial',
      route: '/auth/login-to-book',
      category: 'Auth & Onboarding',
      description: 'Shown when an unauthenticated user tries to book a service',
      icon: Icons.book_online_rounded,
      color: Color(0xFF6C5CE7),
    ),

    // -------------------------------------------------------------------------
    // MODULE 2: BROWSE & EXPLORE
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'Guest Home View',
      route: '/browse/guest-home',
      category: 'Browse & Explore',
      description: 'Home screen tailored for guests with registration banners',
      icon: Icons.explore_outlined,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Customer Home Screen',
      route: '/browse/home',
      category: 'Browse & Explore',
      description: 'Category grid, nearby emergency banner, search bar',
      icon: Icons.home_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Browse Services',
      route: '/browse/services',
      category: 'Browse & Explore',
      description: 'Electricians, plumbers, carpenters, mechanics list',
      icon: Icons.handyman_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Browse Public Places',
      route: '/browse/places',
      category: 'Browse & Explore',
      description: 'Hospitals, colleges, hostels, banks, libraries',
      icon: Icons.account_balance_rounded,
      color: AppColors.indigo,
    ),
    _ScreenItem(
      title: 'Browse Local Shops',
      route: '/browse/shops',
      category: 'Browse & Explore',
      description: 'Hardware, chemist, stationery, groceries',
      icon: Icons.storefront_rounded,
      color: AppColors.amber,
    ),
    _ScreenItem(
      title: 'Category Filter List',
      route: '/browse/listings',
      category: 'Browse & Explore',
      description: 'Listings view with distance, rating, and open tags',
      icon: Icons.format_list_bulleted_rounded,
      color: AppColors.teal,
      mockArgs: {'category': 'Plumber', 'title': 'Plumbers near you'},
    ),
    _ScreenItem(
      title: 'Global Search Results',
      route: '/browse/search',
      category: 'Browse & Explore',
      description: 'Instant autocomplete search across all listings',
      icon: Icons.search_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Shop Detail Screen',
      route: '/browse/shop-detail',
      category: 'Browse & Explore',
      description: 'Photos, open timings, contact button, directions, catalog',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.amber,
    ),
    _ScreenItem(
      title: 'Place Detail Screen',
      route: '/browse/place-detail',
      category: 'Browse & Explore',
      description: 'Facility info, timings, emergency contacts, location',
      icon: Icons.local_hospital_rounded,
      color: AppColors.indigo,
    ),
    _ScreenItem(
      title: 'Provider Detail Screen',
      route: '/browse/provider-detail',
      category: 'Browse & Explore',
      description: 'Service pricing, customer reviews, booking action',
      icon: Icons.badge_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Interactive Map View',
      route: '/browse/map',
      category: 'Browse & Explore',
      description: 'OpenStreetMap with category filter pills and location pin',
      icon: Icons.map_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Reviews List Screen',
      route: '/browse/reviews',
      category: 'Browse & Explore',
      description: 'Customer review breakdown, star averages, comments',
      icon: Icons.star_rate_rounded,
      color: AppColors.star,
    ),
    _ScreenItem(
      title: 'Report Incorrect Info',
      route: '/browse/report-wrong-info',
      category: 'Browse & Explore',
      description: 'Community feedback form to correct shop/service details',
      icon: Icons.report_problem_rounded,
      color: Color(0xFFE17055),
    ),
    _ScreenItem(
      title: 'Saved Places & Bookmarks',
      route: '/browse/saved-places',
      category: 'Browse & Explore',
      description: 'Bookmarked shops, emergency contacts, and favorites',
      icon: Icons.bookmark_rounded,
      color: AppColors.indigo,
    ),

    // -------------------------------------------------------------------------
    // MODULE 3: SERVICE REQUESTS
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'Request Service Form',
      route: '/requests/form',
      category: 'Service Requests',
      description: 'Choose trade, urgency level, photo attachment, and notes',
      icon: Icons.assignment_rounded,
      color: Color(0xFF00B894),
      mockArgs: {'category': 'Plumber', 'serviceName': 'Plumbing Repair'},
    ),
    _ScreenItem(
      title: 'Finding Providers Radar',
      route: '/requests/finding',
      category: 'Service Requests',
      description: 'Radar wave animation broadcasting request to local pros',
      icon: Icons.radar_rounded,
      color: Color(0xFF00B894),
      mockArgs: {
        'requestId': 'demo_req_001',
        'category': 'Electrician',
        'address': 'Shivajinagar, Pune',
      },
    ),
    _ScreenItem(
      title: 'Request Accepted Screen',
      route: '/requests/accepted',
      category: 'Service Requests',
      description: 'Matched provider profile, estimated arrival, inspection fee',
      icon: Icons.check_circle_rounded,
      color: Color(0xFF00B894),
      mockArgs: {
        'requestId': 'demo_req_001',
        'providerName': 'Santosh Sharma',
        'providerPhone': '+91 98220 12345',
        'category': 'Electrician',
        'fee': 250,
      },
    ),
    _ScreenItem(
      title: 'Live Provider Tracking',
      route: '/requests/tracking',
      category: 'Service Requests',
      description: 'Live distance ETA, direct call button, status tracker',
      icon: Icons.navigation_rounded,
      color: Color(0xFF00B894),
      mockArgs: {
        'requestId': 'demo_req_001',
        'providerName': 'Santosh Sharma',
      },
    ),
    _ScreenItem(
      title: 'In-App Direct Chat',
      route: '/requests/chat',
      category: 'Service Requests',
      description: 'Chat messaging between customer and assigned technician',
      icon: Icons.forum_rounded,
      color: Color(0xFF00B894),
      mockArgs: {
        'requestId': 'demo_req_001',
        'recipientName': 'Santosh Sharma (Electrician)',
      },
    ),
    _ScreenItem(
      title: 'Job Done & Review',
      route: '/requests/review',
      category: 'Service Requests',
      description: 'Payment confirmation, star rating, feedback notes',
      icon: Icons.rate_review_rounded,
      color: Color(0xFF00B894),
      mockArgs: {
        'requestId': 'demo_req_001',
        'providerId': 'demo_prov_1',
        'providerName': 'Santosh Sharma',
      },
    ),
    _ScreenItem(
      title: 'Customer Request History',
      route: '/requests/history',
      category: 'Service Requests',
      description: 'Archive of active and past requested services',
      icon: Icons.history_rounded,
      color: Color(0xFF00B894),
    ),
    _ScreenItem(
      title: 'Cancel Request Sheet',
      route: '/requests/cancel',
      category: 'Service Requests',
      description: 'Select cancellation reason and confirm request stop',
      icon: Icons.cancel_outlined,
      color: AppColors.red,
      mockArgs: {'requestId': 'demo_req_001'},
    ),
    _ScreenItem(
      title: 'No Provider Available',
      route: '/requests/no-provider',
      category: 'Service Requests',
      description: 'Timeout fallback screen with retry or alternative actions',
      icon: Icons.error_outline_rounded,
      color: Color(0xFFE17055),
    ),

    // -------------------------------------------------------------------------
    // MODULE 4: AI ASSISTANT & CITY GUIDE
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'AI Problem Assistant',
      route: '/assistant/chat',
      category: 'AI & City Guide',
      description: 'Gemini powered voice/text troubleshooter for home issues',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF0984E3),
    ),
    _ScreenItem(
      title: 'Photo Analysis Consent',
      route: '/assistant/photo-consent',
      category: 'AI & City Guide',
      description: 'Camera privacy consent for image diagnostic analysis',
      icon: Icons.camera_alt_rounded,
      color: Color(0xFF0984E3),
    ),
    _ScreenItem(
      title: 'AI Diagnosis Result',
      route: '/assistant/ai-result',
      category: 'AI & City Guide',
      description: 'Problem diagnosis, estimated repair cost, required tools',
      icon: Icons.psychology_rounded,
      color: Color(0xFF0984E3),
      mockArgs: {
        'problem': 'Defective MCB Breaker Tripping',
        'cost': '₹300 - ₹550',
        'tools': 'Multimeter, Screwdriver Set, 16A MCB',
        'category': 'Electrician',
      },
    ),
    _ScreenItem(
      title: 'AI Follow-Up Question',
      route: '/assistant/follow-up',
      category: 'AI & City Guide',
      description: 'AI prompt to ask user clarifying questions on repair',
      icon: Icons.question_answer_rounded,
      color: Color(0xFF0984E3),
      mockArgs: {
        'question': 'Is the water leaking continuously or only when tap is open?',
      },
    ),
    _ScreenItem(
      title: 'AI Unavailable / Offline',
      route: '/assistant/unavailable',
      category: 'AI & City Guide',
      description: 'Graceful fallback when offline or API quota reached',
      icon: Icons.cloud_off_rounded,
      color: Color(0xFF0984E3),
    ),
    _ScreenItem(
      title: 'New To City Questionnaire',
      route: '/assistant/new-to-city-form',
      category: 'AI & City Guide',
      description: 'Select your relocation status (Student, Job Worker, Family)',
      icon: Icons.location_city_rounded,
      color: Color(0xFF0984E3),
    ),
    _ScreenItem(
      title: 'AI City Plan Generator Loading',
      route: '/assistant/plan-loading',
      category: 'AI & City Guide',
      description: 'Dynamic animation loading personalized onboarding plan',
      icon: Icons.hourglass_top_rounded,
      color: Color(0xFF0984E3),
      mockArgs: {'role': 'Student', 'city': 'Pune'},
    ),
    _ScreenItem(
      title: 'Relocation Checklist',
      route: '/assistant/checklist',
      category: 'AI & City Guide',
      description: 'Step-by-step tasks: SIM card, PG/Flat, Wifi, Local Transit',
      icon: Icons.checklist_rounded,
      color: Color(0xFF0984E3),
      mockArgs: {'role': 'Student'},
    ),
    _ScreenItem(
      title: 'Checklist Task Detail',
      route: '/assistant/task-detail',
      category: 'AI & City Guide',
      description: 'Detailed instructions, nearby shops, and document tips',
      icon: Icons.task_alt_rounded,
      color: Color(0xFF0984E3),
      mockArgs: {
        'title': 'Get Local SIM Card & Broadband',
        'category': 'Utilities',
        'description': 'Keep Aadhaar card and passport photo ready at telecom store.',
      },
    ),

    // -------------------------------------------------------------------------
    // MODULE 5: SOS & PROFILE
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'Emergency SOS Dispatcher',
      route: '/safety/sos',
      category: 'SOS & Safety',
      description: '112 National helpline, high-volume siren, live SMS alerts',
      icon: Icons.emergency_rounded,
      color: AppColors.red,
    ),
    _ScreenItem(
      title: 'Urgent Request Broadcast',
      route: '/safety/urgent-request',
      category: 'SOS & Safety',
      description: 'Immediate priority broadcast for night & emergency fixes',
      icon: Icons.warning_amber_rounded,
      color: AppColors.red,
    ),
    _ScreenItem(
      title: 'Customer Profile View',
      route: '/safety/profile',
      category: 'SOS & Safety',
      description: 'Personal info, quick logout, and account management',
      icon: Icons.account_circle_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Edit Profile View',
      route: '/safety/edit-profile',
      category: 'SOS & Safety',
      description: 'Update name, phone, home address, and profile photo',
      icon: Icons.edit_note_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Settings & Preferences',
      route: '/safety/settings',
      category: 'SOS & Safety',
      description: 'Theme switcher, language selection, notifications',
      icon: Icons.settings_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Help & Feedback Support',
      route: '/safety/help',
      category: 'SOS & Safety',
      description: 'FAQ database, direct email, and feedback submission',
      icon: Icons.help_outline_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Guest Requests & Profile',
      route: '/safety/guest-profile',
      category: 'SOS & Safety',
      description: 'Guest profile gate prompting registration',
      icon: Icons.person_off_rounded,
      color: AppColors.teal,
    ),

    // -------------------------------------------------------------------------
    // MODULE 6: SERVICE PROVIDER
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'Provider 1: Core Trade Info',
      route: '/provider/register-core',
      category: 'Service Provider',
      description: 'Full name, trade category, and primary phone number',
      icon: Icons.app_registration_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Provider 2: Trade Details',
      route: '/provider/register-details',
      category: 'Service Provider',
      description: 'Years experience, tools owned, and service summary',
      icon: Icons.work_outline_rounded,
      color: Color(0xFF27AE60),
      mockArgs: {'name': 'Ramesh Shinde', 'trade': 'Plumber'},
    ),
    _ScreenItem(
      title: 'Provider 3: Location Pinning',
      route: '/provider/register-location',
      category: 'Service Provider',
      description: 'Interactive map picker and shop/service center address',
      icon: Icons.pin_drop_rounded,
      color: Color(0xFF27AE60),
      mockArgs: {'name': 'Ramesh Shinde', 'trade': 'Plumber'},
    ),
    _ScreenItem(
      title: 'Provider 4: Verification Docs',
      route: '/provider/register-documents',
      category: 'Service Provider',
      description: 'Upload Aadhaar front/back and optional skill certificates',
      icon: Icons.upload_file_rounded,
      color: Color(0xFF27AE60),
      mockArgs: {
        'name': 'Ramesh Shinde',
        'trade': 'Plumber',
        'address': 'Kothrud, Pune',
      },
    ),
    _ScreenItem(
      title: 'Application Pending Review',
      route: '/provider/pending',
      category: 'Service Provider',
      description: 'Verification status tracker with background check timer',
      icon: Icons.pending_actions_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Verification Rejected',
      route: '/provider/rejected',
      category: 'Service Provider',
      description: 'Review rejection reason and resubmit updated documents',
      icon: Icons.highlight_off_rounded,
      color: AppColors.red,
      mockArgs: {
        'reason': 'Aadhaar photo is blurry. Please upload a clear photo.',
      },
    ),
    _ScreenItem(
      title: 'Provider Lead Inbox',
      route: '/provider/lead-inbox',
      category: 'Service Provider',
      description: 'Nearby customer job broadcasts with countdown timers',
      icon: Icons.move_to_inbox_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Lead Detail View',
      route: '/provider/lead-detail',
      category: 'Service Provider',
      description: 'Customer problem description, distance, and accept action',
      icon: Icons.content_paste_search_rounded,
      color: Color(0xFF27AE60),
      mockArgs: {
        'leadId': 'lead_101',
        'customerName': 'Meera Joshi',
        'category': 'Plumber',
        'distance': '1.2 km away',
        'fee': 300,
        'description': 'Bathroom pipeline leakage urgent.',
      },
    ),
    _ScreenItem(
      title: 'Confirm Lead Fee Sheet',
      route: '/provider/confirm-fee',
      category: 'Service Provider',
      description: 'Wallet coin deduction confirmation to unlock client details',
      icon: Icons.monetization_on_outlined,
      color: Color(0xFF27AE60),
      mockArgs: {
        'leadId': 'lead_101',
        'fee': 25,
        'customerName': 'Meera Joshi',
      },
    ),
    _ScreenItem(
      title: 'Lead Already Taken',
      route: '/provider/lead-taken',
      category: 'Service Provider',
      description: 'Alert shown when another provider claimed the job first',
      icon: Icons.timer_off_rounded,
      color: Color(0xFFE17055),
    ),
    _ScreenItem(
      title: 'Lead Expired View',
      route: '/provider/lead-expired',
      category: 'Service Provider',
      description: 'Notification that lead timer reached 0 without accept',
      icon: Icons.access_time_filled_rounded,
      color: Color(0xFFE17055),
    ),
    _ScreenItem(
      title: 'Low Wallet Balance Sheet',
      route: '/provider/low-wallet',
      category: 'Service Provider',
      description: 'Recharge prompt when coins are insufficient to accept lead',
      icon: Icons.account_balance_wallet_outlined,
      color: AppColors.amber,
      mockArgs: {'balance': 10, 'required': 30},
    ),
    _ScreenItem(
      title: 'Customer Contact Unlocked',
      route: '/provider/accepted-contact',
      category: 'Service Provider',
      description: 'Direct phone number, full address, navigation button',
      icon: Icons.contact_phone_rounded,
      color: Color(0xFF27AE60),
      mockArgs: {
        'customerName': 'Meera Joshi',
        'customerPhone': '+91 94220 56789',
        'address': 'Flat 204, Om Residency, Model Colony, Pune',
        'category': 'Plumbing Repair',
      },
    ),
    _ScreenItem(
      title: 'Active Ongoing Job',
      route: '/provider/active-job',
      category: 'Service Provider',
      description: 'Start work, mark complete, and collect payment',
      icon: Icons.engineering_rounded,
      color: Color(0xFF27AE60),
      mockArgs: {
        'jobId': 'job_101',
        'customerName': 'Meera Joshi',
        'category': 'Plumbing Repair',
      },
    ),
    _ScreenItem(
      title: 'Wallet & Coin Recharge',
      route: '/provider/wallet',
      category: 'Service Provider',
      description: 'Balance overview, transaction logs, coin bundle packs',
      icon: Icons.savings_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Provider Dashboard',
      route: '/provider/dashboard',
      category: 'Service Provider',
      description: 'Weekly earnings, jobs completed, acceptance rate, stars',
      icon: Icons.dashboard_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Provider Public Profile',
      route: '/provider/profile',
      category: 'Service Provider',
      description: 'Work photos portfolio, trade credentials, customer reviews',
      icon: Icons.contact_page_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Edit Services & Pricing',
      route: '/provider/edit-services',
      category: 'Service Provider',
      description: 'Toggle service trades and update standard inspection rates',
      icon: Icons.price_change_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Service Coverage Radius',
      route: '/provider/service-area',
      category: 'Service Provider',
      description: 'Set maximum travel distance from home base (km slider)',
      icon: Icons.fmd_good_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Provider Customer Reviews',
      route: '/provider/my-reviews',
      category: 'Service Provider',
      description: 'Read reviews and client testimonials for your jobs',
      icon: Icons.reviews_rounded,
      color: AppColors.star,
    ),
    _ScreenItem(
      title: 'Documents Status',
      route: '/provider/documents-status',
      category: 'Service Provider',
      description: 'Check Aadhaar, driving licence, and trade cert status',
      icon: Icons.verified_user_rounded,
      color: Color(0xFF27AE60),
    ),

    // -------------------------------------------------------------------------
    // MODULE 7: VENDOR & PLACE OWNER
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'Register Shop 1: Basic Info',
      route: '/vendor/register-shop',
      category: 'Vendor & Shop',
      description: 'Shop business name, category, and owner contact number',
      icon: Icons.store_mall_directory_rounded,
      color: AppColors.amber,
    ),
    _ScreenItem(
      title: 'Register Shop 2: Location',
      route: '/vendor/shop-location',
      category: 'Vendor & Shop',
      description: 'Interactive map pin, GPS detect, and manual address',
      icon: Icons.add_location_alt_rounded,
      color: AppColors.amber,
      mockArgs: {'shopName': 'Pune Hardware & Paints'},
    ),
    _ScreenItem(
      title: 'Register Shop 3: Hours & Photo',
      route: '/vendor/shop-hours-photo',
      category: 'Vendor & Shop',
      description: 'Storefront photo upload, 24x7 toggle, opening hours',
      icon: Icons.schedule_rounded,
      color: AppColors.amber,
      mockArgs: {
        'shopName': 'Pune Hardware & Paints',
        'address': 'FC Road, Pune',
      },
    ),
    _ScreenItem(
      title: 'Register Shop 4: Items & Brands',
      route: '/vendor/product-types',
      category: 'Vendor & Shop',
      description: 'Stock catalog, major brands sold, and delivery options',
      icon: Icons.inventory_2_rounded,
      color: AppColors.amber,
      mockArgs: {
        'shopName': 'Pune Hardware & Paints',
        'address': 'FC Road, Pune',
      },
    ),
    _ScreenItem(
      title: 'Register Place 1: Details',
      route: '/vendor/register-place',
      category: 'Vendor & Shop',
      description: 'Register Hospital, College, Student PG, Bank, or Library',
      icon: Icons.domain_rounded,
      color: AppColors.indigo,
    ),
    _ScreenItem(
      title: 'Register Place 2: Location',
      route: '/vendor/place-location',
      category: 'Vendor & Shop',
      description: 'Pin public place on map and complete registration',
      icon: Icons.map_outlined,
      color: AppColors.indigo,
      mockArgs: {
        'placeName': 'Sancheti Hospital',
        'placeType': 'Hospital',
      },
    ),
    _ScreenItem(
      title: 'Claim Business Listing',
      route: '/vendor/claim-listing',
      category: 'Vendor & Shop',
      description: 'Claim ownership of an existing unverified place listing',
      icon: Icons.verified_rounded,
      color: AppColors.amber,
    ),
    _ScreenItem(
      title: 'Vendor Dashboard',
      route: '/vendor/dashboard',
      category: 'Vendor & Shop',
      description: 'Visitor views, enquiry calls, stock updates, opening hours',
      icon: Icons.analytics_rounded,
      color: AppColors.amber,
    ),
    _ScreenItem(
      title: 'Edit Listing Details',
      route: '/vendor/edit-listing',
      category: 'Vendor & Shop',
      description: 'Update shop photos, timings, phone number, and address',
      icon: Icons.edit_attributes_rounded,
      color: AppColors.amber,
      mockArgs: {'listingId': 'demo_shop_1'},
    ),
    _ScreenItem(
      title: 'Verification Status Badge',
      route: '/vendor/verification-status',
      category: 'Vendor & Shop',
      description: 'Check verified business badge and review feedback',
      icon: Icons.military_tech_rounded,
      color: AppColors.amber,
      mockArgs: {
        'businessName': 'Pune Hardware & Paints',
        'status': 'under_review',
      },
    ),

    // -------------------------------------------------------------------------
    // BOTTOM-NAV SHELLS
    // -------------------------------------------------------------------------
    _ScreenItem(
      title: 'Customer Shell',
      route: '/shell/customer',
      category: 'Navigation Shells',
      description: 'Primary customer bottom-bar (Home, Map, AI, Requests, SOS, Me)',
      icon: Icons.tab_rounded,
      color: AppColors.teal,
    ),
    _ScreenItem(
      title: 'Provider Shell',
      route: '/shell/provider',
      category: 'Navigation Shells',
      description: 'Provider bottom-bar (Leads, Active Job, Wallet, Profile)',
      icon: Icons.work_history_rounded,
      color: Color(0xFF27AE60),
    ),
    _ScreenItem(
      title: 'Vendor Shell',
      route: '/shell/vendor',
      category: 'Navigation Shells',
      description: 'Shop owner bottom-bar (Dashboard, Listing, Messages, Me)',
      icon: Icons.store_rounded,
      color: AppColors.amber,
    ),
  ];

  final List<String> _categories = [
    'All',
    'Auth & Onboarding',
    'Browse & Explore',
    'Service Requests',
    'AI & City Guide',
    'SOS & Safety',
    'Service Provider',
    'Vendor & Shop',
    'Navigation Shells',
  ];

  List<_ScreenItem> get _filteredScreens {
    return _allScreens.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.route.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openScreen(BuildContext context, _ScreenItem item) {
    try {
      Navigator.of(context).pushNamed(item.route, arguments: item.mockArgs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open ${item.title}: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                trailing: AppLanguage.instance.code == 'en' ? const Icon(Icons.check, color: AppColors.teal) : null,
                onTap: () {
                  AppLanguage.instance.setLanguage('en');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                title: const Text('हिंदी (Hindi)'),
                trailing: AppLanguage.instance.code == 'hi' ? const Icon(Icons.check, color: AppColors.teal) : null,
                onTap: () {
                  AppLanguage.instance.setLanguage('hi');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🚩', style: TextStyle(fontSize: 24)),
                title: const Text('मराठी (Marathi)'),
                trailing: AppLanguage.instance.code == 'mr' ? const Icon(Icons.check, color: AppColors.teal) : null,
                onTap: () {
                  AppLanguage.instance.setLanguage('mr');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeController.instance.isDark;
    final filtered = _filteredScreens;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LocaLink Test Gallery',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${_allScreens.length} Screens Ready for Testing',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Switch Language',
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => _showLanguageDialog(context),
          ),
          IconButton(
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              setState(() {
                ThemeController.instance.toggle();
              });
            },
          ),
          IconButton(
            tooltip: 'Launch Real App (Splash)',
            icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF00B894), size: 28),
            onPressed: () {
              Navigator.of(context).pushNamed('/auth/splash');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Banner & Quick Action Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF132A2F), const Color(0xFF0A181B)]
                        : [const Color(0xFF0E5E63), const Color(0xFF147A81)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.developer_mode_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'One-Tap Screen Test Runner',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Tap any card to test that exact page with safe mock arguments.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pushNamed('/auth/splash'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 18),
                          SizedBox(width: 4),
                          Text('Normal Flow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Box
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search 83 screens by name, route, or category...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF14262A) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF223437) : const Color(0xFFD6E0DF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF223437) : const Color(0xFFD6E0DF)),
                  ),
                ),
              ),
            ),
          ),

          // Category Chips Bar
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSelected = _selectedCategory == cat;
                  final count = cat == 'All'
                      ? _allScreens.length
                      : _allScreens.where((s) => s.category == cat).length;

                  return FilterChip(
                    selected: isSelected,
                    label: Text('$cat ($count)'),
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.5,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF0F1F23)),
                    ),
                    selectedColor: AppColors.teal,
                    backgroundColor: isDark ? const Color(0xFF14262A) : const Color(0xFFE2F0EF),
                    side: BorderSide(
                      color: isSelected ? AppColors.teal : (isDark ? const Color(0xFF2E4347) : Colors.transparent),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Results count indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Showing ${filtered.length} of ${_allScreens.length} screens',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          // Screens List
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No screens matching "$_searchQuery"',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'All';
                      }),
                      child: const Text('Reset filters'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filtered[index];
                    return _buildScreenCard(context, item, isDark);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreenCard(BuildContext context, _ScreenItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14262A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF223437) : const Color(0xFFE2EBEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openScreen(context, item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B1416) : const Color(0xFFF1F5F5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark ? const Color(0xFF223437) : const Color(0xFFD6E0DF),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.route,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.mockArgs != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B894).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Auto-Mock Args',
                                style: TextStyle(
                                  color: Color(0xFF00B894),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            'Test',
                            style: TextStyle(
                              color: item.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 18, color: item.color),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
