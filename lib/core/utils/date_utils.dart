import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('HH:mm').format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.isNegative) {
      final past = now.difference(date);
      if (past.inDays > 0) return 'Hace ${past.inDays} día(s)';
      if (past.inHours > 0) return 'Hace ${past.inHours} hora(s)';
      return 'Hace ${past.inMinutes} minuto(s)';
    }
    if (diff.inDays > 0) return 'En ${diff.inDays} día(s)';
    if (diff.inHours > 0) return 'En ${diff.inHours} hora(s)';
    return 'En ${diff.inMinutes} minuto(s)';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  /// Devuelve el rango legible de un torneo
  static String tournamentRange(DateTime start, DateTime end) =>
      '${formatDate(start)} – ${formatDate(end)}';
}
