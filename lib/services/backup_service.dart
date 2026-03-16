import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../models/backup_preview.dart';
import '../repositories/vault_repository.dart';
import 'crypto_service.dart';
import 'master_password_service.dart';
import 'vault_lock_service.dart';

class BackupService {
  final VaultRepository repository;

  static const int _backupVersion = 2;
  static const int _backupKeyIterations = 210000;

  BackupService(this.repository);

  String _requireCurrentMasterPassword() {
    final currentPassword = VaultLockService.getCurrentMasterPassword();

    if (currentPassword == null || currentPassword.isEmpty) {
      throw Exception('Sessão bloqueada. Desbloqueie o cofre novamente.');
    }

    return currentPassword;
  }

  Future<String?> exportEncryptedBackup() async {
    VaultLockService.suspendAutoLock();

    try {
      final currentPassword = _requireCurrentMasterPassword();
      final items = await repository.exportItemsAsMap();

      final backupSalt = MasterPasswordService.generateRandomBytes(16);
      final backupKey = await MasterPasswordService.deriveKeyFromPasswordAndSalt(
        password: currentPassword,
        salt: backupSalt,
        iterations: _backupKeyIterations,
      );

      final backupPayload = {
        'version': _backupVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'app': 'SafeFy',
        'itemCount': items.length,
        'items': items,
      };

      final encryptedPayload = await CryptoService.encryptText(
        plainText: jsonEncode(backupPayload),
        keyBytes: backupKey,
      );

      final fileContent = jsonEncode({
        'type': 'safefy_backup',
        'version': _backupVersion,
        'encrypted': true,
        'kdf': {
          'algorithm': 'PBKDF2-HMAC-SHA256',
          'iterations': _backupKeyIterations,
          'salt': base64Encode(backupSalt),
        },
        'cipher': {
          'algorithm': 'AES-256-GCM',
        },
        'payload': encryptedPayload,
      });

      final bytes = Uint8List.fromList(utf8.encode(fileContent));

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar backup do SafeFy',
        fileName: 'safefy_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      return result;
    } finally {
      VaultLockService.resumeAutoLock();
    }
  }

  Future<BackupPreview?> pickAndReadBackupPreview() async {
    VaultLockService.suspendAutoLock();

    try {
      final currentPassword = _requireCurrentMasterPassword();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final pickedFile = result.files.single;
      final rawText = await _readPickedFileAsText(pickedFile);

      final decoded = jsonDecode(rawText);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Arquivo de backup inválido.');
      }

      if (decoded['type'] != 'safefy_backup') {
        throw Exception('Arquivo de backup inválido.');
      }

      final kdf = decoded['kdf'];
      if (kdf is! Map<String, dynamic>) {
        throw Exception('Metadados de derivação de chave inválidos.');
      }

      final saltBase64 = kdf['salt'];
      final iterations = kdf['iterations'];

      if (saltBase64 is! String || saltBase64.isEmpty) {
        throw Exception('Salt do backup inválido.');
      }

      if (iterations is! int || iterations <= 0) {
        throw Exception('Configuração de iterações do backup inválida.');
      }

      final encryptedPayload = decoded['payload'];
      if (encryptedPayload is! String || encryptedPayload.isEmpty) {
        throw Exception('Payload do backup inválido.');
      }

      final backupSalt = base64Decode(saltBase64);

      final backupKey = await MasterPasswordService.deriveKeyFromPasswordAndSalt(
        password: currentPassword,
        salt: backupSalt,
        iterations: iterations,
      );

      final decryptedJson = await CryptoService.decryptText(
        encryptedText: encryptedPayload,
        keyBytes: backupKey,
      );

      final backupPayload = jsonDecode(decryptedJson);
      if (backupPayload is! Map<String, dynamic>) {
        throw Exception('Conteúdo do backup inválido.');
      }

      if (backupPayload['app'] != 'SafeFy') {
        throw Exception('Este backup não pertence ao SafeFy.');
      }

      final version = backupPayload['version'];
      final exportedAtRaw = backupPayload['exportedAt'];
      final itemCount = backupPayload['itemCount'];
      final items = backupPayload['items'];

      if (version is! int) {
        throw Exception('Versão do backup inválida.');
      }

      if (itemCount is! int) {
        throw Exception('Contagem de itens inválida.');
      }

      if (items is! List) {
        throw Exception('Lista de itens inválida.');
      }

      if (itemCount != items.length) {
        throw Exception(
          'Backup inconsistente. itemCount=$itemCount e items=${items.length}.',
        );
      }

      return BackupPreview(
        appName: backupPayload['app'] as String,
        version: version,
        exportedAt: exportedAtRaw is String ? DateTime.tryParse(exportedAtRaw) : null,
        itemCount: itemCount,
        items: items,
      );
    } finally {
      VaultLockService.resumeAutoLock();
    }
  }

  Future<int> restoreFromPreview(BackupPreview preview) async {
    final restoredCount = await repository.replaceAllItemsFromMap(preview.items);

    if (restoredCount != preview.itemCount) {
      throw Exception(
        'Restauração inconsistente. Backup=${preview.itemCount} e banco=$restoredCount.',
      );
    }

    return restoredCount;
  }

  Future<String> _readPickedFileAsText(PlatformFile pickedFile) async {
    if (pickedFile.bytes != null && pickedFile.bytes!.isNotEmpty) {
      return utf8.decode(pickedFile.bytes!);
    }

    if (pickedFile.path != null) {
      final file = File(pickedFile.path!);

      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado.');
      }

      return await file.readAsString();
    }

    throw Exception('Não foi possível ler o arquivo selecionado.');
  }
}