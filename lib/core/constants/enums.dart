enum UserRole { customer, provider, shopOwner, placeOwner }
enum ListingKind { service, place, shop }
enum ListingStatus { pending, active, blocked }
enum RequestStatus { searching, accepted, on_the_way, in_progress, done, cancelled, no_provider }
enum Urgency { now, today, schedule, sos }
enum LeadStatus { newLead, viewed, accepted, declined, expired }
enum VerificationStatus { draft, pending, approved, rejected }

/// Safe parse: returns [fallback] when Firestore has an unknown value.
T enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
