import '../../domain/entities/standing_entity.dart';

class StandingModel extends StandingEntity {
  const StandingModel({
    required super.id,
    required super.tournamentId,
    required super.categoryId,
    required super.playerId,
    required super.playerName,
    required super.played,
    required super.won,
    required super.drawn,
    required super.lost,
    required super.goalsFor,
    required super.goalsAgainst,
    required super.points,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) => StandingModel(
        id: json['id'] as String,
        tournamentId: json['tournament_id'] as String,
        categoryId: json['category_id'] as String,
        playerId: json['player_id'] as String,
        playerName: json['player_name'] as String? ?? '',
        played: json['played'] as int? ?? 0,
        won: json['won'] as int? ?? 0,
        drawn: json['drawn'] as int? ?? 0,
        lost: json['lost'] as int? ?? 0,
        goalsFor: json['goals_for'] as int? ?? 0,
        goalsAgainst: json['goals_against'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournament_id': tournamentId,
        'category_id': categoryId,
        'player_id': playerId,
        'player_name': playerName,
        'played': played,
        'won': won,
        'drawn': drawn,
        'lost': lost,
        'goals_for': goalsFor,
        'goals_against': goalsAgainst,
        'points': points,
      };
}
