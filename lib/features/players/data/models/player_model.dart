import '../../domain/entities/player_entity.dart';

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.birthDate,
    super.photoUrl,
    super.categoryId,
    super.createdAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        birthDate: json['birth_date'] != null
            ? DateTime.tryParse(json['birth_date'] as String)
            : null,
        photoUrl: json['photo_url'] as String?,
        categoryId: json['category_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'birth_date': birthDate?.toIso8601String(),
        'photo_url': photoUrl,
      };

  Map<String, dynamic> toInsertJson() {
    final j = toJson();
    j.remove('id');
    return j;
  }

  static PlayerModel fromEntity(PlayerEntity e) => PlayerModel(
        id: e.id,
        name: e.name,
        email: e.email,
        phone: e.phone,
        birthDate: e.birthDate,
        photoUrl: e.photoUrl,
        createdAt: e.createdAt,
      );
}
