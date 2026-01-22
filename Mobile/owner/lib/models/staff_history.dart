class ActivityItem {
  final String activityDate;
  final String type;
  final String description;
  final double? amount;

  ActivityItem({
    required this.activityDate,
    required this.type,
    required this.description,
    this.amount,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      activityDate: json['activity_date'] ?? '',
      type: json['type'] ?? 'Unknown',
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}

class UserHistory {
  final String userName;
  final List<ActivityItem> activities;

  UserHistory({
    required this.userName,
    required this.activities,
  });

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    return UserHistory(
      userName: json['user_name'] ?? 'Unknown',
      activities: (json['activities'] as List?)?.map((e) => ActivityItem.fromJson(e)).toList() ?? [],
    );
  }
}
