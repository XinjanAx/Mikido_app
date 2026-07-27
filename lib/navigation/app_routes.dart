/// Nombres de rutas para usar con GoRouter (context.goNamed / context.pushNamed).
/// Complementa [RouteConstants] que define los paths.
class AppRoutes {
  AppRoutes._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';

  // Torneos
  static const String tournamentList = 'tournament-list';
  static const String tournamentCreate = 'tournament-create';
  static const String tournamentDetail = 'tournament-detail';
  static const String tournamentEdit = 'tournament-edit';

  // Categorías
  static const String categoryList = 'category-list';
  static const String categoryCreate = 'category-create';

  // Participantes
  static const String playerList = 'player-list';
  static const String playerDetail = 'player-detail';
  static const String playerCreate = 'player-create';
  static const String playerEdit = 'player-edit';
  static const String playerEnroll = 'player-enroll';

  // Fixture
  static const String fixture = 'fixture';
  static const String bracket = 'bracket';

  // Resultados
  static const String resultEntry = 'result-entry';

  // Posiciones
  static const String standings = 'standings';

  // Reportes
  static const String reports = 'reports';
}
