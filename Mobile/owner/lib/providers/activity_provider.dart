import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/activity_log.dart';

class ActivityProvider with ChangeNotifier {
  final ApiService _apiService;
  List<ActivityLog> _logs = [];
  bool _isLoading = false;

  ActivityProvider(this._apiService);

  List<ActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;

  Future<void> fetchLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/activity-logs', queryParameters: {'limit': 50});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['logs'] ?? [];
        _logs = list.map((e) => ActivityLog.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching activity logs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
