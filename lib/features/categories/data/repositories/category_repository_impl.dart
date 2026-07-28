import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _local;
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  const CategoryRepositoryImpl(this._local, this._db, this._syncEngine);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByTournament(
      String tournamentId) async {
    try {
      return Right(await _local.getCategoriesByTournament(tournamentId));
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al leer categorías locales: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
      CategoryEntity category) {
    return _saveLocally(CategoryModel.fromEntity(category));
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
      CategoryEntity category) {
    return _saveLocally(CategoryModel.fromEntity(category));
  }

  Future<Either<Failure, CategoryEntity>> _saveLocally(
      CategoryModel model) async {
    try {
      await _local.upsert(model, dirty: true);
      await _enqueue(rowId: model.id, operation: 'upsert', payload: model.toJson());
      unawaited(_syncEngine.trySync());
      return Right(model);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al guardar categoría local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _local.softDelete(id);
      await _enqueue(rowId: id, operation: 'delete', payload: null);
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al eliminar categoría local: $e'));
    }
  }

  Future<void> _enqueue({
    required String rowId,
    required String operation,
    required Map<String, dynamic>? payload,
  }) {
    return _db.enqueueSyncOp(SyncQueueEntriesCompanion.insert(
      id: const Uuid().v4(),
      entityTable: SupabaseConstants.categoriesTable,
      rowId: rowId,
      operation: operation,
      payload: Value(payload == null ? null : jsonEncode(payload)),
    ));
  }
}
