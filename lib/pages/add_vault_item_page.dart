import 'package:flutter/material.dart';
import '../db/database_provider.dart';
import '../repositories/vault_repository.dart';

class AddVaultItemPage extends StatefulWidget {
  const AddVaultItemPage({super.key});

  @override
  State<AddVaultItemPage> createState() => _AddVaultItemPageState();
}

class _AddVaultItemPageState extends State<AddVaultItemPage> {

  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final VaultRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = VaultRepository(DatabaseProvider.instance);
  }

  Future<void> _saveItem() async {

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe um título")),
      );
      return;
    }

    await _repository.addItem(
      title: _titleController.text,
      category: "passwords",
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Título",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Usuário",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Senha",
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveItem,
                child: const Text("Salvar"),
              ),
            )
          ],
        ),
      ),
    );
  }
}