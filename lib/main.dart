import 'package:flutter/material.dart';
import 'core/app_navigator.dart';
import 'core/app_theme.dart';
import 'pages/app_entry_page.dart';
import 'pages/unlock_vault_page.dart';
import 'services/vault_state_service.dart';
import 'services/vault_lock_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeFyApp());
}

class SafeFyApp extends StatefulWidget {
  const SafeFyApp({super.key});

  @override
  State<SafeFyApp> createState() => _SafeFyAppState();
}

class _SafeFyAppState extends State<SafeFyApp> with WidgetsBindingObserver {
  bool _isShowingLockScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      await VaultStateService.lockVault();
      VaultLockService.clearCurrentMasterPassword();
      _isShowingLockScreen = false;
    }

    if (state == AppLifecycleState.resumed) {
      final vaultCreated = await VaultStateService.isVaultCreated();
      final vaultUnlocked = await VaultStateService.isVaultUnlocked();

      if (!vaultCreated || vaultUnlocked || _isShowingLockScreen) {
        return;
      }

      final context = AppNavigator.navigatorKey.currentContext;
      if (context == null) return;

      _isShowingLockScreen = true;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const UnlockVaultPage(),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNavigator.navigatorKey,
      title: 'SafeFy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppEntryPage(),
    );
  }
}