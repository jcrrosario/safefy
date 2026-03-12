import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'pages/create_master_password_page.dart';

void main() {
  runApp(const SafeFyApp());
}

class SafeFyApp extends StatelessWidget {
  const SafeFyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeFy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CreateMasterPasswordPage(),
    );
  }
}