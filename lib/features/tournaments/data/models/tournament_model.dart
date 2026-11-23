import '../../../../core/extensions/datetime_extensions.dart';
import '../../domain/entities/tournament_entity.dart';

class TournamentModel extends TournamentEntity {
  const TournamentModel({
    required super.id,
    required super.name,
    required super.mode,
    required super.status,
    super.description,
    required super.startDate,
    required super.endDate,
    required super.createdBy,
    super.createdAt,
    super.mesaId,
    super.color,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: json['mode'] as String,
      status: json['status'] as String? ?? 'draft',
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdBy: json['created_by'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      mesaId: json['mesa_id'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mode': mode,
        'status': status,
        'description': description,
        'start_date': startDate.toApiDateTime(),
        'end_date': endDate.toApiDateTime(),
        'created_by': createdBy,
        'mesa_id': mesaId,
        'color': color,
      };

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  static TournamentModel fromEntity(TournamentEntity e) => TournamentModel(
        id: e.id,
        name: e.name,
        mode: e.mode,
        status: e.status,
        description: e.description,
        startDate: e.startDate,
        endDate: e.endDate,
        createdBy: e.createdBy,
        createdAt: e.createdAt,
        mesaId: e.mesaId,
        color: e.color,
      );
}
