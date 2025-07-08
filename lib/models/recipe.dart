class Recipe {
  late final int id;
  final String title;
  final String description;
  final double price;
  final String image;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'] ?? '',
    );
  }
}
