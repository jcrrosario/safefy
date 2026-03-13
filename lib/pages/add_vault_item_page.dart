import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../db/app_database.dart';
import '../repositories/vault_repository.dart';

class NewItemPage extends StatefulWidget {
  final VaultRepository repository;
  final VaultItem? item;

  const NewItemPage({
    super.key,
    required this.repository,
    this.item,
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

  late String _selectedCategory;
  bool _isSaving = false;
  bool _obscurePassword = true;

  bool get _isEditing => widget.item != null;
  bool get _isPasswordCategory => _selectedCategory == 'passwords';

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _selectedCategory = item?.category ?? 'passwords';
    _titleController.text = item?.title ?? '';
    _usernameController.text = item?.username ?? '';
    _passwordController.text = item?.password ?? '';
    _urlController.text = item?.url ?? '';
    _contentController.text = item?.content ?? '';
    _notesController.text = item?.notes ?? '';
  }

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

    if (_isPasswordCategory && password.isEmpty) {
      _showMessage('Informe a senha.');
      return;
    }

    if (!_isPasswordCategory && content.isEmpty) {
      _showMessage('Informe o conteúdo do item.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (_isEditing) {
      await widget.repository.updateItem(
        id: widget.item!.id,
        title: title,
        category: _selectedCategory,
        username: username.isEmpty ? null : username,
        password: password.isEmpty ? null : password,
        url: url.isEmpty ? null : url,
        content: content.isEmpty ? null : content,
        notes: notes.isEmpty ? null : notes,
        createdAt: widget.item!.createdAt,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }

    await widget.repository.addItem(
      title: title,
      category: _selectedCategory,
      username: username.isEmpty ? null : username,
      password: password.isEmpty ? null : password,
      url: url.isEmpty ? null : url,
      content: content.isEmpty ? null : content,
      notes: notes.isEmpty ? null : notes,
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Item' : 'Novo Item'),
        centerTitle: true,
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
                          : Text(_isEditing ? 'Salvar Alterações' : 'Salvar'),
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