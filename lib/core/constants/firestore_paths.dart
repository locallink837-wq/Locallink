/// Collection and document paths for Cloud Firestore and Supabase Storage.
/// Strictly based on the Backend Architecture Document.
/// Never hardcode raw strings in feature files; always use [FsPaths] and [Buckets].
class FsPaths {
  // Top-level collections
  static const String admins = 'admins';
  static const String config = 'config';
  static const String users = 'users';
  static const String devices = 'devices';
  static const String emergencyContacts = 'emergency_contacts';
  static const String notifications = 'notifications';
  static const String listings = 'listings';
  static const String reviews = 'reviews';
  static const String listingStats = 'listing_stats';
  static const String reports = 'reports';
  static const String claims = 'claims';
  static const String requests = 'requests';
  static const String privateContact = 'private'; // doc: contact
  static const String messages = 'messages';
  static const String live = 'live'; // doc: provider
  static const String leads = 'leads';
  static const String providers = 'providers';
  static const String wallets = 'wallets';
  static const String walletTxns = 'wallet_txns';
  static const String payments = 'payments';
  static const String aiSessions = 'ai_sessions';
  static const String plans = 'plans';
  static const String feedback = 'feedback';
  static const String sosEvents = 'sos_events';

  // Subcollection and Document Path Helpers
  static String userDoc(String uid) => '$users/$uid';
  static String userDevices(String uid) => '$users/$uid/$devices';

  static String listingDoc(String listingId) => '$listings/$listingId';
  static String listingReviews(String listingId) => '$listings/$listingId/$reviews';

  static String requestDoc(String requestId) => '$requests/$requestId';
  static String requestPrivateContact(String requestId) => '$requests/$requestId/$privateContact/contact';
  static String requestMessages(String requestId) => '$requests/$requestId/$messages';
  static String requestLiveProvider(String requestId) => '$requests/$requestId/$live/provider';

  static String leadDoc(String leadId) => '$leads/$leadId';
  static String providerDoc(String providerUid) => '$providers/$providerUid';

  static String walletDoc(String uid) => '$wallets/$uid';
  static String walletTxnsSub(String uid) => '$wallets/$uid/$walletTxns';

  static String aiSessionDoc(String sessionId) => '$aiSessions/$sessionId';
  static String planDoc(String planId) => '$plans/$planId';
  static String sosEventDoc(String eventId) => '$sosEvents/$eventId';
}

/// Supabase Storage Buckets
class Buckets {
  static const String listingPhotos = 'listing-photos';
  static const String avatars = 'avatars';
  static const String requestPhotos = 'request-photos';
  static const String providerDocs = 'provider-docs';
  static const String aiPhotos = 'ai-photos';
}
