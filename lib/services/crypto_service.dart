import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  static final AesGcm _algorithm = AesGcm.with256bits();

  static Future<String> encryptText({
    required String plainText,
    required List<int> keyBytes,
  }) async {
    final secretKey = SecretKey(keyBytes);

    final nonce = _randomBytes(12);

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
    );

    final payload = {
      'nonce': base64Encode(secretBox.nonce),
      'cipherText': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };

    return jsonEncode(payload);
  }

  static Future<String> decryptText({
    required String encryptedText,
    required List<int> keyBytes,
  }) async {
    final secretKey = SecretKey(keyBytes);

    final payload = jsonDecode(encryptedText) as Map<String, dynamic>;

    final nonce = base64Decode(payload['nonce'] as String);
    final cipherText = base64Decode(payload['cipherText'] as String);
    final macBytes = base64Decode(payload['mac'] as String);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearBytes);
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}