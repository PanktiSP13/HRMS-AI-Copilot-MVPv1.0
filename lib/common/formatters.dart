import 'constants/app_constants.dart';

class AppFormatters {
  AppFormatters._();

  static String date(DateTime value) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]}, ${value.year}';
  }

  static String dateRange(DateTime start, DateTime end) {
    final startText = date(start);
    final endText = date(end);
    return start.year == end.year && start.month == end.month && start.day == end.day
        ? startText
        : '$startText - $endText';
  }

  static String value(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? AppStrings.notAvailable : normalized;
  }
}
