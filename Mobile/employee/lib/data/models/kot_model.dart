class KOTItem {
  final int id;
  final int foodItemId;
  final String itemName;
  final int quantity;

  KOTItem({
    required this.id,
    required this.foodItemId,
    required this.itemName,
    required this.quantity,
  });

  factory KOTItem.fromJson(Map<String, dynamic> json) {
    return KOTItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      foodItemId: json['food_item_id'] is int ? json['food_item_id'] : int.tryParse(json['food_item_id'].toString()) ?? 0,
      itemName: json['food_item_name']?.toString() ?? 'Unknown Item',
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
    );
  }
}

class KOT {
  final int id;
  final String roomNumber;
  final int? roomId;
  final int? tableId;
  final String? tableNumber;
  final String waiterName;
  final DateTime createdAt;
  final List<KOTItem> items;
  String status; // 'pending', 'cooking', 'ready', 'completed'
  final String? deliveryRequest;
  final String orderType;
  int? assignedEmployeeId;
  int? preparedById;
  final String creatorName;
  final String chefName;
  final String? billingStatus;

  KOT({
    required this.id,
    required this.roomNumber,
    this.roomId,
    this.tableId,
    this.tableNumber,
    required this.waiterName,
    required this.createdAt,
    required this.items,
    required this.status,
    this.deliveryRequest,
    required this.orderType,
    this.assignedEmployeeId,
    this.preparedById,
    required this.creatorName,
    required this.chefName,
    this.billingStatus,
  });

  String get displayLocation => tableNumber != null && tableNumber!.isNotEmpty ? tableNumber! : roomNumber;

  factory KOT.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['items'] as List?)?.map((i) => KOTItem.fromJson(i)).toList() ?? [];
    return KOT(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      roomNumber: json['room_number']?.toString() ?? 'N/A',
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      tableId: json['table_id'] is int ? json['table_id'] : int.tryParse(json['table_id']?.toString() ?? ''),
      tableNumber: json['table_number']?.toString(),
      waiterName: json['employee_name']?.toString() ?? 'N/A', // This is assigned name
      createdAt: json['created_at'] != null 
          ? _parseDate(json['created_at'].toString()) 
          : DateTime.now(),
      items: itemsList,
      status: (() {
        final s = json['status']?.toString()?.toLowerCase() ?? 'pending';
        if (s == 'in_progress' || s == 'preparing' || s == 'accepted') return 'cooking';
        return s;
      })(),
      deliveryRequest: json['delivery_request']?.toString(),
      orderType: json['order_type']?.toString() ?? 'dine_in',
      assignedEmployeeId: json['assigned_employee_id'] is int ? json['assigned_employee_id'] : int.tryParse(json['assigned_employee_id']?.toString() ?? ''),
      preparedById: json['prepared_by_id'] is int ? json['prepared_by_id'] : int.tryParse(json['prepared_by_id']?.toString() ?? ''),
      creatorName: json['creator_name']?.toString() ?? 'N/A',
      chefName: json['chef_name']?.toString() ?? 'Not Started',
      billingStatus: json['billing_status']?.toString(),
    );
  }

  static DateTime _parseDate(String dateStr) {
    try {
      if (dateStr.endsWith('Z') || dateStr.contains('+')) {
        return DateTime.parse(dateStr).toLocal();
      }
      final parsed = DateTime.parse(dateStr);
      if (parsed.isUtc) {
        return DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
          parsed.millisecond,
          parsed.microsecond,
        );
      }
      return parsed;
    } catch (e) {
      return DateTime.now();
    }
  }
}
