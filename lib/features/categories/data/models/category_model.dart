import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.tournamentId,
    super.description,
    super.minAge,
    super.maxAge,
    super.maxParticipants,
    super.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        tournamentId: json['tournament_id'] as String,
        description: json['description'] as String?,
        minAge: json['min_age'] as int?,
        maxAge: json['max_age'] as int?,
        maxParticipants: json['max_participants'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tournament_id': tournamentId,
        'description': description,
        'min_age': minAge,
        'max_age': maxAge,
        'max_participants': maxParticipants,
      };

  Map<String, dynamic> toInsertJson() {
    final j = toJson();
    j.remove('id');
    return j;
  }

  static CategoryModel fromEntity(CategoryEntity e) => CategoryModel(
        id: e.id,
        name: e.name,
        tournamentId: e.tournamentId,
        description: e.description,
        minAge: e.minAge,
        maxAge: e.maxAge,
        maxParticipants: e.maxParticipants,
        createdAt: e.createdAt,
      );
}
