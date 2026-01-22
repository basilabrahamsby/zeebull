class MonthlyReport {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int paidLeavesTaken;
  final int sickLeavesTaken;
  final int unpaidLeaves;
  final int paidLeaveBalance;
  final int sickLeaveBalance;
  final double netSalary;

  final int totalPaidLeavesYear;
  final int totalSickLeavesYear;

  MonthlyReport({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.paidLeavesTaken,
    required this.sickLeavesTaken,
    required this.unpaidLeaves,
    required this.paidLeaveBalance,
    required this.sickLeaveBalance,
    required this.netSalary,
    required this.totalPaidLeavesYear,
    required this.totalSickLeavesYear,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      paidLeavesTaken: json['paid_leaves_taken'] ?? 0,
      sickLeavesTaken: json['sick_leaves_taken'] ?? 0,
      unpaidLeaves: json['unpaid_leaves'] ?? 0,
      paidLeaveBalance: json['paid_leave_balance'] ?? 0,
      sickLeaveBalance: json['sick_leave_balance'] ?? 0,
      netSalary: (json['net_salary'] as num?)?.toDouble() ?? 0.0,
      totalPaidLeavesYear: json['total_paid_leaves_year'] ?? 24, // Default if missing
      totalSickLeavesYear: json['total_sick_leaves_year'] ?? 12,
    );
  }
}
