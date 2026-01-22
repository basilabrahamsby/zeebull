class InventoryItem {
  final int id;
  final String name;
  final double price; // Selling price for guest
  final String category;
  final bool isSellable;
  final String unit;
  final double currentStock;
  int consumedQty; // Local state for audit

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isSellable = false,
    this.unit = 'pcs',
    this.currentStock = 0.0,
    this.consumedQty = 0,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      // Price for guest is 'selling_price' in backend
      price: (json['selling_price'] ?? json['price'] ?? 0.0).toDouble(),
      category: json['category_name'] ?? json['category'] ?? 'General',
      isSellable: json['is_sellable_to_guest'] ?? false,
      unit: json['unit'] ?? 'pcs',
      currentStock: (json['current_stock'] ?? 0.0).toDouble(),
    );
  }
}
