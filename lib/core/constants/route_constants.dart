class RouteConstants {
  RouteConstants._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Mesas (pantalla de inicio)
  static const String mesas = '/mesas';
  static const String mesaCreate = '/mesas/create';
  static const String mesaDetail = '/mesas/:id';
  static const String mesaEdit = '/mesas/:id/edit';
  static const String mesaQueue = '/mesas/:id/orden';

  /// Registro de resultados en orden (solo admin).
  static const String mesaLive = '/mesas/:id/en-vivo';

  /// Id de ruta para las categorías que todavía no tienen mesa (datos
  /// anteriores a las mesas).
  static const String noMesaId = 'sin-mesa';

  // Categorías (en el código y la base siguen llamándose "tournaments")
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
