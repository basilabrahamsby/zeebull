class ServiceRequest {
  final int id;
  final String serviceName;
  final String roomNumber;
  final String requestTime;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final String? notes;

  ServiceRequest({
    required this.id,
    required this.serviceName,
    required this.roomNumber,
    required this.requestTime,
    required this.status,
    this.notes,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? 0,
      serviceName: json['service_name'] ?? 'General Service',
      roomNumber: json['room_number']?.toString() ?? 'N/A',
      requestTime: json['created_at'] ?? '',
      status: json['status'] ?? 'Pending',
      notes: json['notes'],
    );
  }
}
