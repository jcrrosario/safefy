import 'package:flutter/material.dart';
import '../db/database_provider.dart';
import '../repositories/vault_repository.dart';
import '../db/app_database.dart';
import 'add_vault_item_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  late final VaultRepository _repository;

  List<VaultItem> _items = [];

  @override
  void initState() {
    super.initState();
    _repository = VaultRepository(DatabaseProvider.instance);
    _loadItems();
  }

  Future<void> _loadItems() async {

    final items = await _repository.getAllItems();

    setState(() {
      _items = items;
    });
  }

  Future<void> _openAddItem() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddVaultItemPage(),
      ),
    );

    if (result == true) {
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("SafeFy"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {

          final item = _items[index];

          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.username ?? ""),
          );
        },
      ),
    );
  }
}