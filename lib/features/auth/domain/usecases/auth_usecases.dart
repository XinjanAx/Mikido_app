import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) =>
      repository.login(email: email, password: password);
}

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String name,
  }) =>
      repository.register(email: email, password: password, name: name);
}

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.logout();
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() => repository.getCurrentUser();
}
