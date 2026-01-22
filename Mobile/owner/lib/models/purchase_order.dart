class PurchaseOrder {
  final int id;
  final String purchaseNumber;
  final int vendorId;
  final String vendorName;
  final double totalAmount;
  final String status;
  final String date;
  final int itemCount;
  final String paymentStatus;
  final List<dynamic> details; // Added

  PurchaseOrder({
    required this.id,
    required this.purchaseNumber,
    required this.vendorId,
    required this.vendorName,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.itemCount,
    required this.paymentStatus,
    this.details = const [], // Added
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] ?? 0,
      purchaseNumber: json['purchase_number'] ?? '',
      vendorId: json['vendor_id'] ?? 0,
      vendorName: json['vendor_name'] ?? 'Unknown Vendor',
      totalAmount: (json['total_amount'] is num) 
          ? (json['total_amount'] as num).toDouble() 
          : (json['total_amount'] is String && double.tryParse(json['total_amount']) != null)
              ? double.parse(json['total_amount'])
              : 0.0,
      status: json['status'] ?? 'draft',
      date: json['purchase_date'] ?? '',
      itemCount: (json['details'] as List?)?.length ?? 0, // Restored
      paymentStatus: json['payment_status'] ?? 'pending',
      details: json['details'] ?? [], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_number': purchaseNumber,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'total_amount': totalAmount,
      'status': status,
      'purchase_date': date,
      'payment_status': paymentStatus,
      'details': details, // Included
    };
  }
}
