import 'package:equatable/equatable.dart';

class StandingEntity extends Equatable {
  final String id;
  final String tournamentId;
  final String playerId;
  final String playerName;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  const StandingEntity({
    required this.id,
    required this.tournamentId,
    required this.playerId,
    required this.playerName,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  @override
  List<Object?> get props => [
        id, tournamentId, playerId, playerName,
        played, won, drawn, lost, goalsFor, goalsAgainst, points
      ];
}
