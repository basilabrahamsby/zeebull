class Room {
  final int id;
  final String roomNumber;
  final String type;
  final String status; // 'Available', 'Occupied', 'Maintenance', 'Dirty'
  final double price;

  Room({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.status,
    required this.price,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      roomNumber: json['number']?.toString() ?? json['room_number']?.toString() ?? 'Unknown',
      type: json['type']?.toString() ?? json['room_type']?.toString() ?? 'Standard',
      status: json['status']?.toString() ?? 'Available', 
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
