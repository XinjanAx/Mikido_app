/// Encuentro visto por el planificador de la mesa: solo lo necesario para
/// decidir el turno (quién juega, de qué categoría y ronda, y si ya se
/// jugó). Los BYE nunca llegan acá — no ocupan turno.
class ScheduleItem {
  final String id;
  final String tournamentId;
  final String? round;
  final String homePlayerId;
  final String awayPlayerId;

  /// Ya jugado (o en curso): su lugar en la cola queda fijo.
  final bool isPlayed;

  const ScheduleItem({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.homePlayerId,
    required this.awayPlayerId,
    required this.isPlayed,
  });

  bool sharesPlayerWith(ScheduleItem other) =>
      homePlayerId == other.homePlayerId ||
      homePlayerId == other.awayPlayerId ||
      awayPlayerId == other.homePlayerId ||
      awayPlayerId == other.awayPlayerId;

  bool involves(String playerId) =>
      homePlayerId == playerId || awayPlayerId == playerId;
}

/// Orden global de encuentros dentro de una mesa — lógica pura, sin base
/// de datos (la persistencia vive en MesaScheduleService).
///
/// Reglas:
/// - **Descanso**: un encuentro no debería compartir competidor con el
///   inmediatamente anterior. Cuando no hay ninguna opción que lo cumpla
///   (típico del final de una eliminación con pocos competidores), la regla
///   se relaja y se toma igual el siguiente.
/// - **Estabilidad**: el algoritmo solo COLOCA encuentros nuevos; nunca
///   reordena los que ya estaban en la cola. Los existentes conservan su
///   orden relativo (sus números pueden correrse si algo se inserta antes).
/// - Nadie edita el orden a mano.
class MesaScheduler {
  MesaScheduler._();

  /// Índice desde el cual se puede insertar: el primer encuentro de la cola
  /// que todavía no se jugó. Todo lo anterior ya pasó y queda fijo.
  static int _firstPendingIndex(List<ScheduleItem> queue) {
    final idx = queue.indexWhere((m) => !m.isPlayed);
    return idx == -1 ? queue.length : idx;
  }

  static bool _conflict(ScheduleItem? a, ScheduleItem? b) =>
      a != null && b != null && a.sharesPlayerWith(b);

  /// Fase de un encuentro para decidir qué encuentros de una categoría
  /// nueva pueden ir en cualquier orden entre sí: todos los grupos son una
  /// misma fase ("Grupo A" y "Grupo B" se intercalan libremente), mientras
  /// que en liga cada jornada va después de la anterior.
  static String _phaseOf(ScheduleItem m) {
    final r = m.round ?? '';
    return r.startsWith('Grupo ') ? 'Grupos' : r;
  }

  /// Turnos que lleva sin jugar cada competidor del encuentro, mirando
  /// hacia atrás desde el final de [placed] (más grande = más descansado).
  static int _restScore(ScheduleItem item, List<ScheduleItem> placed) {
    int restOf(String playerId) {
      for (var i = placed.length - 1; i >= 0; i--) {
        if (placed[i].involves(playerId)) return placed.length - 1 - i;
      }
      return 1 << 20; // todavía no jugó en esta mesa
    }

    final a = restOf(item.homePlayerId);
    final b = restOf(item.awayPlayerId);
    return a < b ? a : b;
  }

