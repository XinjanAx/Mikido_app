import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity_provider.dart';
import 'sync_engine_provider.dart';

/// Provider "activador": con solo observarlo (p. ej. en `app.dart`), dispara
/// una sincronización al arrancar y otra cada vez que vuelve la conexión.
final syncTriggerProvider = Provider<void>((ref) {
  final syncEngine = ref.watch(syncEngineProvider);

  // Sync inicial (si hay red al abrir la app).
  Future.microtask(() => syncEngine.trySync());

  // Reintento corto tras el arranque: en pruebas reales, la primerísima
  // sincronización justo al abrir la app a veces trae listas vacías para
  // alguna tabla (conexión en frío / DNS-TLS recién iniciando), sin tirar
  // ningún error — un segundo intento poco después sí trae los datos
  // completos. No sabemos la causa exacta del lado de la red, pero este
  // reintento la cubre sin costo para el caso normal (si ya sincronizó
  // bien, este segundo intento no cambia nada).
  Future.delayed(const Duration(seconds: 4), () => syncEngine.trySync());

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
