import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/database/app_database.dart';
import 'package:torneo_app/core/sync/sync_adapter.dart';
import 'package:torneo_app/core/sync/sync_engine.dart';

class _SlowAdapter implements SyncAdapter {
  int pulls = 0;
  final gate = Completer<void>();

  @override
  String get tableName => 'x';

  @override
  Future<void> pull() async {
    pulls++;
    await gate.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('una segunda llamada espera la sincronización en curso', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final adapter = _SlowAdapter();
    final engine = SyncEngine(db, [adapter]);

    var firstDone = false;
    var secondDone = false;
    unawaited(engine.trySync().then((_) => firstDone = true));
    // Como el splash: se une a la que ya disparó syncTriggerProvider.
    unawaited(engine.trySync().then((_) => secondDone = true));

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(adapter.pulls, 1, reason: 'no arranca una segunda sincronización');
    expect(secondDone, isFalse, reason: 'antes volvía al instante sin esperar');

    adapter.gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(firstDone, isTrue);
    expect(secondDone, isTrue);

    // Terminada, una nueva llamada sí sincroniza de nuevo.
    await engine.trySync();
    expect(adapter.pulls, 2);
    await db.close();
  });
}
