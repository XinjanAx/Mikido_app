import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? photoUrl;
  final String? categoryId;
  final DateTime? createdAt;

  const PlayerEntity({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.birthDate,
    this.photoUrl,
    this.categoryId,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, email, phone, birthDate, photoUrl, categoryId, createdAt];
}
