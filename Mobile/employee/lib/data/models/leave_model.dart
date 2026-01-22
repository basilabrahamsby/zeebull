class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType; // 'Sick Leave', 'Casual Leave', 'Earned Leave', 'Emergency'
  final String reason;
  String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime requestedAt;
  final String? approvedBy;
  final String? rejectionReason;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.approvedBy,
    this.rejectionReason,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'].toString(),
      employeeId: json['employee_id'].toString(),
      employeeName: json['employee_name'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      leaveType: json['leave_type'],
      reason: json['reason'],
      status: json['status'] ?? 'Pending',
      requestedAt: DateTime.parse(json['requested_at']),
      approvedBy: json['approved_by'],
      rejectionReason: json['rejection_reason'],
    );
  }

  int get totalDays => endDate.difference(startDate).inDays + 1;
  
  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
}

class LeaveBalance {
  final int totalLeaves;
  final int usedLeaves;
  final int pendingLeaves;
  final int availableLeaves;
  final Map<String, int> leaveTypeBalance; // e.g., {'Sick Leave': 5, 'Casual Leave': 10}

  LeaveBalance({
    required this.totalLeaves,
    required this.usedLeaves,
    required this.pendingLeaves,
    required this.availableLeaves,
    required this.leaveTypeBalance,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      totalLeaves: json['total_leaves'] ?? 0,
      usedLeaves: json['used_leaves'] ?? 0,
      pendingLeaves: json['pending_leaves'] ?? 0,
      availableLeaves: json['available_leaves'] ?? 0,
      leaveTypeBalance: Map<String, int>.from(json['leave_type_balance'] ?? {}),
    );
  }
}
