import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'pages/app_entry_page.dart';
import 'services/vault_state_service.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeFy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppEntryPage(),
    );
  }
}