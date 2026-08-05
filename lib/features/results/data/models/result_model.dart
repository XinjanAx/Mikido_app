import '../../../../core/extensions/datetime_extensions.dart';
import '../../domain/entities/result_entity.dart';

class ResultModel extends ResultEntity {
  const ResultModel({
    required super.id,
    required super.matchId,
    required super.tournamentId,
    required super.homePlayerId,
    required super.awayPlayerId,
    required super.homeScore,
    required super.awayScore,
    super.notes,
    required super.registeredBy,
    required super.registeredAt,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) => ResultModel(
        id: json['id'] as String,
        matchId: json['match_id'] as String,
        tournamentId: json['tournament_id'] as String,
        homePlayerId: json['home_player_id'] as String,
        awayPlayerId: json['away_player_id'] as String,
        homeScore: json['home_score'] as int,
        awayScore: json['away_score'] as int,
        notes: json['notes'] as String?,
        registeredBy: json['registered_by'] as String,
        registeredAt: DateTime.parse(json['registered_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'match_id': matchId,
        'tournament_id': tournamentId,
        'home_player_id': homePlayerId,
        'away_player_id': awayPlayerId,
        'home_score': homeScore,
        'away_score': awayScore,
        'notes': notes,
        'registered_by': registeredBy,
        'registered_at': registeredAt.toApiDateTime(),
      };

  Map<String, dynamic> toInsertJson() {
    final j = toJson();
    j.remove('id');
    return j;
  }

  static ResultModel fromEntity(ResultEntity e) => ResultModel(
        id: e.id,
        matchId: e.matchId,
        tournamentId: e.tournamentId,
        homePlayerId: e.homePlayerId,
        awayPlayerId: e.awayPlayerId,
        homeScore: e.homeScore,
        awayScore: e.awayScore,
        notes: e.notes,
        registeredBy: e.registeredBy,
        registeredAt: e.registeredAt,
      );
}
