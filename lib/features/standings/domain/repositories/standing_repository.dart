import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/standing_entity.dart';

abstract class StandingRepository {
  Future<Either<Failure, List<StandingEntity>>> getStandings(
      String tournamentId);
  Future<Either<Failure, void>> recalculateStandings(String tournamentId);
  Stream<List<StandingEntity>> watchStandings(String tournamentId);

  /// Guarda el orden que el admin eligió a mano para un jugador que seguía
  /// empatado (en puntos y diferencia) al finalizar el torneo. 0 = mejor
  /// ubicado dentro de su grupo de empatados.
  Future<Either<Failure, void>> saveManualRank(
      StandingEntity standing, int manualRank);
}
