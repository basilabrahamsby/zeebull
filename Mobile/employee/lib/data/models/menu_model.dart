class MenuItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'].toString(),
      name: json['name'],
      category: json['category'],
      price: json['price']?.toDouble() ?? 0.0,
      description: json['description'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}

class CartItem {
  final MenuItem item;
  int quantity;
  String? notes;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.notes,
  });
}
