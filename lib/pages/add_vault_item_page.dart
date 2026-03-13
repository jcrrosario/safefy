import 'package:flutter/material.dart';
import '../repositories/vault_repository.dart';

class NewItemPage extends StatefulWidget {
  final VaultRepository repository;

  const NewItemPage({
    super.key,
    required this.repository,
  });

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _contentController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'passwords';
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _contentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    final title = _titleController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final url = _urlController.text.trim();
    final content = _contentController.text.trim();
    final notes = _notesController.text.trim();

    if (title.isEmpty) {
      _showMessage('Informe o título.');
      return;
    }

    if (_selectedCategory == 'passwords' && password.isEmpty) {
      _showMessage('Informe a senha.');
      return;
    }

    if (_selectedCategory != 'passwords' && content.isEmpty) {
      _showMessage('Informe o conteúdo do item.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final insertedId = await widget.repository.addItem(
      title: title,
      category: _selectedCategory,
      username: username.isEmpty ? null : username,
      password: password.isEmpty ? null : password,
      url: url.isEmpty ? null : url,
      content: content.isEmpty ? null : content,
      notes: notes.isEmpty ? null : notes,
    );

    debugPrint('Item salvo com ID: $insertedId');

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getContentLabel() {
    switch (_selectedCategory) {
      case 'certificates':
        return 'Conteúdo do Certificado';
      case 'private_keys':
        return 'Chave Privada';
      case 'documents':
        return 'Conteúdo do Documento';
      case 'tokens':
        return 'Token / API Key';
      default:
        return 'Conteúdo';
    }
  }

  bool get _isPasswordCategory => _selectedCategory == 'passwords';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Gmail pessoal',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'passwords',
                  child: Text('Senhas'),
                ),
                DropdownMenuItem(
                  value: 'certificates',
                  child: Text('Certificados'),
                ),
                DropdownMenuItem(
                  value: 'private_keys',
                  child: Text('Chaves Privadas'),
                ),
                DropdownMenuItem(
                  value: 'documents',
                  child: Text('Documentos'),
                ),
                DropdownMenuItem(
                  value: 'tokens',
                  child: Text('Tokens'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                  _usernameController.clear();
                  _passwordController.clear();
                  _urlController.clear();
                  _contentController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            if (_isPasswordCategory) ...[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuário / Email',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                ),
              ),
            ] else ...[
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: _getContentLabel(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveItem,
                      child: _isSaving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Salvar'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}