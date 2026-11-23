import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/database/app_database.dart';

/// Caso real: la base se creó con la v7 (ya tiene `color`), una versión
/// anterior de la app (v6) la abrió y le bajó user_version a 6 sin tocar
/// las tablas. Al reabrirla con la v7, la migración no debe fallar con
/// "duplicate column name: color".
void main() {
  test('reabrir una base v7 marcada como v6 no falla', () async {
    final dir = await Directory.systemTemp.createTemp('torneo_db_test');
    final file = File('${dir.path}/test.sqlite');

    // 1. Base nueva con el esquema actual.
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await db.customSelect('SELECT 1').get(); // fuerza la creación
    // 2. Lo que hace abrirla con una versión anterior: baja la marca.
    await db.customStatement('PRAGMA user_version = 6');
    await db.close();

    // 3. Reabrir con la versión actual: corre la migración 6 → 7.
    db = AppDatabase.forTesting(NativeDatabase(file));
    final columns = await db
        .customSelect('PRAGMA table_info("tournaments")')
        .get();
    expect(columns.where((r) => r.read<String>('name') == 'color').length, 1);
    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 7);

    await db.close();
    await dir.delete(recursive: true);
  });
}
