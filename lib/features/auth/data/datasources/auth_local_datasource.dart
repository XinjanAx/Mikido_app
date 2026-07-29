import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// Cachea el último perfil (nombre/rol) del usuario autenticado, para que
/// la app siga sabiendo quién eres y si eres admin al abrirla sin conexión.
/// Supabase ya guarda la sesión localmente por su cuenta — lo que faltaba
/// era esto: el perfil (tabla `profiles`, con el rol) se leía siempre por
/// red, así que sin internet un admin ya logueado aparecía como invitado.
class AuthLocalDataSource {
  static const _key = 'cached_user_profile';

  Future<void> cacheProfile(UserModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  /// Devuelve el perfil cacheado solo si corresponde al mismo usuario
  /// (evita mostrar el perfil de una sesión anterior de otra persona).
  Future<UserModel?> getCachedProfile(String expectedUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['id'] != expectedUserId) return null;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
