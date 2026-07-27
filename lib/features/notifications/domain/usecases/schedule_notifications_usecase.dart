import '../../../notifications/data/datasources/notification_local_datasource.dart';

class ScheduleNotificationsUseCase {
  final NotificationLocalDataSource _dataSource;
  const ScheduleNotificationsUseCase(this._dataSource);

  Future<void> schedule({
    required String tournamentId,
    required String tournamentName,
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      _dataSource.scheduleTournamentNotifications(
        tournamentId: tournamentId,
        tournamentName: tournamentName,
        startDate: startDate,
        endDate: endDate,
      );

  Future<void> cancel(String tournamentId) =>
      _dataSource.cancelTournamentNotifications(tournamentId);
}
