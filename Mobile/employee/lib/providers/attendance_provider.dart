import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AttendanceProvider with ChangeNotifier {
  final ApiService _apiService;
  bool _isClockedIn = false;
  DateTime? _clockInTime;
  bool _isLoading = false;

  AttendanceProvider(this._apiService);

  bool get isClockedIn => _isClockedIn;
  DateTime? get clockInTime => _clockInTime;
  bool get isLoading => _isLoading;

  Future<void> fetchStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mocking fetch status as endpoint might not exist yet
      // await _apiService.client.get('/employee/attendance/status');
      // For demo, we keep local state or default to false
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print("Error fetching attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAttendance() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final action = _isClockedIn ? 'clock-out' : 'clock-in';
      // await _apiService.client.post('/employee/attendance/$action');
      
      // Optimistic update for demo
      await Future.delayed(const Duration(seconds: 1));
      _isClockedIn = !_isClockedIn;
      _clockInTime = _isClockedIn ? DateTime.now() : null;
      
      return true;
    } catch (e) {
      print("Error toggling attendance: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
