import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/tournament_entity.dart';

abstract class TournamentRepository {
  Future<Either<Failure, List<TournamentEntity>>> getTournaments();
  Future<Either<Failure, TournamentEntity>> getTournamentById(String id);
  Future<Either<Failure, TournamentEntity>> createTournament(TournamentEntity tournament);
  Future<Either<Failure, TournamentEntity>> updateTournament(TournamentEntity tournament);
  Future<Either<Failure, void>> deleteTournament(String id);
  Stream<List<TournamentEntity>> watchTournaments();
}
