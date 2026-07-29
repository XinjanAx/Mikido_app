class SupabaseConstants {
  SupabaseConstants._();

  static const String supabaseUrl = 'https://sbjcxjvyyaesfkrtldip.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_Vg-FlgaDmbYwfJGSxVkoEQ_jRDpdXMd';

  // Nombres de tablas
  static const String tournamentsTable = 'tournaments';
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
