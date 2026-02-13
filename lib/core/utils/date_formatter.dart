import 'package:intl/intl.dart';

/// Date formatter utility
class DateFormatter {
  DateFormatter._();

  static final _fullDateFormat = DateFormat('MMMM dd, yyyy');
  static final _shortDateFormat = DateFormat('MMM dd');
  static final _timeFormat = DateFormat('HH:mm');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _dayMonthFormat = DateFormat('dd MMM');

  /// Format to full date (e.g., "January 15, 2024")
  static String formatFull(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// Format to short date (e.g., "Jan 15")
  static String formatShort(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format to time (e.g., "14:30")
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format to month and year (e.g., "January 2024")
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format to day and month (e.g., "15 Jan")
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Get relative time string (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Calculate days remaining until deadline
  static int daysRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get deadline from duration preset
  static DateTime getDeadlineFromPreset(String preset) {
    final now = DateTime.now();
    switch (preset) {
      case '30 Days':
        return now.add(const Duration(days: 30));
      case '3 Months':
        return DateTime(now.year, now.month + 3, now.day);
      case '6 Months':
        return DateTime(now.year, now.month + 6, now.day);
      default:
        return now.add(const Duration(days: 90));
    }
  }
}
