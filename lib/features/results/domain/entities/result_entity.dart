import 'package:equatable/equatable.dart';

class ResultEntity extends Equatable {
  final String id;
  final String matchId;
  final String tournamentId;
  final String homePlayerId;
  final String awayPlayerId;
  final int homeScore;
  final int awayScore;
  final String? notes;
  final String registeredBy;
  final DateTime registeredAt;

  const ResultEntity({
    required this.id,
    required this.matchId,
    required this.tournamentId,
    required this.homePlayerId,
    required this.awayPlayerId,
    required this.homeScore,
    required this.awayScore,
    this.notes,
    required this.registeredBy,
    required this.registeredAt,
  });

  String? get winnerId {
    if (homeScore > awayScore) return homePlayerId;
    if (awayScore > homeScore) return awayPlayerId;
    return null; // empate
  }

  bool get isDraw => homeScore == awayScore;

  @override
  List<Object?> get props => [
        id, matchId, tournamentId, homePlayerId, awayPlayerId,
        homeScore, awayScore, notes, registeredBy, registeredAt,
      ];
}
