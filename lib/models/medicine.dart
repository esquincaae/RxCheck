class Medicine {
  final int id;
  final String name;
  final String description;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'] ?? 'Sin título',
      description: json['description'] ?? '',
    );
  }
}
