import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Dónde vive la base local (SQLite) de la app.
///
/// - **Escritorio (Windows/macOS/Linux):** en la carpeta de datos de la
///   aplicación (en Windows, `AppData\Roaming\...`). Antes estaba en
///   Documentos, que en Windows suele estar redirigido a OneDrive (y en
///   macOS a iCloud): el servicio de nube podía copiar el archivo a medio
///   escribir —corrompiéndolo— o compartirlo entre PCs y mezclar datos.
/// - **Móvil (Android/iOS):** sigue en Documentos de la app, que ya es una
///   carpeta privada que no se sincroniza; no se toca para no mover la base
///   de los teléfonos que ya la usan.
class DatabaseLocation {
  DatabaseLocation._();

  static const fileName = 'torneo_app.sqlite';

  /// Extensión con la que queda la base vieja después de migrarla, para que
  /// ninguna versión anterior de la app vuelva a abrirla por error.
  static const migratedSuffix = '.migrada';

  static bool get _isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// Archivo de la base, migrando la ubicación vieja si hace falta.
  static Future<File> resolve() async {
    final documents = await getApplicationDocumentsDirectory();
    final legacy = File(p.join(documents.path, fileName));
    if (!_isDesktop) return legacy;

    final support = await getApplicationSupportDirectory();
    final target = File(p.join(support.path, fileName));
    await migrateIfNeeded(legacy: legacy, target: target);
    return target;
  }

  /// Si la base nueva todavía no existe y hay una en la ubicación vieja, la
  /// COPIA (junto con sus archivos -wal / -shm, que pueden tener cambios
  /// aún no volcados) y recién después renombra la vieja a [migratedSuffix].
  /// Si algo falla a mitad de camino, la vieja queda intacta y se reintenta
  /// en el próximo arranque.
  static Future<void> migrateIfNeeded({
    required File legacy,
    required File target,
  }) async {
    if (await target.exists() || !await legacy.exists()) return;

    await target.parent.create(recursive: true);
    const companions = ['', '-wal', '-shm'];
    final copied = <File>[];
    try {
      for (final suffix in companions) {
        final from = File('${legacy.path}$suffix');
        if (await from.exists()) {
          copied.add(await from.copy('${target.path}$suffix'));
        }
      }
    } catch (_) {
      // Copia incompleta: se descarta para no abrir una base a medias.
      for (final f in copied) {
        if (await f.exists()) await f.delete();
      }
      rethrow;
    }

    for (final suffix in companions) {
      final from = File('${legacy.path}$suffix');
      if (await from.exists()) {
        await from.rename('${from.path}$migratedSuffix');
      }
    }
  }
}
