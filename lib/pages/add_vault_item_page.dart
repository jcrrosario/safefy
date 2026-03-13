import 'dart:math';
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

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor:
        isError ? AppColors.error : AppColors.successStrong,
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

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'passwords':
        return 'Senhas';
      case 'certificates':
        return 'Certificados';
      case 'private_keys':
        return 'Chaves Privadas';
      case 'documents':
        return 'Documentos';
      case 'tokens':
        return 'Tokens';
      default:
        return 'Senhas';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'passwords':
        return Icons.key_outlined;
      case 'certificates':
        return Icons.verified_user_outlined;
      case 'private_keys':
        return Icons.vpn_key_outlined;
      case 'documents':
        return Icons.description_outlined;
      case 'tokens':
        return Icons.password_outlined;
      default:
        return Icons.key_outlined;
    }
  }

  Color _getCategoryAccent(String category) {
    switch (category) {
      case 'passwords':
        return const Color(0xFF38BDF8);
      case 'certificates':
        return const Color(0xFF34D399);
      case 'private_keys':
        return const Color(0xFFF59E0B);
      case 'documents':
        return const Color(0xFFA78BFA);
      case 'tokens':
        return const Color(0xFFF472B6);
      default:
        return AppColors.primaryLight;
    }
  }

  String _generateStrongPassword({int length = 18}) {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}<>?';
    const all = upper + lower + numbers + symbols;

    final random = Random.secure();

    final chars = <String>[
      upper[random.nextInt(upper.length)],
      lower[random.nextInt(lower.length)],
      numbers[random.nextInt(numbers.length)],
      symbols[random.nextInt(symbols.length)],
    ];

    while (chars.length < length) {
      chars.add(all[random.nextInt(all.length)]);
    }

    chars.shuffle(random);
    return chars.join();
  }

  void _generatePassword() {
    final password = _generateStrongPassword();
    setState(() {
      _passwordController.text = password;
      _obscurePassword = true;
    });
    _showMessage('Senha segura gerada.', isError: false);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildCategorySelector() {
    final accent = _getCategoryAccent(_selectedCategory);

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        labelText: 'Categoria',
        prefixIcon: Icon(
          _getCategoryIcon(_selectedCategory),
          color: accent,
        ),
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
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _buildLabel('Usuário / Email'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            hintText: 'Ex: seuemail@provedor.com',
          ),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildLabel('Senha'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Digite ou gere uma senha segura',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Gerar senha',
                  onPressed: _generatePassword,
                  icon: const Icon(Icons.auto_awesome_outlined),
                ),
                IconButton(
                  tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildLabel('URL'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'Ex: https://mail.google.com',
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _buildLabel(_getContentLabel()),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Informe o conteúdo com segurança',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 110),
              child: Icon(
                _getCategoryIcon(_selectedCategory),
                color: _getCategoryAccent(_selectedCategory),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _buildLabel('Notas'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Informações adicionais',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    final accent = _getCategoryAccent(_selectedCategory);

    return Row(
      children: [
        Expanded(
          child: Text(
            _isEditing ? 'Editar Item' : 'Novo Item',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(_selectedCategory),
                size: 14,
                color: accent,
              ),
              const SizedBox(width: 6),
              Text(
                _getCategoryLabel(_selectedCategory),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return _buildSectionCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _getCategoryAccent(_selectedCategory).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(_selectedCategory),
              color: _getCategoryAccent(_selectedCategory),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Atualize seu item com segurança' : 'Adicione um novo item ao cofre',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Todos os dados sensíveis são protegidos antes de serem armazenados.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _isSaving
                  ? null
                  : () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                _isEditing ? 'Salvar Alterações' : 'Salvar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  _buildTopHeader(),
                  const SizedBox(height: 18),
                  _buildHeaderCard(),
                  const SizedBox(height: 18),
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Título *'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Ex: Gmail pessoal',
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildCategorySelector(),
                        const SizedBox(height: 18),
                        if (_isPasswordCategory)
                          _buildPasswordFields()
                        else
                          _buildContentField(),
                        const SizedBox(height: 18),
                        _buildNotesField(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}