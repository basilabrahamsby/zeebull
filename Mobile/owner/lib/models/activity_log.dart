class ActivityLog {
  final int id;
  final String action;
  final String method;
  final String path;
  final int statusCode;
  final String? userName;
  final String? userEmail;
  final String timestamp;
  final String details;

  ActivityLog({
    required this.id,
    required this.action,
    required this.method,
    required this.path,
    required this.statusCode,
    this.userName,
    this.userEmail,
    required this.timestamp,
    required this.details,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] ?? 0,
      action: json['action'] ?? 'Unknown',
      method: json['method'] ?? 'GET',
      path: json['path'] ?? '',
      statusCode: json['status_code'] ?? 200,
      userName: json['user_name'],
      userEmail: json['user_email'],
      timestamp: json['timestamp'] ?? '',
      details: json['details'] ?? '',
    );
  }
}
