class ServiceRequest {
  final String id;
  final String roomNumber;
  final String type; // 'Towels', 'Toiletries', 'Cleaning', 'Maintenance', 'Other'
  final String description;
  final String priority; // 'Low', 'Medium', 'High', 'Urgent'
  String status; // 'Pending', 'In Progress', 'Completed'
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? guestName;
  final List<dynamic> refillItems;
  final int? employeeId;
  final String? employeeName;

  ServiceRequest({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.guestName,
    this.refillItems = const [],
    this.employeeId,
    this.employeeName,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'].toString(),
      roomNumber: json['room_number']?.toString() ?? 'N/A',
      type: json['type']?.toString() ?? 'Other',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString().replaceAll(RegExp(r'Z$'), ''))
          : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'].toString().replaceAll(RegExp(r'Z$'), ''))
          : null,
      guestName: json['guest_name']?.toString(), // Keep nullable
      refillItems: json['refill_data'] is List ? json['refill_data'] : [],
      employeeId: json['employee_id'],
      employeeName: json['employee_name']?.toString(),
    );
  }
}
