class Room {
  final int id;
  final String roomNumber;
  final String type;
  final String status; // 'Available', 'Occupied', 'Maintenance', 'Dirty'
  final String housekeepingStatus; 
  final double price;
  final String? imageUrl;
  final String? housekeepingUpdatedAt;
  final String? lastMaintenanceDate;
  final int adults;
  final int children;
  
  // Features
  final bool airConditioning;
  final bool wifi;
  final bool bathroom;
  final bool tv;
  final bool kitchen;
  final bool parking;

  Room({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.status,
    required this.housekeepingStatus,
    required this.price,
    this.imageUrl,
    this.housekeepingUpdatedAt,
    this.lastMaintenanceDate,
    this.adults = 2,
    this.children = 0,
    this.airConditioning = false,
    this.wifi = false,
    this.bathroom = false,
    this.tv = false,
    this.kitchen = false,
    this.parking = false,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      roomNumber: json['number']?.toString() ?? 'Unknown',
      type: json['type'] ?? 'Standard',
      status: json['status'] ?? 'Available',
      housekeepingStatus: json['housekeeping_status'] ?? 'Clean',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      housekeepingUpdatedAt: json['housekeeping_updated_at'],
      lastMaintenanceDate: json['last_maintenance_date'],
      adults: json['adults'] ?? 2,
      children: json['children'] ?? 0,
      airConditioning: json['air_conditioning'] ?? false,
      wifi: json['wifi'] ?? false,
      bathroom: json['bathroom'] ?? false,
      tv: json['tv'] ?? false, // Mapped from family_room or living_area? Used 'tv' as generic. 
      // Web Admin has 'living_area', 'family_room', 'terrace', 'bbq', 'garden', 'dining', 'breakfast'.
      // I'll stick to a subset for mobile.
      kitchen: json['kitchen'] ?? false,
      parking: json['parking'] ?? false,
    );
  }
}
