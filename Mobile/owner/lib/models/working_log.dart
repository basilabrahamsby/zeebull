class WorkingLog {
  final int id;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final String? location;
  final double? durationHours;

  WorkingLog({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.location,
    this.durationHours,
  });

  factory WorkingLog.fromJson(Map<String, dynamic> json) {
    return WorkingLog(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      location: json['location'],
      durationHours: (json['duration_hours'] as num?)?.toDouble(),
    );
  }
}
