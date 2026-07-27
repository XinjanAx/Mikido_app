import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_local_datasource.dart';
import '../../domain/usecases/schedule_notifications_usecase.dart';

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
  (_) => FlutterLocalNotificationsPlugin(),
);

final notificationDataSourceProvider = Provider<NotificationLocalDataSource>(
  (ref) => NotificationLocalDataSource(
    ref.watch(flutterLocalNotificationsPluginProvider),
  ),
);

final scheduleNotificationsUseCaseProvider =
    Provider<ScheduleNotificationsUseCase>(
  (ref) => ScheduleNotificationsUseCase(
    ref.watch(notificationDataSourceProvider),
  ),
);

/// Inicialización de notificaciones — llamar al arrancar la app
final notificationInitProvider = FutureProvider<void>((ref) async {
  final ds = ref.watch(notificationDataSourceProvider);
  await ds.initialize();
  await ds.requestPermissions();
});
