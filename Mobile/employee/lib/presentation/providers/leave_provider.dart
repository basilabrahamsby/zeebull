import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';

class LeaveProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  LeaveProvider(this._apiService);

  List<dynamic> _leaves = [];
  bool _isLoading = false;
  String? _error;
  int _availableLeaves = 0; // Will be fetched from backend
  int _usedLeaves = 0;
  int _totalAllocated = 0;

  List<dynamic> get leaves => _leaves;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get availableLeaves => _availableLeaves;
  int get usedLeaves => _usedLeaves;
  int get totalAllocated => _totalAllocated;

  Future<void> fetchLeaves(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch leave history
      final response = await _apiService.getEmployeeLeaves(employeeId);
      if (response.statusCode == 200 && response.data is List) {
        _leaves = response.data as List;
      } else {
        _error = "Failed to fetch leaves";
        _leaves = [];
      }

      // Fetch monthly report for current month to get calculated balance
      final now = DateTime.now();
      final reportResponse = await _apiService.getMonthlyReport(
        employeeId,
        now.year,
        now.month,
      );

      if (reportResponse.statusCode == 200 && reportResponse.data != null) {
        final report = reportResponse.data;
        // Use calculated balance from backend
        _availableLeaves = report['paid_leave_balance'] ?? 0;
        _usedLeaves = report['paid_leaves_taken'] ?? 0;
        _totalAllocated = report['total_paid_leaves_year'] ?? 0;
      } else {
        // Fallback: calculate from leave history
        _usedLeaves = _leaves.where((leave) => leave['status'] == 'approved').length;
        _availableLeaves = 12 - _usedLeaves; // Default fallback
      }
    } catch (e) {
      _error = e.toString();
      _leaves = [];
      print("Fetch leaves error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyLeave({
    required int employeeId,
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.applyLeave({
        'employee_id': employeeId,
        'type': type,
        'from_date': fromDate.toIso8601String().split('T')[0],
        'to_date': toDate.toIso8601String().split('T')[0],
        'reason': reason,
        'status': 'pending',
      });
      
      if (response.statusCode == 200) {
        // Refresh leaves list
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print("Apply leave error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
