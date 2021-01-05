import 'package:repository/repository.dart';
import 'package:repository/src/common/template_requestor.dart';
import 'package:repository/src/db/db_requestor.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DBRepo {
  DBRepo(
    this.dbName,
    {
      this.version,
    }
  );

  final String dbName;
  final int version;

  Database _database;

  /// Initialize database.
  ///
  ///
  Future<void> init() async {
    _database = await databaseFactoryIo.openDatabase(dbName);
  }

  /// Create database tables.
  ///
  ///
  void createTable(DBRequestor requestor) => stringMapStoreFactory.store(requestor.tableName);

  /// Select all query from [tableName].
  ///
  ///
  Future<List<T>> select<T extends TemplateRequestor>(String tableName) async {
    if (tableName == null || tableName.isEmpty) {
      return null;
    }

    final store = stringMapStoreFactory.store(tableName);
    final List<T> result = <T>[];

    await _database.transaction((transaction) async {
      final shit = await store.find(_database);

      shit.forEach((element) {
        final T requestor = Repo.requestors[T].call().fromJson(element.value);
        result.add(requestor);
      });
    });

    return result;
  }

  /// Save data to database.
  ///
  ///
  Future<bool> put<T extends TemplateRequestor>(T item) async {
    if (item == null) {
      return false;
    }

    final DBRequestor dbItem = item as DBRequestor;
    final store = stringMapStoreFactory.store(dbItem.tableName);

    await _database.transaction((transaction) async {
      await store.record(dbItem.dbId).put(transaction, dbItem.toJson());
    });

    return true;
  }

  /// Save list data to database.
  ///
  ///
  Future<bool> putList<T extends TemplateRequestor>(List<T> items) async {
    if (items == null || items.isEmpty) {
      return false;
    }

    final store = stringMapStoreFactory.store((items.first as DBRequestor).tableName);

    await _database.transaction((transaction) async {
      for (final T item in items) {
        final DBRequestor dbItem = item as DBRequestor;
        await store.record(dbItem.dbId).put(transaction, dbItem.toJson());
      }
    });

    return true;
  }

  /// Update data from database.
  ///
  ///
  Future<bool> update<T>() async {
    return false;
  }

  /// Delete data from database.
  ///
  ///
  Future<bool> delete<T>() async {
    return false;
  }
}