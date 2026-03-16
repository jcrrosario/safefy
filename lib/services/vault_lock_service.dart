class VaultLockService {
  static String? _currentMasterPassword;
  static bool _suspendAutoLock = false;

  static void setCurrentMasterPassword(String password) {
    _currentMasterPassword = password;
  }

  static String? getCurrentMasterPassword() {
    return _currentMasterPassword;
  }

  static void clearCurrentMasterPassword() {
    _currentMasterPassword = null;
  }

  static void suspendAutoLock() {
    _suspendAutoLock = true;
  }

  static void resumeAutoLock() {
    _suspendAutoLock = false;
  }

  static bool isAutoLockSuspended() {
    return _suspendAutoLock;
  }
}