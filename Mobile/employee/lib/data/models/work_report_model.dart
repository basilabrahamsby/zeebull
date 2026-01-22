
class ActivityItem {
  final DateTime activityDate;
  final String type;
  final String description;
  final double? amount;
  final String? userName; // Added for global view

  ActivityItem({
    required this.activityDate,
    required this.type,
    required this.description,
    this.amount,
    this.userName,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      activityDate: DateTime.parse(json['activity_date']),
      type: json['type'],
      description: json['description'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      userName: json['user_name'],
    );
  }
}

class UserHistory {
  final String? userName; // Null validation for global report
  final List<ActivityItem> activities;

  UserHistory({
    this.userName,
    required this.activities,
  });

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    // If it's a list (global report), wrap it
    if (json is List) {
      return UserHistory(
        userName: "Global Report",
        activities: (json as List).map((e) => ActivityItem.fromJson(e)).toList(),
      );
    }
    // If it's the old single user format
    return UserHistory(
      userName: json['user_name'],
      activities: (json['activities'] as List<dynamic>)
          .map((e) => ActivityItem.fromJson(e))
          .toList(),
    );
  }
  
  // Static helper since global report returns a List, not a Map with 'activities' key
  static UserHistory fromList(List<dynamic> list) {
    return UserHistory(
      userName: "All Employees",
      activities: list.map((e) => ActivityItem.fromJson(e)).toList(),
    );
  }
}
