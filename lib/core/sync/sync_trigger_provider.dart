import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity_provider.dart';
import 'sync_engine_provider.dart';

/// Provider "activador": con solo observarlo (p. ej. en `app.dart`), dispara
/// una sincronización al arrancar y otra cada vez que vuelve la conexión.
final syncTriggerProvider = Provider<void>((ref) {
  final syncEngine = ref.watch(syncEngineProvider);

  // Sync inicial (si hay red al abrir la app).
  Future.microtask(() => syncEngine.trySync());

  // Reintentar cuando se recupera la conexión.
  bool? wasOnline;
  ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
    final isNowOnline = next.value;
    if (isNowOnline == true && wasOnline != true) {
      syncEngine.trySync();
    }
    if (isNowOnline != null) wasOnline = isNowOnline;
  });
});
