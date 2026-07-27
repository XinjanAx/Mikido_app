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
  });

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
        return 'Activo';
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
      [id, name, mode, status, description, startDate, endDate, createdBy, createdAt];
}