  /// Categoría nueva (fixture recién generado) en una mesa que puede tener
  /// ya otras categorías en marcha: sus encuentros se intercalan con los
  /// pendientes de la cola de forma proporcional (las categorías avanzan
  /// parejas), respetando el descanso. Los pendientes que ya estaban no
  /// cambian su orden relativo entre sí.
  ///
  /// [newItems] debe venir en el orden de la categoría (match_number).
  /// Devuelve la cola completa en el orden nuevo.
  static List<ScheduleItem> interleave({
    required List<ScheduleItem> queue,
    required List<ScheduleItem> newItems,
  }) {
    final start = _firstPendingIndex(queue);
    final result = <ScheduleItem>[...queue.sublist(0, start)];
    final tail = queue.sublist(start);
    final pendingNew = [...newItems];

    final totalTail = tail.length;
    final totalNew = pendingNew.length;
    var takenTail = 0;
    var takenNew = 0;

    while (takenTail < totalTail || pendingNew.isNotEmpty) {
      final last = result.isEmpty ? null : result.last;
      final tailHead = takenTail < totalTail ? tail[takenTail] : null;

      // Candidatos de la categoría nueva: los de su fase actual.
      final phase = pendingNew.isEmpty ? null : _phaseOf(pendingNew.first);
      final window = pendingNew.where((m) => _phaseOf(m) == phase).toList();

      ScheduleItem? bestNew({required bool requireRest}) {
        ScheduleItem? best;
        var bestScore = -1;
        for (final c in window) {
          if (requireRest && _conflict(last, c)) continue;
          // Preferir el que no choque con lo que viene después de la cola
          // existente, y después el de competidores más descansados.
          final score =
              _restScore(c, result) * 2 + (_conflict(c, tailHead) ? 0 : 1);
          if (score > bestScore) {
            best = c;
            bestScore = score;
          }
        }
        return best;
      }

      final tailOk = tailHead != null && !_conflict(last, tailHead);
      final newOk = bestNew(requireRest: true);

      // Proporción avanzada de cada fuente: se toma de la más atrasada.
      final fracTail = totalTail == 0 ? 1.0 : takenTail / totalTail;
      final fracNew = totalNew == 0 ? 1.0 : takenNew / totalNew;
      final preferNew =
          pendingNew.isNotEmpty && (tailHead == null || fracNew <= fracTail);

      ScheduleItem pick;
      bool fromNew;
      if (preferNew && newOk != null) {
        pick = newOk;
        fromNew = true;
      } else if (!preferNew && tailOk) {
        pick = tailHead;
        fromNew = false;
      } else if (newOk != null) {
        pick = newOk;
        fromNew = true;
      } else if (tailOk) {
        pick = tailHead;
        fromNew = false;
      } else {
        // Nadie cumple el descanso: se relaja la regla.
        if (preferNew) {
          pick = bestNew(requireRest: false)!;
          fromNew = true;
        } else {
          pick = tailHead!;
          fromNew = false;
        }
      }

      result.add(pick);
      if (fromNew) {
        pendingNew.remove(pick);
        takenNew++;
      } else {
        takenTail++;
      }
    }
    return result;
  }

  /// Ronda nueva de eliminación (semifinal, final, 3er puesto...) de una
  /// categoría que ya está en juego: cada encuentro va al primer hueco
  /// válido de la cola — después del último encuentro ya jugado de su
  /// misma categoría (de ahí salen sus competidores) y del primer
  /// pendiente de la mesa, sin quedar pegado a un encuentro que comparta
  /// competidor ni antes ni después. Lo que venía detrás se corre un
  /// lugar. Si no hay hueco que cumpla el descanso, va al final.
  ///
  /// Los encuentros nuevos conservan entre sí el orden de [newItems].
  static List<ScheduleItem> insertEarliest({
    required List<ScheduleItem> queue,
    required List<ScheduleItem> newItems,
  }) {
    final result = [...queue];
    var minPos = _firstPendingIndex(result);

    for (final item in newItems) {
      final lastOwnPlayed = result.lastIndexWhere(
          (m) => m.tournamentId == item.tournamentId && m.isPlayed);
      if (lastOwnPlayed + 1 > minPos) minPos = lastOwnPlayed + 1;

      var pos = -1;
      for (var p = minPos; p <= result.length; p++) {
        final prev = p > 0 ? result[p - 1] : null;
        final next = p < result.length ? result[p] : null;
        if (!_conflict(prev, item) && !_conflict(item, next)) {
          pos = p;
          break;
        }
      }
      if (pos == -1) pos = result.length;

      result.insert(pos, item);
      minPos = pos + 1;
    }
    return result;
  }
}
