import 'employee.dart';

class EmployeeStatusOverview {
  final List<Employee> activeEmployees;
  final List<Employee> inactiveEmployees;
  final List<Employee> onPaidLeave;
  final List<Employee> onSickLeave;
  final List<Employee> onUnpaidLeave;

  EmployeeStatusOverview({
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.onPaidLeave,
    required this.onSickLeave,
    required this.onUnpaidLeave,
  });

  factory EmployeeStatusOverview.fromJson(Map<String, dynamic> json) {
    return EmployeeStatusOverview(
      activeEmployees: (json['active_employees'] as List?)?.map((e) => Employee.fromJson(e)).toList() ?? [],
      inactiveEmployees: (json['inactive_employees'] as List?)?.map((e) => Employee.fromJson(e)).toList() ?? [],
      onPaidLeave: (json['on_paid_leave'] as List?)?.map((e) => Employee.fromJson(e)).toList() ?? [],
      onSickLeave: (json['on_sick_leave'] as List?)?.map((e) => Employee.fromJson(e)).toList() ?? [],
      onUnpaidLeave: (json['on_unpaid_leave'] as List?)?.map((e) => Employee.fromJson(e)).toList() ?? [],
    );
  }
}
