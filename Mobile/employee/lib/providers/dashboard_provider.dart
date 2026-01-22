import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/kpi_summary.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;
  KpiSummary? _kpiSummary;
  bool _isLoading = false;

  DashboardProvider(this._apiService);

  KpiSummary? get kpiSummary => _kpiSummary;
  bool get isLoading => _isLoading;

  Future<void> fetchKPIData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use current month range
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
      final end = now.toIso8601String().split('T')[0];

      final response = await _apiService.client.get(
        '/accounts/auto-report', 
        queryParameters: {'start_date': start, 'end_date': end}
      );

      if (response.statusCode == 200) {
        _kpiSummary = KpiSummary.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching KPI: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
