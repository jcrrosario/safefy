class VaultItemModel {
  final int? id;
  final String title;
  final String category;
  final String? username;
  final String? password;
  final String? url;
  final String? content;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultItemModel({
    this.id,
    required this.title,
    required this.category,
    this.username,
    this.password,
    this.url,
    this.content,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}