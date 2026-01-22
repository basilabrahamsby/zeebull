class FoodItem {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String? image;
  final bool isAvailable;
  final int totalSold; // For "Best Sellers"

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.image,
    required this.isAvailable,
    required this.totalSold,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: (json['category'] is Map) 
          ? (json['category']['name'] ?? 'General') 
          : (json['category']?.toString() ?? 'General'),
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'], // Backend usually returns 'image' field with URL/Path
      isAvailable: json['is_available'] ?? true,
      totalSold: json['total_sold'] ?? 0,
    );
  }
}
