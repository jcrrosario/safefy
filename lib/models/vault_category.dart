enum VaultCategory {
  passwords,
  certificates,
  privateKeys,
  documents,
  tokens,
}

extension VaultCategoryExtension on VaultCategory {
  String get label {
    switch (this) {
      case VaultCategory.passwords:
        return 'Senhas';
      case VaultCategory.certificates:
        return 'Certificados';
      case VaultCategory.privateKeys:
        return 'Chaves Privadas';
      case VaultCategory.documents:
        return 'Documentos';
      case VaultCategory.tokens:
        return 'Tokens';
    }
  }

  String get value {
    switch (this) {
      case VaultCategory.passwords:
        return 'passwords';
      case VaultCategory.certificates:
        return 'certificates';
      case VaultCategory.privateKeys:
        return 'private_keys';
      case VaultCategory.documents:
        return 'documents';
      case VaultCategory.tokens:
        return 'tokens';
    }
  }
}