import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

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
