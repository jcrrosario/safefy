class BackupPreview {
  final String appName;
  final int version;
  final DateTime? exportedAt;
  final int itemCount;
  final List<dynamic> items;

  const BackupPreview({
    required this.appName,
    required this.version,
    required this.exportedAt,
    required this.itemCount,
    required this.items,
  });
}