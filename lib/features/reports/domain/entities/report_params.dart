class ReportParams {
  final String tournamentName;
  final String category;
  final String mode; // groups | elimination | league
  final List<Map<String, dynamic>> standings;
  final List<Map<String, dynamic>> matches;

  const ReportParams({
    required this.tournamentName,
    required this.category,
    required this.mode,
    required this.standings,
    required this.matches,
  });
}
