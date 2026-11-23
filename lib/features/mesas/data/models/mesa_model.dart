import '../../domain/entities/mesa_entity.dart';

class MesaModel extends MesaEntity {
  const MesaModel({
    required super.id,
    required super.name,
    super.description,
    required super.createdBy,
    super.createdAt,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        createdBy: json['created_by'] as String? ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'created_by': createdBy,
      };

  static MesaModel fromEntity(MesaEntity e) => MesaModel(
        id: e.id,
        name: e.name,
        description: e.description,
        createdBy: e.createdBy,
        createdAt: e.createdAt,
      );
}
