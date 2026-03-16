import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [VaultItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertVaultItem(VaultItemsCompanion item) {
    return into(vaultItems).insert(item);
  }

  Future<List<VaultItem>> getAllVaultItems() {
    return select(vaultItems).get();
  }

  Future<List<VaultItem>> getVaultItemsByCategory(String category) {
    return (select(vaultItems)
      ..where((tbl) => tbl.category.equals(category))
      ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.updatedAt),
      ]))
        .get();
  }

  Future<List<VaultItem>> searchVaultItems(String query) {
    return (select(vaultItems)
      ..where(
            (tbl) =>
        tbl.title.like('%$query%') |
        tbl.category.like('%$query%') |
        tbl.username.like('%$query%') |
        tbl.notes.like('%$query%'),
      )
      ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.updatedAt),
      ]))
        .get();
  }

  Future<bool> updateVaultItem(VaultItem item) {
    return update(vaultItems).replace(item);
  }

  Future<int> deleteVaultItemById(int id) {
    return (delete(vaultItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteAllVaultItems() {
    return delete(vaultItems).go();
  }


}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'safefy.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

