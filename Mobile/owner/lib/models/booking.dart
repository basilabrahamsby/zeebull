class Booking {
  final int id;
  final String bookingReference;
  final String guestName;
  final String checkInDate;
  final String checkOutDate;
  final String status;
  final String amount;
  final String roomNumber;
  final bool isPackage; 

  final String roomType;
  final int adults;
  final int children;
  final String source;
  final String packageName;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.guestName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.amount,
    required this.roomNumber,
    required this.isPackage,
    this.roomType = 'Standard',
    this.adults = 2,
    this.children = 0,
    this.source = 'Direct',
    this.packageName = '',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Calculate amount from total_amount or fallback to room prices
    double calculatedAmount = 0.0;
    
    if (json['total_amount'] != null && json['total_amount'] > 0) {
      calculatedAmount = (json['total_amount'] as num).toDouble();
    } else if (json['rooms'] != null && (json['rooms'] as List).isNotEmpty) {
      // Fallback: Calculate from room prices and stay duration
      try {
        final rooms = json['rooms'] as List;
        final checkIn = DateTime.tryParse(json['check_in'] ?? '');
        final checkOut = DateTime.tryParse(json['check_out'] ?? '');
        
        if (checkIn != null && checkOut != null) {
          final nights = checkOut.difference(checkIn).inDays;
          for (var room in rooms) {
            final roomPrice = (room['price'] ?? 0) as num;
            calculatedAmount += roomPrice.toDouble() * nights;
          }
        }
      } catch (e) {
        print('Error calculating booking amount: $e');
      }
    }

    String rType = 'Standard';
    if (json['rooms'] != null && (json['rooms'] as List).isNotEmpty) {
      rType = json['rooms'][0]['type'] ?? 'Standard';
    }
    
    return Booking(
      id: json['id'] ?? 0,
      bookingReference: json['display_id'] ?? 'Ref: ${json['id']}',
      guestName: json['guest_name'] ?? 'Unknown',
      checkInDate: json['check_in'] ?? '',
      checkOutDate: json['check_out'] ?? '',
      status: json['status'] ?? 'Pending',
      amount: calculatedAmount > 0 ? calculatedAmount.toStringAsFixed(2) : '0',
      roomNumber: (json['rooms'] != null && (json['rooms'] as List).isNotEmpty) 
          ? json['rooms'][0]['number'].toString() 
          : '-',
      isPackage: json['is_package'] ?? false,
      roomType: rType,
      adults: json['adults'] ?? 2,
      children: json['children'] ?? 0,
      source: json['source'] ?? 'Direct',
      packageName: json['package_name'] ?? '',
    );
  }
}
