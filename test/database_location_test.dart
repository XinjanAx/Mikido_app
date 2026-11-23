import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/database/database_location.dart';

void main() {
  late Directory tmp;
  late File legacy;
  late File target;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('db_location_test');
    legacy = File('${tmp.path}/onedrive/torneo_app.sqlite');
    target = File('${tmp.path}/appdata/sub/torneo_app.sqlite');
    await legacy.parent.create(recursive: true);
  });

  tearDown(() => tmp.delete(recursive: true));

  test('copia la base vieja (y su -wal) y renombra la vieja', () async {
    await legacy.writeAsString('datos');
    await File('${legacy.path}-wal').writeAsString('wal');

    await DatabaseLocation.migrateIfNeeded(legacy: legacy, target: target);

    expect(await target.readAsString(), 'datos');
    expect(await File('${target.path}-wal').readAsString(), 'wal');
    expect(await legacy.exists(), isFalse);
    expect(
        await File('${legacy.path}${DatabaseLocation.migratedSuffix}')
            .readAsString(),
        'datos');
  });

  test('no pisa una base nueva que ya existe', () async {
    await legacy.writeAsString('vieja');
    await target.parent.create(recursive: true);
    await target.writeAsString('nueva');

    await DatabaseLocation.migrateIfNeeded(legacy: legacy, target: target);

    expect(await target.readAsString(), 'nueva');
    expect(await legacy.readAsString(), 'vieja'); // intacta
  });

  test('sin base vieja no hace nada', () async {
    await DatabaseLocation.migrateIfNeeded(legacy: legacy, target: target);
    expect(await target.exists(), isFalse);
  });
}
