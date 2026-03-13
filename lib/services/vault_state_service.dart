import 'package:shared_preferences/shared_preferences.dart';

class VaultStateService {
  static const String _vaultCreatedKey = 'vault_created';

  static Future<void> setVaultCreated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vaultCreatedKey, true);
  }

  static Future<bool> isVaultCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vaultCreatedKey) ?? false;
  }
}