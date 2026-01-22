import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Expense> _expenses = [];
  bool _isLoading = false;

  ExpenseProvider(this._apiService);

  List<Expense> get expenses => _expenses;
  List<Expense> get pendingExpenses => _expenses.where((e) => e.status == 'Pending').toList();
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/expenses', queryParameters: {'limit': 50});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = (response.data is List) ? response.data : (response.data['expenses'] ?? []);
        _expenses = list.map((e) => Expense.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateExpenseStatus(int id, String status) async {
    try {
      final response = await _apiService.client.put('/expenses/$id/status/$status');
      if (response.statusCode == 200) {
        // Optimistic update
        final index = _expenses.indexWhere((e) => e.id == id);
        if (index != -1) {
           // We need to fetch again or recreate the object (since fields are final)
           // For now, simpler to just re-fetch to ensure consistency
           await fetchExpenses(); 
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating expense: $e");
      return false;
    }
  }
  Future<bool> addExpense(Map<String, dynamic> data) async {
    try {
      // Backend expects Form Data
      // The instruction implies changing the data format to expense.toJson()
      // Assuming 'data' map can be converted to an Expense object or directly used if it matches Expense structure
      // For now, I'll use the provided 'data' map directly as the body, assuming it's not FormData anymore.
      // If 'expense.toJson()' was literal, the method signature or usage would need to change.
      // Sticking to the instruction's endpoint and data format change.
      final response = await _apiService.client.post('/expenses', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchExpenses();
        return true;
      }
      return false;
    } catch (e) {
      print("Error adding expense: $e");
      return false;
    }
  }

  Map<String, dynamic>? _budgetAnalysis;
  Map<String, dynamic>? get budgetAnalysis => _budgetAnalysis;

  Future<void> fetchBudgetAnalysis() async {
    try {
      final response = await _apiService.client.get('/expenses/budget-analysis');
      if (response.statusCode == 200 && response.data != null) {
        _budgetAnalysis = response.data as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching budget analysis: $e");
    }
  }
}
