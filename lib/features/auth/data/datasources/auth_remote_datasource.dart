import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register(
      {required String email, required String password, required String name});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> login(
      {required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthException(message: 'Credenciales inválidas');
      }

      // Intentar obtener perfil, si no existe crearlo
      UserModel? profile;
      try {
        profile = await _fetchProfile(response.user!.id, response.user!.email!);
      } catch (_) {
        // Si no existe el perfil, crearlo ahora
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'email': response.user!.email,
          'name': response.user!.email!.split('@').first,
          'role': 'user',
        });
        profile = await _fetchProfile(response.user!.id, response.user!.email!);
      }
      return profile;
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: 'Error: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Registrar sin iniciar sesión automáticamente
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw const AuthException(message: 'Error al registrar usuario');
      }

      // Cerrar la sesión que Supabase abre automáticamente
      await _client.auth.signOut();

      // Devolver un usuario básico con los datos del registro
      return UserModel(
        id: response.user!.id,
        email: email,
        name: name,
        role: 'user',
      );
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: 'Error al registrar: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchProfile(user.id, user.email!);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      try {
        return await _fetchProfile(user.id, user.email!);
      } catch (_) {
        return null;
      }
    });
  }

  Future<UserModel> _fetchProfile(String id, String email) async {
    final data = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', id)
        .single();
    return UserModel.fromJson({...data, 'email': email});
  }
}
