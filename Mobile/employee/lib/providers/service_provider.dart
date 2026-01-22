import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/service_request.dart';

class ServiceProvider with ChangeNotifier {
  final ApiService _apiService;
  List<ServiceRequest> _requests = [];
  bool _isLoading = false;

  ServiceProvider(this._apiService);

  List<ServiceRequest> get requests => _requests;
  bool get isLoading => _isLoading;

  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch assigned services for the logged-in employee
      // Uses the same endpoint as dashboard but filtered for employee view
      final response = await _apiService.client.get('/services/assigned'); 
      if (response.statusCode == 200 && response.data is List) {
        _requests = (response.data as List).map((e) => ServiceRequest.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching services: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int requestId, String newStatus) async {
    try {
      final response = await _apiService.client.put('/services/assigned/$requestId', data: {
        'status': newStatus
      });
      if (response.statusCode == 200) {
        // Optimistic update
        final index = _requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          _requests[index] = ServiceRequest(
            id: requestId, 
            serviceName: _requests[index].serviceName,
            roomNumber: _requests[index].roomNumber,
            requestTime: _requests[index].requestTime,
            status: newStatus,
            notes: _requests[index].notes
          );
          notifyListeners();
        }
        await fetchRequests(); // Full refresh
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating service: $e");
      return false;
    }
  }
}
