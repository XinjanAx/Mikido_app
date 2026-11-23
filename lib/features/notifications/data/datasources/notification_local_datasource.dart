import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/constants/app_constants.dart';

class NotificationLocalDataSource {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationLocalDataSource(this._plugin);

  // Minutos de antelación para avisar antes de que empiece/termine el
  // torneo. El 0 final es el aviso justo en el momento exacto de inicio/fin
  // (no "antes de" — cuando ya llegó/venció la hora).
  static const List<int> _startOffsetsMin = [30, 10, 5, 0];
  static const List<int> _endOffsetsMin = [60, 30, 10, 5, 0];

  bool get _isSupported => !Platform.isWindows && !Platform.isLinux;

  Future<void> initialize() async {
    if (!_isSupported) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    if (!_isSupported) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    // Necesario en Android 12+ para poder programar notificaciones a una
    // hora exacta (androidScheduleMode: exactAllowWhileIdle).
    await android?.requestExactAlarmsPermission();
  }

  /// Programa todas las notificaciones de un torneo
  Future<void> scheduleTournamentNotifications({
    required String tournamentId,
    required String tournamentName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final baseStartId =
        tournamentId.hashCode.abs() + AppConstants.notifIdStartBase;
    final baseEndId = tournamentId.hashCode.abs() + AppConstants.notifIdEndBase;

    // Notificaciones de inicio
    final startMessages = [
      'Faltan 30 minutos para iniciar',
      'Faltan 10 minutos para iniciar',
      '¡Faltan 5 minutos para iniciar!',
      '¡La categoría ha comenzado!',
    ];

    for (var i = 0; i < _startOffsetsMin.length; i++) {
      final notifTime =
          startDate.subtract(Duration(minutes: _startOffsetsMin[i]));
      if (notifTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: baseStartId + i,
          title: tournamentName,
          body: startMessages[i],
          scheduledDate: notifTime,
        );
      }
    }

    // Notificaciones de finalización
    final endMessages = [
      'Falta 1 hora para finalizar',
      'Faltan 30 minutos para finalizar',
      'Faltan 10 minutos para finalizar',
      '¡Faltan 5 minutos para finalizar!',
      'La categoría ya debió haber finalizado',
    ];

    for (var i = 0; i < _endOffsetsMin.length; i++) {
      final notifTime = endDate.subtract(Duration(minutes: _endOffsetsMin[i]));
      if (notifTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: baseEndId + i,
          title: tournamentName,
          body: endMessages[i],
          scheduledDate: notifTime,
        );
      }
    }
  }

  Future<void> cancelTournamentNotifications(String tournamentId) async {
    if (!_isSupported) return;
    final baseStartId =
        tournamentId.hashCode.abs() + AppConstants.notifIdStartBase;
    final baseEndId = tournamentId.hashCode.abs() + AppConstants.notifIdEndBase;

    for (var i = 0; i < _startOffsetsMin.length; i++) {
      await _plugin.cancel(baseStartId + i);
    }
    for (var i = 0; i < _endOffsetsMin.length; i++) {
      await _plugin.cancel(baseEndId + i);
    }
  }

  Future<void> cancelAll() async {
    if (!_isSupported) return;
    await _plugin.cancelAll();
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isSupported) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'torneo_channel',
          'Torneos MIKIDO',
          channelDescription: 'Notificaciones de torneos deportivos',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
