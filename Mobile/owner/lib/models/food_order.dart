class FoodOrder {
  final int id;
  final String roomNumber;
  final String status; // 'Ordered', 'Preparing', 'Ready', 'Delivered'
  final double totalAmount;
  final List<FoodOrderItem> items;
  final String createdAt;
  final int? assignedEmployeeId;
  final String orderType; // 'dine_in', 'room_service'

  FoodOrder({
    required this.id,
    required this.roomNumber,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.assignedEmployeeId,
    required this.orderType,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      id: json['id'] ?? 0,
      roomNumber: (json['room_number'] is Map) 
          ? (json['room_number']['number']?.toString() ?? 'N/A') 
          : (json['room_number']?.toString() ?? 'N/A'),
      status: json['status'] ?? 'Ordered',
      totalAmount: (json['amount'] ?? json['total_amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      assignedEmployeeId: (json['assigned_employee'] is Map) 
          ? json['assigned_employee']['id'] 
          : json['assigned_employee_id'],
      orderType: json['order_type'] ?? 'room_service',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => FoodOrderItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class FoodOrderItem {
  final int foodItemId;
  final String name;
  final int quantity;
  final double price;

  FoodOrderItem({
    required this.foodItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory FoodOrderItem.fromJson(Map<String, dynamic> json) {
    return FoodOrderItem(
      foodItemId: json['food_item_id'] ?? 0,
      name: json['item_name'] ?? (json['food_item'] != null ? json['food_item']['name'] : 'Item'),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
