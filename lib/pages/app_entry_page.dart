import 'package:flutter/material.dart';
import '../services/vault_state_service.dart';
import 'create_master_password_page.dart';
import 'dashboard_page.dart';
import 'unlock_vault_page.dart';

class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  bool _isLoading = true;
  bool _vaultCreated = false;
  bool _vaultUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final vaultCreated = await VaultStateService.isVaultCreated();
    final vaultUnlocked = await VaultStateService.isVaultUnlocked();

    if (!mounted) return;

    setState(() {
      _vaultCreated = vaultCreated;
      _vaultUnlocked = vaultUnlocked;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_vaultCreated) {
      return const CreateMasterPasswordPage();
    }

    if (_vaultUnlocked) {
      DashboardPage();
    }

    return const UnlockVaultPage();
  }
}