import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MasterPasswordService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String _masterPasswordHashKey = 'master_password_hash';
  static const String _masterPasswordSaltKey = 'master_password_salt';

  static Future<String> _generateHash(String password) async {
    final bytes = utf8.encode(password);
    final digest = await Sha256().hash(bytes);
    return base64Encode(digest.bytes);
  }

  static String _generateRandomSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static Future<void> saveMasterPassword(String password) async {
    final hash = await _generateHash(password);
    final existingSalt = await _secureStorage.read(key: _masterPasswordSaltKey);
    final salt = existingSalt ?? _generateRandomSalt();

    await _secureStorage.write(
      key: _masterPasswordHashKey,
      value: hash,
    );

    await _secureStorage.write(
      key: _masterPasswordSaltKey,
      value: salt,
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

  static Future<List<int>> deriveKeyFromPassword(String password) async {
    final saltBase64 = await _secureStorage.read(key: _masterPasswordSaltKey);

    if (saltBase64 == null || saltBase64.isEmpty) {
      throw Exception('Salt da senha mestra não encontrado.');
    }

    final salt = base64Decode(saltBase64);

    return deriveKeyFromPasswordAndSalt(
      password: password,
      salt: salt,
    );
  }

  static Future<List<int>> deriveKeyFromPasswordAndSalt({
    required String password,
    required List<int> salt,
    int iterations = 210000,
  }) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    final secretKey = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    return await secretKey.extractBytes();
  }

  static List<int> generateRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}