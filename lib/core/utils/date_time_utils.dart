class DateTimeUtils {
  static String formatForDisplay(DateTime value) {
    return '${value.day}/${value.month}/${value.year} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  /// True when the deadline is still in the future but within the next 24
  /// hours. Used for the subtle "Expiring Soon" urgency indicator.
  static bool isExpiringSoon(DateTime deadline) {
    final now = DateTime.now();
    return deadline.isAfter(now) &&
        deadline.isBefore(now.add(const Duration(hours: 24)));
  }

  /// True when the deadline has already passed.
  static bool isPastDeadline(DateTime deadline) {
    return deadline.isBefore(DateTime.now());
  }

  /// Short human-readable countdown label, e.g. "5h left" or "2d left".
  static String timeLeftLabel(DateTime deadline) {
    final difference = deadline.difference(DateTime.now());
    if (difference.isNegative) {
      return 'Past deadline';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min left';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h left';
    }
    return '${difference.inDays}d left';
  }
}
