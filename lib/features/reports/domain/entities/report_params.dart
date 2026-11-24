class ReportParams {
  final String tournamentName;
  final String category;
  final String mode; // groups | elimination | league
  final List<Map<String, dynamic>> standings;
  final List<Map<String, dynamic>> matches;

  /// Solo en modo grupos: posiciones ya agrupadas y ordenadas exactamente
  /// como la pantalla real de posiciones (puntos, diferencia de gol,
  /// desempate manual) — clave = nombre del grupo ("Grupo A", ...). Evita
  /// que el PDF tenga que recalcular la tabla desde los partidos, lo que
  /// perdía el desempate manual que el admin ya había resuelto.
  final Map<String, List<Map<String, dynamic>>>? groupedStandings;

  /// Color de la categoría, '#RRGGBB' (ver CategoryColors). null = sin color.
  final String? categoryColor;

  /// Nombre de la mesa de la categoría (null en datos sin mesa).
  final String? mesaName;

  const ReportParams({
    required this.tournamentName,
    required this.category,
    required this.mode,
    required this.standings,
    required this.matches,
    this.groupedStandings,
    this.categoryColor,
    this.mesaName,
  });
}
