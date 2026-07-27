import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.tournamentId,
    required super.categoryId,
    required super.homePlayerId,
    required super.awayPlayerId,
    required super.homePlayerName,
    required super.awayPlayerName,
    super.homeScore,
    super.awayScore,
    required super.status,
    super.scheduledAt,
    super.round,
    super.matchNumber,
    super.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        id: json['id'] as String,
        tournamentId: json['tournament_id'] as String,
        categoryId: json['category_id'] as String,
        homePlayerId: json['home_player_id'] as String,
        awayPlayerId: json['away_player_id'] as String,
        homePlayerName: json['home_player_name'] as String? ?? '',
        awayPlayerName: json['away_player_name'] as String? ?? '',
        homeScore: json['home_score'] as int?,
        awayScore: json['away_score'] as int?,
        status: json['status'] as String? ?? 'pending',
        scheduledAt: json['scheduled_at'] != null
            ? DateTime.tryParse(json['scheduled_at'] as String)
            : null,
        round: json['round'] as String?,
        matchNumber: json['match_number'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournament_id': tournamentId,
        'category_id': categoryId,
        'home_player_id': homePlayerId,
        'away_player_id': awayPlayerId,
        'home_player_name': homePlayerName,
        'away_player_name': awayPlayerName,
        'home_score': homeScore,
        'away_score': awayScore,
        'status': status,
        'scheduled_at': scheduledAt?.toIso8601String(),
        'round': round,
        'match_number': matchNumber,
      };

  Map<String, dynamic> toInsertJson() {
    final j = toJson();
    j.remove('id');
    return j;
  }
}
