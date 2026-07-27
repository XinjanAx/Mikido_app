import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/constants/app_constants.dart';

class NotificationLocalDataSource {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationLocalDataSource(this._plugin);

  Future<void> initialize() async {
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
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Programa todas las notificaciones de un torneo
  Future<void> scheduleTournamentNotifications({
    required String tournamentId,
    required String tournamentName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final baseStartId = tournamentId.hashCode.abs() + AppConstants.notifIdStartBase;
    final baseEndId = tournamentId.hashCode.abs() + AppConstants.notifIdEndBase;

    // Notificaciones de inicio
    final startOffsets = [60, 30, 10, 0];
    final startMessages = [
      'Falta 1 hora para iniciar',
      'Faltan 30 minutos para iniciar',
      'Faltan 10 minutos para iniciar',
      '¡El torneo comienza ahora!',
    ];

    for (var i = 0; i < startOffsets.length; i++) {
      final notifTime = startDate.subtract(Duration(minutes: startOffsets[i]));
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
    final endOffsets = [60, 30, 10, 0];
    final endMessages = [
      'Falta 1 hora para finalizar',
      'Faltan 30 minutos para finalizar',
      'Faltan 10 minutos para finalizar',
      '¡El torneo ha finalizado!',
    ];

    for (var i = 0; i < endOffsets.length; i++) {
      final notifTime = endDate.subtract(Duration(minutes: endOffsets[i]));
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
    final baseStartId = tournamentId.hashCode.abs() + AppConstants.notifIdStartBase;
    final baseEndId = tournamentId.hashCode.abs() + AppConstants.notifIdEndBase;

    for (var i = 0; i < 4; i++) {
      await _plugin.cancel(baseStartId + i);
      await _plugin.cancel(baseEndId + i);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
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
