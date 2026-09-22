/// How often a playable puzzle rotates. Streaks always stay on calendar days.
abstract final class PlayPeriod {
  static const daily = Duration(days: 1);
  static const minute = Duration(minutes: 1);

  static bool isSubDaily(Duration period) => period < const Duration(days: 1);

  static DateTime bucket(DateTime date, Duration period) {
    if (isSubDaily(period)) {
      return DateTime(date.year, date.month, date.day, date.hour, date.minute);
    }
    return DateTime(date.year, date.month, date.day);
  }

  static String id(DateTime date, Duration period) {
    final b = bucket(date, period);
    final y = b.year.toString().padLeft(4, '0');
    final m = b.month.toString().padLeft(2, '0');
    final d = b.day.toString().padLeft(2, '0');
    if (!isSubDaily(period)) return '$y$m$d';
    final hour = b.hour.toString().padLeft(2, '0');
    final minute = b.minute.toString().padLeft(2, '0');
    return '$y$m$d$hour$minute';
  }
}
