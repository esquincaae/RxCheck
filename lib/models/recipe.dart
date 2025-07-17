class Recipe {
  late final int id;
  final String issue_at;
  late final String? qr;

  Recipe({
    required this.id,
    required this.issue_at,
    required this.qr,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      issue_at: json['issue_at'] ?? 'Sin título',
      qr: json['qr_image'],
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, issue_at: $issue_at)';
  }
}
