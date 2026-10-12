library;

/// Core Enums for the LocaLink platform.
/// Strictly aligned with the Backend Architecture and UI/UX Specification v2.

enum UserRole {
  customer,
  provider,
  shopOwner,
  placeOwner;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.provider:
        return 'Service provider';
      case UserRole.shopOwner:
        return 'Shop owner';
      case UserRole.placeOwner:
        return 'Place owner';
    }
  }
}

enum ListingKind {
  service,
  place,
  shop;

  String get displayName {
    switch (this) {
      case ListingKind.service:
        return 'Service';
      case ListingKind.place:
        return 'Place';
      case ListingKind.shop:
        return 'Shop';
    }
  }
}

enum ListingStatus {
  pending,
  active,
  blocked,
}

enum RequestStatus {
  searching,
  accepted,
  onTheWay,
  inProgress,
  done,
  cancelled,
  noProvider;

  String toBackendString() {
    switch (this) {
      case RequestStatus.searching:
        return 'searching';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.onTheWay:
        return 'on_the_way';
      case RequestStatus.inProgress:
        return 'in_progress';
      case RequestStatus.done:
        return 'done';
      case RequestStatus.cancelled:
        return 'cancelled';
      case RequestStatus.noProvider:
        return 'no_provider';
    }
  }

  static RequestStatus fromBackendString(String? raw) {
    switch (raw) {
      case 'searching':
        return RequestStatus.searching;
      case 'accepted':
        return RequestStatus.accepted;
      case 'on_the_way':
      case 'onTheWay':
        return RequestStatus.onTheWay;
      case 'in_progress':
      case 'inProgress':
        return RequestStatus.inProgress;
      case 'done':
        return RequestStatus.done;
      case 'cancelled':
        return RequestStatus.cancelled;
      case 'no_provider':
      case 'noProvider':
        return RequestStatus.noProvider;
      default:
        return RequestStatus.searching;
    }
  }

  String get label {
    switch (this) {
      case RequestStatus.searching:
        return 'Searching nearby';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.onTheWay:
        return 'On the way';
      case RequestStatus.inProgress:
        return 'In progress';
      case RequestStatus.done:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.noProvider:
        return 'No provider found';
    }
  }
}

enum Urgency {
  now,
  today,
  schedule,
  sos;

  String get label {
    switch (this) {
      case Urgency.now:
        return 'Normal / Now';
      case Urgency.today:
        return 'Today';
      case Urgency.schedule:
        return 'Scheduled';
      case Urgency.sos:
        return 'Urgent / SOS';
    }
  }
}

enum LeadStatus {
  newLead,
  viewed,
  accepted,
  declined,
  expired;

  String toBackendString() {
    switch (this) {
      case LeadStatus.newLead:
        return 'new';
      case LeadStatus.viewed:
        return 'viewed';
      case LeadStatus.accepted:
        return 'accepted';
      case LeadStatus.declined:
        return 'declined';
      case LeadStatus.expired:
        return 'expired';
    }
  }

  static LeadStatus fromBackendString(String? raw) {
    switch (raw) {
      case 'new':
      case 'newLead':
        return LeadStatus.newLead;
      case 'viewed':
        return LeadStatus.viewed;
      case 'accepted':
        return LeadStatus.accepted;
      case 'declined':
        return LeadStatus.declined;
      case 'expired':
        return LeadStatus.expired;
      default:
        return LeadStatus.newLead;
    }
  }
}

enum VerificationStatus {
  draft,
  pending,
  approved,
  rejected,
}

/// Helper for safe string to enum conversion
T enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null || name.isEmpty) return fallback;
  for (final v in values) {
    if (v.name.toLowerCase() == name.toLowerCase()) return v;
  }
  return fallback;
}
