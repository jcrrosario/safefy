import 'package:drift/drift.dart';
import '../db/app_database.dart';

class VaultRepository {
  final AppDatabase database;

  VaultRepository(this.database);

  Future<int> addItem({
    required String title,
    required String category,
    String? username,
    String? password,
    String? url,
    String? content,
    String? notes,
  }) {
    final now = DateTime.now();

    return database.insertVaultItem(
      VaultItemsCompanion.insert(
        title: title,
        category: category,
        username: Value(username),
        password: Value(password),
        url: Value(url),
        content: Value(content),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<VaultItem>> getAllItems() {
    return database.getAllVaultItems();
  }

  Future<List<VaultItem>> getItemsByCategory(String category) {
    return database.getVaultItemsByCategory(category);
  }

  Future<List<VaultItem>> searchItems(String query) {
    return database.searchVaultItems(query);
  }

  Future<bool> updateItem(VaultItem item) {
    return database.updateVaultItem(item);
  }

  Future<int> deleteItem(int id) {
    return database.deleteVaultItemById(id);
  }
}