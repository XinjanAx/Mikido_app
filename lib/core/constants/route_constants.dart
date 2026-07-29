class RouteConstants {
  RouteConstants._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Torneos
  static const String tournaments = '/tournaments';
  static const String tournamentDetail = '/tournaments/:id';
  static const String tournamentCreate = '/tournaments/create';
  static const String tournamentEdit = '/tournaments/:id/edit';

  // Participantes
  static const String players = '/players';
  static const String playerDetail = '/players/:id';
  static const String playerCreate = '/players/create';
  static const String playerEdit = '/players/:id/edit';
  static const String playerEnroll = '/tournaments/:id/enroll';

  // Fixtures
  static const String fixtures = '/tournaments/:id/fixtures';
  static const String bracket = '/tournaments/:id/bracket';

  // Resultados
  static const String resultEntry = '/matches/:id/result';

  // Clasificaciones
  static const String standings = '/tournaments/:id/standings';

  // Reportes
  static const String reports = '/tournaments/:id/reports';
}
