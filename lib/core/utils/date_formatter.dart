import 'package:intl/intl.dart';

class DateFormatter {
  // Date formats
  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthDayYear = DateFormat('MM/dd/yyyy');
  static final DateFormat _yearMonthDay = DateFormat('yyyy-MM-dd');
  static final DateFormat _longDate = DateFormat('MMMM dd, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM dd');
  static final DateFormat _dayName = DateFormat('EEEE');
  static final DateFormat _shortDayName = DateFormat('EEE');
  static final DateFormat _monthName = DateFormat('MMMM');
  static final DateFormat _shortMonthName = DateFormat('MMM');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonthYear = DateFormat('MMM yyyy');

  // Time formats
  static final DateFormat _time24 = DateFormat('HH:mm');
  static final DateFormat _time12 = DateFormat('hh:mm a');
  static final DateFormat _timeWithSeconds = DateFormat('HH:mm:ss');
  static final DateFormat _time12WithSeconds = DateFormat('hh:mm:ss a');

  // DateTime formats
  static final DateFormat _dateTime24 = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dateTime12 = DateFormat('dd/MM/yyyy hh:mm a');
  static final DateFormat _longDateTime = DateFormat('MMMM dd, yyyy hh:mm a');

  // Format date to DD/MM/YYYY
  static String formatDateDMY(DateTime date) {
    return _dayMonthYear.format(date);
  }

  // Format date to MM/DD/YYYY
  static String formatDateMDY(DateTime date) {
    return _monthDayYear.format(date);
  }

  // Format date to YYYY-MM-DD (ISO format)
  static String formatDateISO(DateTime date) {
    return _yearMonthDay.format(date);
  }

  // Format date to long format (January 01, 2024)
  static String formatLongDate(DateTime date) {
    return _longDate.format(date);
  }

  // Format date to short format (Jan 01)
  static String formatShortDate(DateTime date) {
    return _shortDate.format(date);
  }

  // Get day name (Monday)
  static String getDayName(DateTime date) {
    return _dayName.format(date);
  }

  // Get short day name (Mon)
  static String getShortDayName(DateTime date) {
    return _shortDayName.format(date);
  }

  // Get month name (January)
  static String getMonthName(DateTime date) {
    return _monthName.format(date);
  }

  // Get short month name (Jan)
  static String getShortMonthName(DateTime date) {
    return _shortMonthName.format(date);
  }

  // Format month and year (January 2024)
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  // Format short month and year (Jan 2024)
  static String formatShortMonthYear(DateTime date) {
    return _shortMonthYear.format(date);
  }

  // Format time to 24-hour format (14:30)
  static String formatTime24(DateTime dateTime) {
    return _time24.format(dateTime);
  }

  // Format time to 12-hour format (2:30 PM)
  static String formatTime12(DateTime dateTime) {
    return _time12.format(dateTime);
  }

  // Format time with seconds (14:30:25)
  static String formatTimeWithSeconds(DateTime dateTime) {
    return _timeWithSeconds.format(dateTime);
  }

  // Format time with seconds in 12-hour format (2:30:25 PM)
  static String formatTime12WithSeconds(DateTime dateTime) {
    return _time12WithSeconds.format(dateTime);
  }

  // Format datetime to 24-hour format (01/01/2024 14:30)
  static String formatDateTime24(DateTime dateTime) {
    return _dateTime24.format(dateTime);
  }

  // Format datetime to 12-hour format (01/01/2024 2:30 PM)
  static String formatDateTime12(DateTime dateTime) {
    return _dateTime12.format(dateTime);
  }

  // Format datetime to long format (January 01, 2024 2:30 PM)
  static String formatLongDateTime(DateTime dateTime) {
    return _longDateTime.format(dateTime);
  }

  // Get relative time (Today, Yesterday, etc.)
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow';
    } else {
      final difference = targetDate.difference(today).inDays;
      if (difference > 0 && difference <= 7) {
        return getDayName(date);
      } else if (difference < 0 && difference >= -7) {
        return getDayName(date);
      } else {
        return formatShortDate(date);
      }
    }
  }

  // Get time ago (2 hours ago, 3 days ago, etc.)
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Parse date from string (DD/MM/YYYY)
  static DateTime? parseDateDMY(String dateString) {
    try {
      return _dayMonthYear.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Parse date from ISO string (YYYY-MM-DD)
  static DateTime? parseDateISO(String dateString) {
    try {
      return _yearMonthDay.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return startOfDay(monday);
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return endOfDay(sunday);
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return endOfDay(nextMonth.subtract(const Duration(days: 1)));
  }

  // Calculate working hours between two times
  static double calculateWorkingHours(DateTime startTime, DateTime endTime) {
    final difference = endTime.difference(startTime);
    return difference.inMinutes / 60.0;
  }

  // Format duration to hours and minutes (8h 30m)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  // Get month number from name
  static int? getMonthNumber(String monthName) {
    const months = {
      'january': 1, 'jan': 1,
      'february': 2, 'feb': 2,
      'march': 3, 'mar': 3,
      'april': 4, 'apr': 4,
      'may': 5,
      'june': 6, 'jun': 6,
      'july': 7, 'jul': 7,
      'august': 8, 'aug': 8,
      'september': 9, 'sep': 9,
      'october': 10, 'oct': 10,
      'november': 11, 'nov': 11,
      'december': 12, 'dec': 12,
    };
    
    return months[monthName.toLowerCase()];
  }
}
