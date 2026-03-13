class VaultLockService {
  static String? _currentMasterPassword;

  static void setCurrentMasterPassword(String password) {
    _currentMasterPassword = password;
  }

  static String? getCurrentMasterPassword() {
    return _currentMasterPassword;
  }

  static void clearCurrentMasterPassword() {
    _currentMasterPassword = null;
  }
}