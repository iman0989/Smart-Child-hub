import 'package:intl/intl.dart';

/// Formatting helpers for dates, times, durations and numbers.
class Formatters {
  Formatters._();

  static final NumberFormat _hours = NumberFormat('0.#');
  static final NumberFormat _number = NumberFormat.decimalPattern();

  /// Formats a [DateTime] as "Mon, 3 Aug 2026".
  static String fullDate(DateTime date) => DateFormat('EEE, d MMM yyyy').format(date);

  /// Formats a [DateTime] as "3 Aug 2026".
  static String mediumDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  /// Formats a [DateTime] as "Mon 3 Aug".
  static String shortDate(DateTime date) => DateFormat('EEE d MMM').format(date);

  /// Formats a [DateTime] as "14:30" using a 24h clock.
  static String timeOfDay(DateTime date) => DateFormat('HH:mm').format(date);

  /// Formats hour/minute integers as "8:30 PM" using a 12h clock.
  static String hourMinute(int hour, int minute) {
    final String h = hour == 0 ? '12' : (hour > 12 ? (hour - 12).toString() : hour.toString());
    final String m = minute.toString().padLeft(2, '0');
    final String ap = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }

  /// Formats a [Duration] as "9 h 30 m".
  static String duration(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes % 60;
    if (h == 0) return '$m m';
    if (m == 0) return '$h h';
    return '$h h $m m';
  }

  /// Formats an hour count as "9.5 h".
  static String hours(double value) => '${_hours.format(value)} h';

  /// Relative label like "2 h ago", "Just now".
  static String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} m ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return mediumDate(date);
  }

  /// Percent helper: 0.67 -> "67%".
  static String percent(double value) => '${(value * 100).round()}%';

  /// Plain number grouping, e.g. 12500 -> "12,500".
  static String number(num value) => _number.format(value);

  /// Short weekday label ("Mon").
  static String weekday(DateTime date) => DateFormat('E').format(date);

  /// Full weekday ("Monday").
  static String weekdayFull(DateTime date) => DateFormat('EEEE').format(date);

  /// Month short label ("Aug").
  static String monthShort(DateTime date) => DateFormat('MMM').format(date);

  /// Backend `date` field format: "2026-08-06".
  static String apiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Backend datetime field format: "2026-08-06 14:30:00".
  static String apiDateTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${apiDate(date)} ${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }
}
