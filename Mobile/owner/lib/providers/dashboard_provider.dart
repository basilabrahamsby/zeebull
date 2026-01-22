import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/kpi_summary.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;
  KpiSummary? _kpiSummary;
  bool _isLoading = false;
  String _period = 'month';
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, int> _roomStats = {};
  Map<String, int> get roomStats => _roomStats;

  DashboardProvider(this._apiService);

  KpiSummary? get kpiSummary => _kpiSummary;
  bool get isLoading => _isLoading;
  
  void updateDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      _startDate = start;
      _endDate = end;
      _period = 'custom';
    } else {
      _period = 'month';
    }
    fetchKPIData();
  }



  Future<void> fetchKPIData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final params = <String, dynamic>{'period': _period};
      if (_period == 'custom' && _startDate != null) {
        params['start_date'] = _startDate!.toIso8601String().split('T')[0];
        params['end_date'] = _endDate!.toIso8601String().split('T')[0];
      }

      final response = await _apiService.client.get(
        '/dashboard/summary', 
        queryParameters: params
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

  Future<List<dynamic>> fetchTransactionsList() async {
    try {
      final response = await _apiService.client.get('/dashboard/transactions');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      // Don't rethrow to keep UI safe, return empty or handle
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchPnL() async {
    try {
      final params = <String, dynamic>{'period': _period};
      if (_period == 'custom' && _startDate != null) {
        params['start_date'] = _startDate!.toIso8601String().split('T')[0];
        params['end_date'] = _endDate!.toIso8601String().split('T')[0];
      }
      final response = await _apiService.client.get('/dashboard/pnl', queryParameters: params);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching PnL: $e");
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchDepartmentDetails(String deptName) async {
    try {
      final params = <String, dynamic>{'period': _period};
      if (_period == 'custom' && _startDate != null) {
        params['start_date'] = _startDate!.toIso8601String().split('T')[0];
        params['end_date'] = _endDate!.toIso8601String().split('T')[0];
      }
      final response = await _apiService.client.get('/dashboard/department/$deptName', queryParameters: params);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching dept details: $e");
    }
    return {};
  }

  Future<List<dynamic>> fetchVendorStats() async {
    try {
      final response = await _apiService.client.get('/dashboard/vendors/stats');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
    } catch (e) {
      print("Error fetching vendor stats: $e");
    }
    return [];
  }

  Future<void> fetchRoomStats() async {
      try {
          final res = await _apiService.client.get('/rooms/stats');
          if (res.statusCode == 200) {
              final data = res.data as Map<String, dynamic>;
              _roomStats = {
                'total': (data['total'] ?? 0).toInt(),
                'occupied': (data['occupied'] ?? 0).toInt(),
                'available': (data['available'] ?? 0).toInt(),
                'maintenance': (data['maintenance'] ?? 0).toInt(),
                'dirty': (data['dirty'] ?? 0).toInt(),
              };
              notifyListeners();
          }
      } catch (e) {
          print("Error fetching room stats $e");
      }
  }

  Map<String, dynamic> _dailyStats = {};
  Map<String, dynamic> get dailyStats => _dailyStats;

  Future<void> fetchDailyKPIs() async {
    try {
      final res = await _apiService.client.get('/dashboard/kpis');
      if (res.statusCode == 200 && res.data is List && res.data.isNotEmpty) {
        _dailyStats = res.data[0];
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching daily KPIs: $e");
    }
  }

  Future<List<dynamic>> fetchVendorTransactions(int id) async {
       try {
           final res = await _apiService.client.get('/dashboard/vendors/$id/transactions');
           if (res.statusCode == 200) {
               return res.data as List<dynamic>;
           }
       } catch (e) {
           print("Error fetching vendor tx: $e");
       }
       return [];
  }

  List<dynamic> _financialTrends = [];
  Map<String, dynamic> _chartData = {}; // Stores revenue_breakdown and weekly_performance

  List<dynamic> get financialTrends => _financialTrends;
  Map<String, dynamic> get chartData => _chartData;

  Future<void> fetchFinancialTrends() async {
     // Kept for backward compatibility if needed, but we use fetchChartData now
    try {
      final res = await _apiService.client.get('/dashboard/financial-trends');
      if (res.statusCode == 200) {
        _financialTrends = res.data as List<dynamic>;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching trends: $e");
    }
  }

  Future<void> fetchChartData() async {
    try {
      final res = await _apiService.client.get('/dashboard/charts');
      if (res.statusCode == 200) {
        _chartData = res.data as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching chart data: $e");
    }
  }

  List<dynamic> _recentActivity = [];
  List<dynamic> get recentActivity => _recentActivity;

  Future<void> fetchReportsData() async {
    try {
      final res = await _apiService.client.get('/dashboard/reports');
      if (res.statusCode == 200 && res.data is List && res.data.isNotEmpty) {
        _recentActivity = res.data[0]['recent_bookings'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching reports: $e");
    }
  }

  // --- Accounting Module Methods ---

  Future<List<dynamic>> fetchAccountGroups() async {
    try {
      final res = await _apiService.client.get('/accounts/groups');
      if (res.statusCode == 200) {
        return res.data as List<dynamic>;
      }
    } catch (e) {
      print("Error fetching account groups: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchAccountLedgers() async {
    try {
      final res = await _apiService.client.get('/accounts/ledgers');
      if (res.statusCode == 200) {
        return res.data as List<dynamic>;
      }
    } catch (e) {
      print("Error fetching account ledgers: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchJournalEntries() async {
    try {
      final res = await _apiService.client.get('/accounts/journal-entries');
      if (res.statusCode == 200) {
        return res.data as List<dynamic>;
      }
    } catch (e) {
      print("Error fetching journal entries: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchTrialBalance() async {
    try {
      final res = await _apiService.client.get('/accounts/trial-balance');
      if (res.statusCode == 200) {
        return res.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching trial balance: $e");
    }
    return {};
  }

  Future<bool> createAccountGroup(Map<String, dynamic> data) async {
    try {
      await _apiService.client.post('/accounts/groups', data: data);
      return true;
    } catch (e) {
      print("Error creating account group: $e");
      return false;
    }
  }

  Future<bool> createAccountLedger(Map<String, dynamic> data) async {
    try {
      await _apiService.client.post('/accounts/ledgers', data: data);
      return true;
    } catch (e) {
      print("Error creating ledger: $e");
      return false;
    }
  }

  Future<bool> createJournalEntry(Map<String, dynamic> data) async {
    try {
      await _apiService.client.post('/accounts/journal-entries', data: data);
      return true;
    } catch (e) {
      print("Error creating journal entry: $e");
      return false;
    }
  }
}
