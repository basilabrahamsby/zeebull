import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  AttendanceProvider(this._apiService);

  bool _isClockedIn = false;
  bool _isLoading = false;
  DateTime? _clockInTime;
  String? _error;

  bool get isClockedIn => _isClockedIn;
  bool get isLoading => _isLoading;
  DateTime? get clockInTime => _clockInTime;
  String? get error => _error;

  List<dynamic> _workLogs = [];
  List<dynamic> get workLogs => _workLogs;
  
  bool get isOnDuty => _isClockedIn;

  Future<void> checkTodayStatus(int? employeeId) async {
    if (employeeId == null) {
      _isClockedIn = false;
      _clockInTime = null;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getWorkLogs(employeeId);
      if (response.statusCode == 200 && response.data is List) {
        final logs = response.data as List;
        bool foundActive = false;
        
        if (logs.isNotEmpty) {
           final today = DateTime.now();
           final todayLogs = logs.where(
             (log) => DateTime.parse(log['date']).day == today.day && DateTime.parse(log['date']).month == today.month && DateTime.parse(log['date']).year == today.year
           ).toList();
           
           // Sort by creation or time? Assuming latest is what we care about
           // Check if ANY log is open (no checkout time)
           final activeLog = todayLogs.firstWhere((log) => log['check_out_time'] == null, orElse: () => null);

           if (activeLog != null) {
              _isClockedIn = true;
              _clockInTime = DateTime.parse('${activeLog['date']} ${activeLog['check_in_time']}');
              foundActive = true;
           } else {
              // Maybe they clocked out?
              // If they have logs but all closed, they are clocked out.
              if (todayLogs.isNotEmpty) {
                 // Optionally store last clock in time?
              }
           }
        }
        
        if (!foundActive) {
           _isClockedIn = false;
           // Keep clockInTime null or set to last known? For now null.
           _clockInTime = null;
        }
      }
    } catch (e) {
      _error = e.toString();
      // Don't reset _isClockedIn on error? Or assume safely false?
      // Better to keep previous state or explicit error handling.
      print("Check status error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clockIn(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.clockIn(employeeId, "Mobile App");
      if (response.statusCode == 200) {
        _isClockedIn = true;
        _clockInTime = DateTime.now();
        return true;
      } else {
        _error = "Failed to clock in";
        _isClockedIn = false;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clockOut(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.clockOut(employeeId);
       if (response.statusCode == 200) {
        _isClockedIn = false;
        _clockInTime = null;
        return true;
      } else {
         _error = "Failed to clock out";
         return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWorkLogs(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getWorkLogs(employeeId);
      if (response.statusCode == 200 && response.data is List) {
        _workLogs = response.data as List;
      } else {
        _error = "Failed to fetch work logs";
        _workLogs = [];
      }
    } catch (e) {
      _error = e.toString();
      _workLogs = [];
      print("Fetch work logs error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
