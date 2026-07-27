import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class MatchEntity extends Equatable {
  final String id;
  final String tournamentId;
  final String categoryId;
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

  const MatchEntity({
    required this.id,
    required this.tournamentId,
    required this.categoryId,
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
  });

  bool get isFinished => status == AppConstants.matchStatusFinished;
  bool get isPending => status == AppConstants.matchStatusPending;

  String? get winner {
    if (!isFinished) return null;
    if (homeScore == null || awayScore == null) return null;
    if (homeScore! > awayScore!) return homePlayerId;
    if (awayScore! > homeScore!) return awayPlayerId;
    return null; // empate
  }

  @override
  List<Object?> get props => [
        id, tournamentId, categoryId, homePlayerId, awayPlayerId,
        homeScore, awayScore, status, scheduledAt, round, matchNumber
      ];
}
