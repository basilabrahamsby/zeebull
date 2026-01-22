class GuestProfile {
  final GuestDetails? guestDetails;
  final List<GuestBookingHistory> bookings;
  final List<GuestFoodHistory> foodOrders;
  final List<GuestServiceHistory> services;
  final List<GuestInventoryHistory> inventoryUsage;

  GuestProfile({
    this.guestDetails,
    required this.bookings,
    required this.foodOrders,
    required this.services,
    required this.inventoryUsage,
  });

  factory GuestProfile.fromJson(Map<String, dynamic> json) {
    return GuestProfile(
      guestDetails: json['guest_details'] != null ? GuestDetails.fromJson(json['guest_details']) : null,
      bookings: (json['bookings'] as List?)?.map((e) => GuestBookingHistory.fromJson(e)).toList() ?? [],
      foodOrders: (json['food_orders'] as List?)?.map((e) => GuestFoodHistory.fromJson(e)).toList() ?? [],
      services: (json['services'] as List?)?.map((e) => GuestServiceHistory.fromJson(e)).toList() ?? [],
      inventoryUsage: (json['inventory_usage'] as List?)?.map((e) => GuestInventoryHistory.fromJson(e)).toList() ?? [],
    );
  }
}

class GuestDetails {
  final String? name;
  final String? email;
  final String? mobile;

  GuestDetails({this.name, this.email, this.mobile});

  factory GuestDetails.fromJson(Map<String, dynamic> json) {
    return GuestDetails(
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }
}

class GuestBookingHistory {
  final int id;
  final String type;
  final String checkIn;
  final String checkOut;
  final String status;
  final List<String> rooms;
  final String? idCardImageUrl;
  final String? guestPhotoUrl;

  GuestBookingHistory({
    required this.id,
    required this.type,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.rooms,
    this.idCardImageUrl,
    this.guestPhotoUrl,
  });

  factory GuestBookingHistory.fromJson(Map<String, dynamic> json) {
    return GuestBookingHistory(
      id: json['id'],
      type: json['type'],
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      status: json['status'] ?? '',
      rooms: List<String>.from(json['rooms'] ?? []),
      idCardImageUrl: json['id_card_image_url'],
      guestPhotoUrl: json['guest_photo_url'],
    );
  }
}

class GuestFoodHistory {
  final int id;
  final String? roomNumber;
  final double amount;
  final String status;
  final String createdAt;
  final List<String> items; // Simplified items list string or create Item model if needed

  GuestFoodHistory({
    required this.id,
    this.roomNumber,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory GuestFoodHistory.fromJson(Map<String, dynamic> json) {
    // Items come as list of objects {food_item_id, quantity, etc}
    // Dashboard just maps them to string name + qty.
    // The API returns 'items': [FoodOrderItemOut...]
    // FoodOrderItemOut has 'food_item': {name...}
    
    final itemList = (json['items'] as List?)?.map((item) {
      final name = item['food_item']?['name'] ?? 'Unknown';
      final qty = item['quantity'] ?? 0;
      return "$name (x$qty)";
    }).toList() ?? [];

    return GuestFoodHistory(
      id: json['id'],
      roomNumber: json['room_number'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      items: List<String>.from(itemList),
    );
  }
}

class GuestServiceHistory {
  final int id;
  final String? serviceName;
  final String? roomNumber;
  final double charges;
  final String status;
  final String assignedAt;

  GuestServiceHistory({
    required this.id,
    this.serviceName,
    this.roomNumber,
    required this.charges,
    required this.status,
    required this.assignedAt,
  });

  factory GuestServiceHistory.fromJson(Map<String, dynamic> json) {
    return GuestServiceHistory(
      id: json['id'],
      serviceName: json['service_name'],
      roomNumber: json['room_number'],
      charges: (json['charges'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      assignedAt: json['assigned_at'] ?? '',
    );
  }
}

class GuestInventoryHistory {
  final String itemName;
  final double quantity;
  final String unit;
  final String issueDate;
  final String roomNumber;
  final String? category;
  final double? cost;

  GuestInventoryHistory({
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.issueDate,
    required this.roomNumber,
    this.category,
    this.cost,
  });

  factory GuestInventoryHistory.fromJson(Map<String, dynamic> json) {
    return GuestInventoryHistory(
      itemName: json['item_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      issueDate: json['issue_date'] ?? '',
      roomNumber: json['room_number'] ?? '',
      category: json['category'],
      cost: (json['cost'] as num?)?.toDouble(),
    );
  }
}
