import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String tournamentId;
  final String? description;
  final int? minAge;
  final int? maxAge;
  final int? maxParticipants;
  final DateTime? createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.tournamentId,
    this.description,
    this.minAge,
    this.maxAge,
    this.maxParticipants,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, name, tournamentId, description, minAge, maxAge, maxParticipants, createdAt
      ];
}
