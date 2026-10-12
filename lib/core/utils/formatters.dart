/// Formatting utilities for currency, distance, phones, and times.
class AppFormatters {
  /// Format credits or money: e.g. "Rs 25"
  static String currency(num amount, {bool useRupeeSymbol = false}) {
    final prefix = useRupeeSymbol ? '₹' : 'Rs ';
    return '$prefix${amount.toInt()}';
  }

  /// Format distance from meters: e.g. "450 m", "1.4 km"
  static String distance(num meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Masks customer phone for privacy until request is accepted: e.g., "+91 ••••• ••123"
  static String maskPhone(String phone) {
    if (phone.length <= 4) return '••••';
    final visiblePart = phone.substring(phone.length - 4);
    return '••••••$visiblePart';
  }

  /// Friendly time string, e.g., "10:30 AM" or "Yesterday"
  static String friendlyTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $amPm';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
