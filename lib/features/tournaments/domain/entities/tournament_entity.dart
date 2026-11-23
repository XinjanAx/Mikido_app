import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class TournamentEntity extends Equatable {
  final String id;
  final String name;
  final String mode; // groups | elimination | league
  final String status; // draft | active | finished | cancelled
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime? createdAt;

  /// Mesa a la que pertenece esta categoría (null solo en datos viejos).
  final String? mesaId;

  /// Color de la categoría, '#RRGGBB' (ver CategoryColors).
  final String? color;

  const TournamentEntity({
    required this.id,
    required this.name,
    required this.mode,
    required this.status,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    this.createdAt,
    this.mesaId,
    this.color,
  });

  TournamentEntity copyWith({
    String? name,
    String? mode,
    String? status,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? color,
  }) =>
      TournamentEntity(
        id: id,
        name: name ?? this.name,
        mode: mode ?? this.mode,
        status: status ?? this.status,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        createdBy: createdBy,
        createdAt: createdAt,
        mesaId: mesaId,
        color: color ?? this.color,
      );

  bool get isDraft => status == AppConstants.statusDraft;
  bool get isActive => status == AppConstants.statusActive;
  bool get isFinished => status == AppConstants.statusFinished;

  String get modeLabel {
    switch (mode) {
      case AppConstants.tournamentModeGroups:
        return 'Por grupos';
      case AppConstants.tournamentModeElimination:
        return 'Eliminación simple';
      case AppConstants.tournamentModeLeague:
        return 'Liga';
      default:
        return mode;
    }
  }

  String get statusLabel {
    switch (status) {
      case AppConstants.statusDraft:
        return 'Borrador';
      case AppConstants.statusActive:
        return 'En curso';
      case AppConstants.statusFinished:
        return 'Finalizado';
      case AppConstants.statusCancelled:
        return 'Cancelado';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props =>
      [id, name, mode, status, description, startDate, endDate, createdBy, createdAt, mesaId, color];
}
