class AttendanceRecord {
  final String id;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final String status; // 'Present', 'Absent', 'Half Day', 'Leave'
  final Duration? workedHours;
  final String? location; // GPS location if needed

  AttendanceRecord({
    required this.id,
    required this.date,
    this.clockIn,
    this.clockOut,
    required this.status,
    this.workedHours,
    this.location,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      clockIn: json['clock_in'] != null ? DateTime.parse(json['clock_in']) : null,
      clockOut: json['clock_out'] != null ? DateTime.parse(json['clock_out']) : null,
      status: json['status'] ?? 'Absent',
      workedHours: json['worked_hours'] != null 
          ? Duration(minutes: json['worked_hours']) 
          : null,
      location: json['location'],
    );
  }

  bool get isClockedIn => clockIn != null && clockOut == null;
  bool get isComplete => clockIn != null && clockOut != null;
}

class SalaryInfo {
  final double monthlySalary;
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int halfDays;
  final double perDaySalary;
  final double earnedSalary;
  final double deductions;
  final double netSalary;

  SalaryInfo({
    required this.monthlySalary,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.absentDays,
    required this.halfDays,
    required this.perDaySalary,
    required this.earnedSalary,
    required this.deductions,
    required this.netSalary,
  });

  factory SalaryInfo.fromJson(Map<String, dynamic> json) {
    return SalaryInfo(
      monthlySalary: json['monthly_salary']?.toDouble() ?? 0.0,
      totalWorkingDays: json['total_working_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      halfDays: json['half_days'] ?? 0,
      perDaySalary: json['per_day_salary']?.toDouble() ?? 0.0,
      earnedSalary: json['earned_salary']?.toDouble() ?? 0.0,
      deductions: json['deductions']?.toDouble() ?? 0.0,
      netSalary: json['net_salary']?.toDouble() ?? 0.0,
    );
  }

  double get attendancePercentage => 
      totalWorkingDays > 0 ? (presentDays / totalWorkingDays) * 100 : 0;
}
