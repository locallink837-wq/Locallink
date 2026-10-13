/// Small input checks shared by the auth screens.
class AuthValidators {
  AuthValidators._();

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isEmail(String v) => _email.hasMatch(v.trim());

  /// Indian mobile number, digits only (10 digits, starts with 6-9).
  static String digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

  static bool isIndianMobile(String v) {
    final d = digitsOnly(v);
    final ten = d.length > 10 ? d.substring(d.length - 10) : d;
    return RegExp(r'^[6-9]\d{9}$').hasMatch(ten);
  }

  /// "98765 43210" or "+91 98765 43210" -> "+919876543210"
  static String toE164(String v) {
    final d = digitsOnly(v);
    final ten = d.length > 10 ? d.substring(d.length - 10) : d;
    return '+91$ten';
  }
}
