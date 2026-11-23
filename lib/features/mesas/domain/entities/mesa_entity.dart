import 'package:equatable/equatable.dart';

/// Lugar físico (cancha, pista, tatami, ring o plataforma) donde se juegan
/// los encuentros de una o varias categorías, con un orden global propio.
class MesaEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime? createdAt;

  const MesaEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, createdBy, createdAt];
}
