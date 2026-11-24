import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? photoUrl;
  final DateTime? createdAt;

  /// Gremio o clan (opcional).
  final String? guild;

  /// Acrónimo del gremio: máx. 4 letras o números, siempre en mayúsculas.
  /// Solo existe si hay [guild].
  final String? guildAcronym;

  const PlayerEntity({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.birthDate,
    this.photoUrl,
    this.createdAt,
    this.guild,
    this.guildAcronym,
  });

  /// "Nombre - ACRO" si tiene gremio; si no, solo el nombre.
  String get nameWithAcronym =>
      (guildAcronym == null || guildAcronym!.isEmpty)
          ? name
          : '$name - $guildAcronym';

  @override
  List<Object?> get props => [
        id, name, email, phone, birthDate, photoUrl, createdAt,
        guild, guildAcronym,
      ];
}
