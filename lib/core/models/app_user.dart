import '../constants/enums.dart';

/// Represents a LocaLink user in Firestore (`users/{uid}`).
class AppUser {
  final String uid;
  final String role; // customer | provider | shopOwner | placeOwner
  final String name;
  final String phone;
  final String email;
  final String area;
  final String language; // en | hi | mr
  final bool onboardingDone;
  final String photoUrl;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.role,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.area = '',
    this.language = 'en',
    this.onboardingDone = false,
    this.photoUrl = '',
    this.createdAt,
  });

  bool get isCustomer => role == UserRole.customer.name;
  bool get isProvider => role == UserRole.provider.name;
  bool get isShopOwner => role == UserRole.shopOwner.name;
  bool get isPlaceOwner => role == UserRole.placeOwner.name;
  bool get isGuest => uid.isEmpty || name.isEmpty;

  UserRole get parsedRole {
    return enumFromName(UserRole.values, role, UserRole.customer);
  }

  static const empty = AppUser(
    uid: '',
    role: 'customer',
    name: 'Guest',
    onboardingDone: false,
  );

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        role: (m['role'] ?? 'customer') as String,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        area: (m['area'] ?? '') as String,
        language: (m['language'] ?? 'en') as String,
        onboardingDone: (m['onboardingDone'] ?? false) as bool,
        photoUrl: (m['photoUrl'] ?? '') as String,
        createdAt: m['createdAt'] != null
            ? (m['createdAt'] is DateTime
                ? m['createdAt'] as DateTime
                : DateTime.tryParse(m['createdAt'].toString()))
            : null,
      );

  Map<String, dynamic> toMap() => {
        'role': role,
        'name': name,
        'phone': phone,
        'email': email,
        'area': area,
        'language': language,
        'onboardingDone': onboardingDone,
        'photoUrl': photoUrl,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  AppUser copyWith({
    String? uid,
    String? role,
    String? name,
    String? phone,
    String? email,
    String? area,
    String? language,
    bool? onboardingDone,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      area: area ?? this.area,
      language: language ?? this.language,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
