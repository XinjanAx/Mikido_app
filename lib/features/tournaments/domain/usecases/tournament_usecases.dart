import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

class GetTournamentsUseCase {
  final TournamentRepository repository;
  const GetTournamentsUseCase(this.repository);

  Future<Either<Failure, List<TournamentEntity>>> call() =>
      repository.getTournaments();
}

class GetTournamentByIdUseCase {
  final TournamentRepository repository;
  const GetTournamentByIdUseCase(this.repository);

  Future<Either<Failure, TournamentEntity>> call(String id) =>
      repository.getTournamentById(id);
}

class CreateTournamentUseCase {
  final TournamentRepository repository;
  const CreateTournamentUseCase(this.repository);

  Future<Either<Failure, TournamentEntity>> call(TournamentEntity tournament) =>
      repository.createTournament(tournament);
}

class UpdateTournamentUseCase {
  final TournamentRepository repository;
  const UpdateTournamentUseCase(this.repository);

  Future<Either<Failure, TournamentEntity>> call(TournamentEntity tournament) =>
      repository.updateTournament(tournament);
}

class DeleteTournamentUseCase {
  final TournamentRepository repository;
  const DeleteTournamentUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) =>
      repository.deleteTournament(id);
}
