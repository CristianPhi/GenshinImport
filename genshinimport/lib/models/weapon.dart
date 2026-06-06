class Weapon {
  final int id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final double price;
  final String? imageUrl;

  Weapon({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.price,
    this.imageUrl,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image'],
    );
  }
}
