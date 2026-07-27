import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toDisplayDate() => DateFormat('dd/MM/yyyy').format(this);

  String toDisplayDateTime() => DateFormat('dd/MM/yyyy HH:mm').format(this);

  String toDisplayTime() => DateFormat('HH:mm').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isPast => isBefore(DateTime.now());

  bool get isFuture => isAfter(DateTime.now());

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}
