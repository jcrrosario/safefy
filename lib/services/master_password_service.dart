import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MasterPasswordService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _masterPasswordHashKey = 'master_password_hash';

  static Future<String> _generateHash(String password) async {
    final bytes = utf8.encode(password);
    final digest = await Sha256().hash(bytes);
    return base64Encode(digest.bytes);
  }

  static Future<void> saveMasterPassword(String password) async {
    final hash = await _generateHash(password);
    await _secureStorage.write(
      key: _masterPasswordHashKey,
      value: hash,
    );
  }

  static Future<bool> validateMasterPassword(String password) async {
    final savedHash = await _secureStorage.read(key: _masterPasswordHashKey);

    if (savedHash == null || savedHash.isEmpty) {
      return false;
    }

    final currentHash = await _generateHash(password);
    return savedHash == currentHash;
  }

  static Future<bool> hasMasterPassword() async {
    final savedHash = await _secureStorage.read(key: _masterPasswordHashKey);
    return savedHash != null && savedHash.isNotEmpty;
  }
}