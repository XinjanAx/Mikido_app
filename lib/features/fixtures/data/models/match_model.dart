import '../../../../core/extensions/datetime_extensions.dart';
import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.tournamentId,
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
    super.mesaOrder,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        id: json['id'] as String,
        tournamentId: json['tournament_id'] as String,
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
        mesaOrder: json['mesa_order'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournament_id': tournamentId,
        'home_player_id': homePlayerId,
        'away_player_id': awayPlayerId,
        'home_player_name': homePlayerName,
        'away_player_name': awayPlayerName,
        'home_score': homeScore,
        'away_score': awayScore,
        'status': status,
        'scheduled_at': scheduledAt?.toApiDateTime(),
        'round': round,
        'match_number': matchNumber,
        'mesa_order': mesaOrder,
      };

  /// Copia con otro turno de mesa (lo único que cambia MesaScheduleService).
  MatchModel withMesaOrder(int? order) => MatchModel(
        id: id,
        tournamentId: tournamentId,
        homePlayerId: homePlayerId,
        awayPlayerId: awayPlayerId,
        homePlayerName: homePlayerName,
        awayPlayerName: awayPlayerName,
        homeScore: homeScore,
        awayScore: awayScore,
        status: status,
        scheduledAt: scheduledAt,
        round: round,
        matchNumber: matchNumber,
        createdAt: createdAt,
        mesaOrder: order,
      );

  Map<String, dynamic> toInsertJson() {
    final j = toJson();
    j.remove('id');
    return j;
  }
}
