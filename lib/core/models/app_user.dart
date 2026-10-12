/// users/{uid}
class AppUser {
  final String uid;
  final String role; // customer | provider | shopOwner | placeOwner
  final String name;
  final String phone;
  final String email;
  final String area;
  final String language; // en | hi | mr
  final bool onboardingDone;

  const AppUser({
    required this.uid,
    required this.role,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.area = '',
    this.language = 'en',
    this.onboardingDone = false,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        role: (m['role'] ?? 'customer') as String,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        area: (m['area'] ?? '') as String,
        language: (m['language'] ?? 'en') as String,
        onboardingDone: (m['onboardingDone'] ?? false) as bool,
      );
}
