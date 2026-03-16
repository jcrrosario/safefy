import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../repositories/vault_repository.dart';
import 'add_vault_item_page.dart';
import 'manual_sync_page.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final VaultRepository _repository;

  final TextEditingController _searchController = TextEditingController();

  List<VaultItem> _allItems = [];
  List<VaultItem> _filteredItems = [];

  bool _isLoading = true;
  String _selectedCategory = 'all';

  final Map<int, bool> _visiblePasswords = {};

  @override
  void initState() {
    super.initState();
    _repository = VaultRepository(DatabaseProvider.instance);
    _loadItems();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openManualSync() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ManualSyncPage(),
      ),
    );

    if (result == true) {
      await _loadItems();
    }
  }

  Future<void> _loadItems() async {
    final items = await _repository.getAllItems();

    if (!mounted) return;

    setState(() {
      _allItems = items;
      _isLoading = false;
    });

    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<VaultItem> items = List.from(_allItems);

    if (_selectedCategory != 'all') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    if (query.isNotEmpty) {
      items = items.where((item) {
        final title = item.title.toLowerCase();
        final category = item.category.toLowerCase();
        final username = (item.username ?? '').toLowerCase();
        final url = (item.url ?? '').toLowerCase();
        final notes = (item.notes ?? '').toLowerCase();
        final content = (item.content ?? '').toLowerCase();

        return title.contains(query) ||
            category.contains(query) ||
            username.contains(query) ||
            url.contains(query) ||
            notes.contains(query) ||
            content.contains(query);
      }).toList();
    }

    setState(() {
      _filteredItems = items;
    });
  }

  Future<void> _openAddItem() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewItemPage(repository: _repository),
      ),
    );

    if (result == true) {
      await _loadItems();
    }
  }

  Future<void> _openEditItem(VaultItem item) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewItemPage(
          repository: _repository,
          item: item,
        ),
      ),
    );

    if (result == true) {
      await _loadItems();
    }
  }

  Future<void> _deleteItem(VaultItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Excluir item',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Tem certeza que deseja excluir "${item.title}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _repository.deleteItem(item.id);

    _showMessage('Item excluído com sucesso.', isError: false);
    await _loadItems();
  }

  Future<void> _copyToClipboard(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    _showMessage('$label copiado.', isError: false);
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

  int _countByCategory(String category) {
    if (category == 'all') return _allItems.length;
    return _allItems.where((item) => item.category == category).length;
  }

  String _categoryLabel(String value) {
    switch (value) {
      case 'passwords':
        return 'Senhas';
      case 'certificates':
        return 'Certificados';
      case 'private_keys':
        return 'Chaves';
      case 'documents':
        return 'Documentos';
      case 'tokens':
        return 'Tokens';
      default:
        return 'Todos';
    }
  }

  IconData _categoryIcon(String value) {
    switch (value) {
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
        return Icons.apps_outlined;
    }
  }

  Color _categoryAccent(String value) {
    switch (value) {
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

  String _maskedPassword(String value) {
    if (value.isEmpty) return '';
    return '••••••••••';
  }

  Widget _buildCategoryChip({
    required String value,
    required String label,
  }) {
    final isSelected = _selectedCategory == value;
    final count = _countByCategory(value);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _categoryIcon(value),
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 44,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Seu cofre está vazio',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Adicione sua primeira credencial para começar',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _openAddItem,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Adicionar primeiro item',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    List<Widget>? trailingActions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailingActions != null) ...trailingActions,
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color ?? Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(VaultItem item) {
    final accent = _categoryAccent(item.category);
    final categoryLabel = _categoryLabel(item.category);
    final isPasswordItem = item.category == 'passwords';
    final isPasswordVisible = _visiblePasswords[item.id] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(item.category),
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  categoryLabel,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if ((item.username ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              label: 'USUÁRIO',
              value: item.username!,
              trailingActions: [
                _buildActionIcon(
                  icon: Icons.copy_outlined,
                  onTap: () => _copyToClipboard(item.username!, 'Usuário'),
                ),
              ],
            ),
          ],
          if (isPasswordItem && (item.password ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildInfoRow(
              label: 'SENHA',
              value: isPasswordVisible
                  ? item.password!
                  : _maskedPassword(item.password!),
              trailingActions: [
                _buildActionIcon(
                  icon: isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onTap: () {
                    setState(() {
                      _visiblePasswords[item.id] = !isPasswordVisible;
                    });
                  },
                ),
                _buildActionIcon(
                  icon: Icons.copy_outlined,
                  onTap: () => _copyToClipboard(item.password!, 'Senha'),
                ),
              ],
            ),
          ],
          if (!isPasswordItem && (item.content ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildInfoRow(
              label: 'CONTEÚDO',
              value: item.content!,
              trailingActions: [
                _buildActionIcon(
                  icon: Icons.copy_outlined,
                  onTap: () => _copyToClipboard(item.content!, 'Conteúdo'),
                ),
              ],
            ),
          ],
          if ((item.url ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildInfoRow(
              label: 'URL',
              value: item.url!,
            ),
          ],
          if ((item.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildInfoRow(
              label: 'NOTAS',
              value: item.notes!,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Atualizado em ${item.updatedAt.day.toString().padLeft(2, '0')}/${item.updatedAt.month.toString().padLeft(2, '0')}/${item.updatedAt.year}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              _buildActionIcon(
                icon: Icons.edit_outlined,
                onTap: () => _openEditItem(item),
                color: AppColors.primaryLight,
              ),
              _buildActionIcon(
                icon: Icons.delete_outline,
                onTap: () => _deleteItem(item),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryItems = [
      {'value': 'all', 'label': 'Todos'},
      {'value': 'passwords', 'label': 'Senhas'},
      {'value': 'certificates', 'label': 'Certificados'},
      {'value': 'private_keys', 'label': 'Chaves'},
      {'value': 'documents', 'label': 'Documentos'},
      {'value': 'tokens', 'label': 'Tokens'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SafeFy',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF123C2D),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF1F7A59),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: Color(0xFF4ADE80),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Criptografado',
                              style: TextStyle(
                                color: Color(0xFFB7F7CB),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          onPressed: _openManualSync,
                          icon: const Icon(
                            Icons.sync_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar no cofre...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: _openAddItem,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = categoryItems[index];
                    return _buildCategoryChip(
                      value: item['value']!,
                      label: item['label']!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              _filteredItems.isEmpty
                  ? _buildEmptyState()
                  : Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _filteredItems.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return _buildItemCard(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}