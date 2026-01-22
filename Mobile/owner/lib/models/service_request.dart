class ServiceRequest {
  final int id;
  final String requestType;
  final String description;
  final String status;
  final String createdAt;
  final String roomNumber;
  final String employeeName;
  final bool isCheckoutRequest;
  final String? completedAt;
  final List<dynamic>? assetDamages;
  final List<dynamic>? inventoryData;

  ServiceRequest({
    required this.id,
    required this.requestType,
    required this.description,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.roomNumber,
    required this.employeeName,
    required this.isCheckoutRequest,
    this.assetDamages,
    this.inventoryData,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? 0,
      requestType: json['request_type'] ?? 'General',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      completedAt: json['completed_at'],
      roomNumber: json['room_number'] ?? '-',
      employeeName: json['employee_name'] ?? '-',
      isCheckoutRequest: json['is_checkout_request'] ?? false,
      assetDamages: json['asset_damages'],
      inventoryData: json['inventory_data_with_charges'],
    );
  }
}
