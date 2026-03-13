import 'package:shared_preferences/shared_preferences.dart';

class VaultStateService {
  static const String _vaultCreatedKey = 'vault_created';
  static const String _vaultUnlockedKey = 'vault_unlocked';

  static Future<void> setVaultCreated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vaultCreatedKey, true);
  }

  static Future<bool> isVaultCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vaultCreatedKey) ?? false;
  }

  static Future<void> setVaultUnlocked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vaultUnlockedKey, value);
  }

  static Future<bool> isVaultUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vaultUnlockedKey) ?? false;
  }

  static Future<void> lockVault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vaultUnlockedKey, false);
  }

  static Future<void> unlockVault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vaultUnlockedKey, true);
  }
}