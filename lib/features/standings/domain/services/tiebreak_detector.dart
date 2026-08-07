import '../entities/standing_entity.dart';

/// Un grupo de 2+ jugadores empatados en puntos y diferencia (los dos
/// criterios de [orden ya aplicados en la consulta de standings]) — no hay
/// forma automática de decidir quién queda arriba, así que el admin lo
/// resuelve a mano antes de finalizar el torneo.
class TiedGroup {
  final String? groupLabel;
  final List<StandingEntity> members;

  const TiedGroup({this.groupLabel, required this.members});
}

/// Detecta empates sin resolver en una lista de posiciones ya ordenada
/// (puntos desc, diferencia desc). Con [groupOf] nulo compara a todos los
/// jugadores entre sí (modo liga); con [groupOf] no nulo (mapa
/// `playerId -> "Grupo A"`, modo grupos) solo compara dentro de cada grupo
/// — dos jugadores de grupos distintos nunca "empatan" entre sí.
List<TiedGroup> detectTiedGroups(
  List<StandingEntity> standings, {
  Map<String, String>? groupOf,
}) {
  final buckets = <String, List<StandingEntity>>{};
  for (final s in standings) {
    final scope = groupOf == null ? '' : (groupOf[s.playerId] ?? 'Sin grupo');
    final key = '$scope|${s.points}|${s.goalDifference}';
    buckets.putIfAbsent(key, () => []).add(s);
  }

  final tied = <TiedGroup>[];
  for (final members in buckets.values) {
    if (members.length < 2) continue;
    tied.add(TiedGroup(
      groupLabel: groupOf == null ? null : (groupOf[members.first.playerId] ?? 'Sin grupo'),
      members: members,
    ));
  }

  // El empate por el puesto más alto se muestra primero.
  tied.sort((a, b) => b.members.first.points.compareTo(a.members.first.points));
  return tied;
}
