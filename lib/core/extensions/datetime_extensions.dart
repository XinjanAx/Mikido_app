import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Serializa a UTC explícito para Supabase. `toIso8601String()` solo no
  /// alcanza: en un `DateTime` local (no UTC) no agrega offset, y Postgres
  /// interpreta esa cadena "flotante" con la timezone de la sesión (UTC por
  /// defecto en Supabase) en vez de la hora local del dispositivo — corrompe
  /// la hora guardada por el offset de la zona horaria del usuario.
  String toApiDateTime() => toUtc().toIso8601String();

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
