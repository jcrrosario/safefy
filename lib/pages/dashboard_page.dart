import 'package:flutter/material.dart';
import '../db/app_database.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final AppDatabase _database;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _testDatabase();
  }

  Future<void> _testDatabase() async {
    final items = await _database.getAllVaultItems();
    debugPrint('Itens no cofre: ${items.length}');
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Dashboard SafeFy',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}