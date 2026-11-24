import '../../../../core/constants/app_constants.dart';
import '../../../fixtures/domain/entities/match_entity.dart';

/// Total FINAL de encuentros de una mesa (para el contador "X de Y"), aunque
/// en eliminación todavía no existan las rondas siguientes.
///
/// - Liga / Grupos: todos sus encuentros ya existen → se cuentan tal cual.
/// - Eliminación: con n competidores siempre hay n − 1 encuentros reales
///   (los BYE no cuentan), más 1 por el 3er puesto cuando corresponde.
///   El cuadro del club pone los BYE solo en la primera ronda, así que las
///   semifinales tienen 4 competidores reales — y por lo tanto 3er puesto —
///   siempre que n ≥ 4 (con 3, una "semifinal" es BYE y no hay 3er puesto).
///
/// [allMatches] son todos los encuentros de la mesa, incluidos los BYE (de
/// ahí salen todos los competidores de cada categoría). [modeOf] da la
/// modalidad de cada categoría (null si no se conoce: se cuenta tal cual).
class MesaProgress {
  MesaProgress._();

  static int projectedTotal(
    List<MatchEntity> allMatches,
    String? Function(String tournamentId) modeOf,
  ) {
    final byCategory = <String, List<MatchEntity>>{};
    for (final m in allMatches) {
      byCategory.putIfAbsent(m.tournamentId, () => []).add(m);
    }

    var total = 0;
    for (final entry in byCategory.entries) {
      final matches = entry.value;
      final real = matches.where((m) => !m.isBye).length;
      if (modeOf(entry.key) != AppConstants.tournamentModeElimination) {
        total += real;
        continue;
      }
      final players = <String>{
        for (final m in matches) ...[
          if (m.homePlayerId.isNotEmpty) m.homePlayerId,
          if (m.awayPlayerId.isNotEmpty) m.awayPlayerId,
        ],
      };
      final n = players.length;
      final projected = n < 2 ? 0 : (n - 1) + (n >= 4 ? 1 : 0);
      // Por las dudas (datos viejos o raros): nunca menos de lo que existe.
      total += projected > real ? projected : real;
    }
    return total;
  }
}
