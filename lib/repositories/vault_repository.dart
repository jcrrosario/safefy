import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../services/crypto_service.dart';
import '../services/master_password_service.dart';
import '../services/vault_lock_service.dart';

class VaultRepository {
  final AppDatabase database;

  VaultRepository(this.database);

  Future<List<int>> _getSessionKey() async {
    final currentPassword = VaultLockService.getCurrentMasterPassword();

    if (currentPassword == null || currentPassword.isEmpty) {
      throw Exception('Sessão bloqueada. Senha mestra não disponível.');
    }

    return MasterPasswordService.deriveKeyFromPassword(currentPassword);
  }

  Future<String?> _encryptNullable(String? value, List<int> key) async {
    if (value == null || value.isEmpty) return null;
    return CryptoService.encryptText(
      plainText: value,
      keyBytes: key,
    );
  }

  Future<String?> _decryptNullable(String? value, List<int> key) async {
    if (value == null || value.isEmpty) return null;
    return CryptoService.decryptText(
      encryptedText: value,
      keyBytes: key,
    );
  }

  Future<int> addItem({
    required String title,
    required String category,
    String? username,
    String? password,
    String? url,
    String? content,
    String? notes,
  }) async {
    final now = DateTime.now();
    final key = await _getSessionKey();

    return database.insertVaultItem(
      VaultItemsCompanion.insert(
        title: await CryptoService.encryptText(
          plainText: title,
          keyBytes: key,
        ),
        category: category,
        username: Value(await _encryptNullable(username, key)),
        password: Value(await _encryptNullable(password, key)),
        url: Value(await _encryptNullable(url, key)),
        content: Value(await _encryptNullable(content, key)),
        notes: Value(await _encryptNullable(notes, key)),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<VaultItem>> getAllItems() async {
    final rawItems = await database.getAllVaultItems();
    final key = await _getSessionKey();

    return Future.wait(
      rawItems.map((item) async {
        return VaultItem(
          id: item.id,
          title: await CryptoService.decryptText(
            encryptedText: item.title,
            keyBytes: key,
          ),
          category: item.category,
          username: await _decryptNullable(item.username, key),
          password: await _decryptNullable(item.password, key),
          url: await _decryptNullable(item.url, key),
          content: await _decryptNullable(item.content, key),
          notes: await _decryptNullable(item.notes, key),
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
        );
      }),
    );
  }

  Future<List<VaultItem>> getItemsByCategory(String category) async {
    final items = await getAllItems();
    return items.where((item) => item.category == category).toList();
  }

  Future<List<VaultItem>> searchItems(String query) async {
    final items = await getAllItems();
    final q = query.toLowerCase();

    return items.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          (item.username ?? '').toLowerCase().contains(q) ||
          (item.url ?? '').toLowerCase().contains(q) ||
          (item.notes ?? '').toLowerCase().contains(q) ||
          (item.content ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<bool> updateItem({
    required int id,
    required String title,
    required String category,
    String? username,
    String? password,
    String? url,
    String? content,
    String? notes,
    required DateTime createdAt,
  }) async {
    final key = await _getSessionKey();

    return database.updateVaultItem(
      VaultItem(
        id: id,
        title: await CryptoService.encryptText(
          plainText: title,
          keyBytes: key,
        ),
        category: category,
        username: await _encryptNullable(username, key),
        password: await _encryptNullable(password, key),
        url: await _encryptNullable(url, key),
        content: await _encryptNullable(content, key),
        notes: await _encryptNullable(notes, key),
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<int> deleteItem(int id) {
    return database.deleteVaultItemById(id);
  }
}