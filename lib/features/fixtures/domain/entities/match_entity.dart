import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class MatchEntity extends Equatable {
  final String id;
  final String tournamentId;
  final String homePlayerId;
  final String awayPlayerId;
  final String homePlayerName;
  final String awayPlayerName;
  final int? homeScore;
  final int? awayScore;
  final String status; // pending | in_progress | finished
  final DateTime? scheduledAt;
  final String? round; // "Grupo A", "Cuartos", "Semifinal", "Final", "Jornada 1"
  final int? matchNumber;
  final DateTime? createdAt;

  /// Turno global dentro de la mesa (ver MesaScheduleService). null en
  /// los BYE, que no ocupan turno.
  final int? mesaOrder;

  const MatchEntity({
    required this.id,
    required this.tournamentId,
    required this.homePlayerId,
    required this.awayPlayerId,
    required this.homePlayerName,
    required this.awayPlayerName,
    this.homeScore,
    this.awayScore,
    required this.status,
    this.scheduledAt,
    this.round,
    this.matchNumber,
    this.createdAt,
    this.mesaOrder,
  });

  bool get isFinished => status == AppConstants.matchStatusFinished;
  bool get isPending => status == AppConstants.matchStatusPending;

  /// Partido "bye": el jugador avanza automáticamente porque el número de
  /// participantes de la ronda era impar (mismo jugador en ambos lados, o
  /// rival marcado como 'BYE').
  bool get isBye =>
      awayPlayerName.toUpperCase() == 'BYE' ||
      (homePlayerId.isNotEmpty && homePlayerId == awayPlayerId);

  String? get winner {
    if (!isFinished) return null;
    if (homeScore == null || awayScore == null) return null;
    if (homeScore! > awayScore!) return homePlayerId;
    if (awayScore! > homeScore!) return awayPlayerId;
    return null; // empate
  }

  @override
  List<Object?> get props => [
        id, tournamentId, homePlayerId, awayPlayerId,
        homeScore, awayScore, status, scheduledAt, round, matchNumber, mesaOrder
      ];
}
