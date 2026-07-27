class AppConstants {
  AppConstants._();

  // Modalidades de torneo
  static const String tournamentModeGroups = 'groups';
  static const String tournamentModeElimination = 'elimination';
  static const String tournamentModeLeague = 'league';

  // Roles de usuario
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Estado de torneo
  static const String statusDraft = 'draft';
  static const String statusActive = 'active';
  static const String statusFinished = 'finished';
  static const String statusCancelled = 'cancelled';

  // Estado de partido
  static const String matchStatusPending = 'pending';
  static const String matchStatusInProgress = 'in_progress';
  static const String matchStatusFinished = 'finished';

  // Notificaciones - minutos antes
  static const int notifBeforeStart60 = 60;
  static const int notifBeforeStart30 = 30;
  static const int notifBeforeStart10 = 10;
  static const int notifBeforeEnd60 = 60;
  static const int notifBeforeEnd30 = 30;
  static const int notifBeforeEnd10 = 10;

  // IDs de notificación (base, se suman al tournamentId hashCode)
  static const int notifIdStartBase = 1000;
  static const int notifIdEndBase = 2000;

  // Paginación
  static const int pageSize = 20;
}
