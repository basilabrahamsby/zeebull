class FoodItemDetail {
  final String name;
  final int quantity;
  final double price;

  FoodItemDetail({required this.name, required this.quantity, required this.price});

  factory FoodItemDetail.fromJson(Map<String, dynamic> json) {
    return FoodItemDetail(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class FoodOrderSummary {
  final int id;
  final double amount;
  final String status;
  final String createdAt;
  final List<String> items;

  FoodOrderSummary({required this.id, required this.amount, required this.status, required this.createdAt, required this.items});

  factory FoodOrderSummary.fromJson(Map<String, dynamic> json) {
    return FoodOrderSummary(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      items: (json['items'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class ServiceRequestSummary {
  final int id;
  final String serviceName;
  final double charges;
  final String status;
  final String assignedAt;

  ServiceRequestSummary({required this.id, required this.serviceName, required this.charges, required this.status, required this.assignedAt});

  factory ServiceRequestSummary.fromJson(Map<String, dynamic> json) {
    return ServiceRequestSummary(
      id: json['id'] ?? 0,
      serviceName: json['service_name'] ?? 'Unknown',
      charges: (json['charges'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      assignedAt: json['assigned_at'] ?? '',
    );
  }
}

class InventoryUsageSummary {
  final String itemName;
  final double quantity;
  final String unit;
  final String issuedAt;
  final bool isPayable;
  final double unitPrice;
  final bool isDamaged;
  final String? notes;

  InventoryUsageSummary({
    required this.itemName, 
    required this.quantity, 
    required this.unit, 
    required this.issuedAt,
    this.isPayable = false,
    this.unitPrice = 0.0,
    this.isDamaged = false,
    this.notes
  });

  factory InventoryUsageSummary.fromJson(Map<String, dynamic> json) {
    return InventoryUsageSummary(
      itemName: json['item_name'] ?? 'Unknown',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      issuedAt: json['issued_at'] ?? '',
      isPayable: json['is_payable'] ?? false,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      isDamaged: json['is_damaged'] ?? false,
      notes: json['notes'],
    );
  }
}

class PaymentDetails {
  final int id;
  final double amount;
  final String method;
  final String date;

  PaymentDetails({required this.id, required this.amount, required this.method, required this.date});

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? 'cash',
      date: json['created_at'] ?? '',
    );
  }
}

class BookingDetails {
  final int id;
  final String guestName;
  final String? guestMobile;
  final String? guestEmail;
  final String status;
  final String checkIn;
  final String checkOut;
  final String roomNumber;
  final String? idCardImageUrl;
  final String? guestPhotoUrl;
  final double totalAmount;
  final double foodOrdersTotal;
  final double advanceDeposit;
  final String source;
  final String? packageName;
  
  final bool isIdVerified;
  final String? digitalSignatureUrl;
  final String? specialRequests;
  final String? preferences;
  
  final List<FoodOrderSummary> foodOrders;
  final List<ServiceRequestSummary> serviceRequests;
  final List<InventoryUsageSummary> inventoryUsage;
  final List<PaymentDetails> payments;

  BookingDetails({
    required this.id,
    required this.guestName,
    this.guestMobile,
    this.guestEmail,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.roomNumber,
    this.idCardImageUrl,
    this.guestPhotoUrl,
    required this.totalAmount,
    required this.foodOrdersTotal,
    required this.advanceDeposit,
    this.source = 'Direct',
    this.packageName,
    this.isIdVerified = false,
    this.digitalSignatureUrl,
    this.specialRequests,
    this.preferences,
    required this.foodOrders,
    required this.serviceRequests,
    required this.inventoryUsage,
    required this.payments,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      id: json['id'] ?? 0,
      guestName: json['guest_name'] ?? 'Unknown',
      guestMobile: json['guest_mobile'],
      guestEmail: json['guest_email'],
      status: json['status'] ?? 'booked',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      roomNumber: json['room_number'] ?? '', // This might be complex if multiple rooms, but current UI assumes one primary room
      idCardImageUrl: json['id_card_image_url'],
      guestPhotoUrl: json['guest_photo_url'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      foodOrdersTotal: (json['food_orders_total'] ?? 0).toDouble(),
      advanceDeposit: (json['advance_deposit'] ?? 0).toDouble(),
      source: json['source'] ?? 'Direct',
      packageName: json['package_name'],
      isIdVerified: json['is_id_verified'] ?? false,
      digitalSignatureUrl: json['digital_signature_url'],
      specialRequests: json['special_requests'],
      preferences: json['preferences'],
      foodOrders: (json['food_orders'] as List? ?? []).map((e) => FoodOrderSummary.fromJson(e)).toList(),
      serviceRequests: (json['service_requests'] as List? ?? []).map((e) => ServiceRequestSummary.fromJson(e)).toList(),
      inventoryUsage: (json['inventory_usage'] as List? ?? []).map((e) => InventoryUsageSummary.fromJson(e)).toList(),
      payments: (json['payments'] as List? ?? []).map((e) => PaymentDetails.fromJson(e)).toList(),
    );
  }
}
