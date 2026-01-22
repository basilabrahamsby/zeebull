class Expense {
  final int id;
  final String description;
  final double amount;
  final String category;
  final String date;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String requestedBy;
  final String? image;
  final String? department;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.status,
    required this.requestedBy,
    this.image,
    this.department,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      description: json['description'] ?? 'Expense',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? 'General',
      date: json['date'] ?? '',
      status: json['status'] ?? 'Pending',
      requestedBy: json['employee_name'] ?? json['requested_by'] ?? 'Staff',
      image: json['image'],
      department: json['department'],
    );
  }
}
