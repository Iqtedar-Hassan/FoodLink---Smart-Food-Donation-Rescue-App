class DateTimeUtils {
  static String formatForDisplay(DateTime value) {
    return '${value.day}/${value.month}/${value.year} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
