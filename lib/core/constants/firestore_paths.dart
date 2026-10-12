/// Collection names from the Backend Architecture PDF (section 3).
/// Never type a collection name by hand anywhere else.
class FsPaths {
  static const admins = 'admins';
  static const config = 'config';
  static const users = 'users';
  static const devices = 'devices';
  static const emergencyContacts = 'emergency_contacts';
  static const notifications = 'notifications';
  static const listings = 'listings';
  static const reviews = 'reviews';
  static const listingStats = 'listing_stats';
  static const reports = 'reports';
  static const claims = 'claims';
  static const requests = 'requests';
  static const privateContact = 'private'; // doc id: contact
  static const messages = 'messages';
  static const live = 'live'; // doc id: provider
  static const leads = 'leads';
  static const providers = 'providers';
  static const wallets = 'wallets';
  static const walletTxns = 'wallet_txns';
  static const payments = 'payments';
  static const aiSessions = 'ai_sessions';
  static const plans = 'plans';
  static const feedback = 'feedback';
  static const sosEvents = 'sos_events';
}

/// Supabase buckets (PDF section 7).
class Buckets {
  static const listingPhotos = 'listing-photos';
  static const avatars = 'avatars';
  static const requestPhotos = 'request-photos';
  static const providerDocs = 'provider-docs';
  static const aiPhotos = 'ai-photos';
}
