class InventoryItem {
  final int id;
  final String name;
  final String category;
  final double quantity;
  final double minQuantity;
  final String unit;
  final double price;
  final String? lastVendor;
  final String? lastPurchaseDate;
  final String? itemCode; // Added
  final bool isAssetFixed;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    this.price = 0.0,
    this.lastVendor,
    this.lastPurchaseDate,
    this.itemCode,
    this.isAssetFixed = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: (json['id'] is int) ? json['id'] : 0,
      name: json['name'] ?? 'Unknown Item',
      category: json['category_name'] ?? 'General',
      quantity: (json['current_stock'] is num) ? (json['current_stock'] as num).toDouble() : (json['stock_quantity'] is num ? (json['stock_quantity'] as num).toDouble() : 0.0),
      minQuantity: (json['min_stock_level'] is num) ? (json['min_stock_level'] as num).toDouble() : 10.0,
      unit: json['unit'] ?? 'units',
      price: (json['unit_price'] is num) ? (json['unit_price'] as num).toDouble() : 0.0,
      lastVendor: json['last_vendor_name'],
      lastPurchaseDate: json['last_purchase_date'],
      itemCode: json['item_code'], // Added
      isAssetFixed: json['is_asset_fixed'] == true,
    );
  }

  bool get isLowStock => quantity <= minQuantity;
}
