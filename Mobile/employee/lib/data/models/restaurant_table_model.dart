class RestaurantTable {
  final int id;
  final String tableNumber;
  final int seatingCapacity;
  String status; // 'Available', 'Occupied', etc.
  final int branchId;

  RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.seatingCapacity,
    required this.status,
    required this.branchId,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      tableNumber: json['table_number']?.toString() ?? 'Unknown',
      seatingCapacity: json['seating_capacity'] is int ? json['seating_capacity'] : int.tryParse(json['seating_capacity']?.toString() ?? '') ?? 4,
      status: json['status']?.toString() ?? 'Available',
      branchId: json['branch_id'] is int ? json['branch_id'] : int.tryParse(json['branch_id']?.toString() ?? '') ?? 1,
    );
  }
}
