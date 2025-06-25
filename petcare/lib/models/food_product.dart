class FoodProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String brand;
  final String weight;
  final int stock;
  final double rating;
  final DateTime createdAt;

  FoodProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.brand,
    required this.weight,
    required this.stock,
    required this.rating,
    required this.createdAt,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    return FoodProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      brand: json['brand'] ?? '',
      weight: json['weight'] ?? '',
      stock: json['stock'] ?? 0,
      rating: double.parse(json['rating'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'brand': brand,
      'weight': weight,
      'stock': stock,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
