import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/errors/exceptions.dart';
import 'package:torneo_app/features/mesas/data/datasources/mesa_local_datasource.dart';
import 'package:torneo_app/features/mesas/data/datasources/mesa_remote_datasource.dart';
import 'package:torneo_app/features/mesas/data/sync/mesa_sync_adapter.dart';

class _FakeRemote implements MesaRemoteDataSource {
  bool referenced;
  _FakeRemote({required this.referenced});

  @override
  Future<void> deleteMesa(String id) async {
    if (referenced) {
      throw const StillReferencedException(message: 'tiene categorías');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocal implements MesaLocalDataSource {
  final restored = <String>[];
  final hardDeleted = <String>[];

  @override
  Future<void> restore(String id) async => restored.add(id);

  @override
  Future<void> hardDelete(String id) async => hardDeleted.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Simula lo que hace SyncEngine con una operación de borrado del outbox.
Future<void> drainDelete(MesaSyncAdapter adapter, String id) async {
  await adapter.pushDelete(id);
  await adapter.markSynced(id, wasDelete: true);
}

void main() {
  test('borrado rechazado por el servidor: la mesa vuelve a la lista', () async {
    final local = _FakeLocal();
    final adapter = MesaSyncAdapter(_FakeRemote(referenced: true), local);

    await drainDelete(adapter, 'm1');

    expect(local.restored, ['m1']);
    expect(local.hardDeleted, isEmpty);
  });

  test('borrado aceptado: se elimina de la base local', () async {
    final local = _FakeLocal();
    final adapter = MesaSyncAdapter(_FakeRemote(referenced: false), local);

    await drainDelete(adapter, 'm1');

    expect(local.restored, isEmpty);
    expect(local.hardDeleted, ['m1']);
  });
}
