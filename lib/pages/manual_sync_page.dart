import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../db/database_provider.dart';
import '../models/backup_preview.dart';
import '../repositories/vault_repository.dart';
import '../services/backup_service.dart';

class ManualSyncPage extends StatefulWidget {
  const ManualSyncPage({super.key});

  @override
  State<ManualSyncPage> createState() => _ManualSyncPageState();
}

class _ManualSyncPageState extends State<ManualSyncPage> {
  late final BackupService _backupService;

  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    final repository = VaultRepository(DatabaseProvider.instance);
    _backupService = BackupService(repository);
  }

  Future<void> _exportBackup() async {
    try {
      setState(() {
        _isExporting = true;
      });

      final path = await _backupService.exportEncryptedBackup();

      if (!mounted) return;

      if (path == null) {
        _showMessage('Backup cancelado.', isError: false);
        return;
      }

      _showMessage(
        'Backup exportado com sucesso.\nArquivo salvo em:\n$path',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erro ao exportar backup: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      setState(() {
        _isImporting = true;
      });

      final preview = await _backupService.pickAndReadBackupPreview();

      if (!mounted) return;

      if (preview == null) {
        _showMessage('Importação cancelada.', isError: false);
        return;
      }

      setState(() {
        _isImporting = false;
      });

      final confirmed = await _showBackupPreviewDialog(preview);

      if (confirmed != true) {
        return;
      }

      setState(() {
        _isImporting = true;
      });

      final restoredCount = await _backupService.restoreFromPreview(preview);

      if (!mounted) return;

      _showMessage(
        'Backup restaurado com sucesso.\n$restoredCount item(ns) recuperado(s).',
        isError: false,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erro ao importar backup: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<bool?> _showBackupPreviewDialog(BackupPreview preview) {
    final exportedAt = preview.exportedAt;
    final exportedAtText = exportedAt == null
        ? 'Não disponível'
        : '${exportedAt.day.toString().padLeft(2, '0')}/'
        '${exportedAt.month.toString().padLeft(2, '0')}/'
        '${exportedAt.year} às '
        '${exportedAt.hour.toString().padLeft(2, '0')}:'
        '${exportedAt.minute.toString().padLeft(2, '0')}';

    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Prévia do backup',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewRow('Aplicativo', preview.appName),
              const SizedBox(height: 10),
              _buildPreviewRow('Versão do backup', '${preview.version}'),
              const SizedBox(height: 10),
              _buildPreviewRow('Data do backup', exportedAtText),
              const SizedBox(height: 10),
              _buildPreviewRow('Registros no backup', '${preview.itemCount}'),
              const SizedBox(height: 16),
              const Text(
                'Ao continuar, os dados atuais do cofre serão apagados e substituídos pelos dados deste backup.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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

  Widget _buildActionCard({
    required IconData icon,
    required Color accent,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    required bool loading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sincronização Manual',
                          style: TextStyle(
                            fontSize: 26,
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Exporte seu cofre criptografado para backup ou importe um backup de outro dispositivo.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildActionCard(
                    icon: Icons.upload_file_outlined,
                    accent: const Color(0xFF22C55E),
                    title: 'Exportar Backup',
                    description:
                    'Cria um arquivo JSON criptografado com todas as credenciais atuais do cofre.',
                    buttonText: 'Exportar Cofre',
                    onPressed: _exportBackup,
                    loading: _isExporting,
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.download_outlined,
                    accent: AppColors.primary,
                    title: 'Importar Backup',
                    description:
                    'Lê a prévia do backup antes de restaurar. A senha mestra da sessão atual precisa ser a mesma usada no backup.',
                    buttonText: 'Importar Backup',
                    onPressed: _importBackup,
                    loading: _isImporting,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Text(
                      'Atenção: ao importar um backup, os dados atuais do cofre serão substituídos.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}