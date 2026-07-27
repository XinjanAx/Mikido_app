import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' | 'user'
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, email, name, role, createdAt];
}
