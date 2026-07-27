class SupabaseConstants {
  SupabaseConstants._();

  static const String supabaseUrl = 'https://sneddtvtakcbjtsirlrl.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_Cu0wJyGIfpqn4USHJ-wD9Q_UhIlKIov';

  // Nombres de tablas
  static const String tournamentsTable = 'tournaments';
  static const String categoriesTable = 'categories';
  static const String playersTable = 'players';
  static const String matchesTable = 'matches';
  static const String resultsTable = 'results';
  static const String standingsTable = 'standings';
  static const String enrollmentsTable = 'enrollments';
  static const String profilesTable = 'profiles';

  // Canales Realtime
  static const String standingsChannel = 'standings-channel';
  static const String matchesChannel = 'matches-channel';
  static const String tournamentChannel = 'tournament-channel';
}
