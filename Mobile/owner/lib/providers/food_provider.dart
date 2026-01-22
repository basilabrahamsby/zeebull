import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/food_order.dart';
import '../models/food_item.dart';

class FoodProvider with ChangeNotifier {
  final ApiService _apiService;
  List<FoodOrder> _orders = [];
  List<FoodItem> _menuItems = [];
  List<dynamic> _employees = [];
  List<dynamic> _categories = [];
  List<dynamic> _inventoryItems = [];
  Map<int, dynamic> _recipes = {}; // food_item_id -> recipe
  
  bool _isLoading = false;
  bool _isAnalyticsLoading = false;

  // Analytics Metrics
  double _totalRevenue = 0;
  double _dailyRevenue = 0;
  double _totalCOGS = 0;
  double _totalProfit = 0;
  int _totalCompletedOrders = 0;
  int _totalItemsSold = 0;
  double _avgOrderValue = 0;
  double _avgProfitPerOrder = 0;
  Map<String, double> _revenueByOrderType = {'dine_in': 0, 'room_service': 0};
  Map<String, int> _orderStatusDist = {};
  List<Map<String, dynamic>> _topItems = [];
  List<Map<String, dynamic>> _inventoryUsage = [];
  List<Map<String, dynamic>> _employeePerformance = [];
  Map<DateTime, double> _salesTrend = {};

  FoodProvider(this._apiService);

  List<FoodOrder> get activeOrders => _orders.where((o) => !['delivered', 'completed', 'cancelled'].contains(o.status.toLowerCase())).toList();
  List<FoodOrder> get historyOrders => _orders.where((o) => ['delivered', 'completed'].contains(o.status.toLowerCase())).toList();
  List<FoodItem> get menuItems => _menuItems;
  List<FoodItem> get bestSellers => List.from(_menuItems)..sort((a, b) => b.totalSold.compareTo(a.totalSold));
  List<dynamic> get employees => _employees;
  List<dynamic> get categories => _categories;
  
  bool get isLoading => _isLoading;
  bool get isAnalyticsLoading => _isAnalyticsLoading;

  // Analytics Getters
  double get totalRevenue => _totalRevenue;
  double get dailyRevenue => _dailyRevenue;
  double get totalCOGS => _totalCOGS;
  double get totalProfit => _totalProfit;
  int get totalCompletedOrders => _totalCompletedOrders;
  int get totalItemsSold => _totalItemsSold;
  double get avgOrderValue => _avgOrderValue;
  double get avgProfitPerOrder => _avgProfitPerOrder;
  Map<String, double> get revenueByOrderType => _revenueByOrderType;
  Map<String, int> get orderStatusDist => _orderStatusDist;
  List<Map<String, dynamic>> get topItems => _topItems;
  List<Map<String, dynamic>> get inventoryUsage => _inventoryUsage;
  List<Map<String, dynamic>> get employeePerformance => _employeePerformance;
  Map<DateTime, double> get salesTrend => _salesTrend;


  Future<void> fetchFoodData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Orders - fetch ALL orders for analytics (limit 1000)
      final ordersRes = await _apiService.client.get('/food-orders', queryParameters: {'limit': 1000});
      if (ordersRes.statusCode == 200 && ordersRes.data != null) {
        final List<dynamic> list = (ordersRes.data is List) ? ordersRes.data : (ordersRes.data['orders'] ?? []);
        _orders = list.map((e) => FoodOrder.fromJson(e)).toList();
      }

      // Fetch Menu
      final menuRes = await _apiService.client.get('/food-items', queryParameters: {'limit': 100});
      if (menuRes.statusCode == 200 && menuRes.data != null) {
        final List<dynamic> list = (menuRes.data is List) ? menuRes.data : (menuRes.data['items'] ?? []);
        _menuItems = list.map((e) => FoodItem.fromJson(e)).toList();
      }

      // Fetch Employees (for assignment dropdown)
      await fetchEmployees();

      // Fetch Categories
      await fetchCategories();

    } catch (e) {
      print("Error fetching food data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEmployees() async {
    try {
      final res = await _apiService.client.get('/employees');
      if (res.statusCode == 200) {
        _employees = (res.data is List) ? res.data : [];
      }
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _apiService.client.get('/food-categories');
      if (res.statusCode == 200) {
        _categories = (res.data is List) ? res.data : (res.data['categories'] ?? []);
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchAnalyticsData() async {
    _isAnalyticsLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Inventory Items (for cost calculation)
      // Limit 1000 to cover all ingredients
      final invRes = await _apiService.client.get('/inventory/items', queryParameters: {'limit': 1000});
      if (invRes.statusCode == 200) {
        _inventoryItems = (invRes.data is List) ? invRes.data : (invRes.data['items'] ?? []);
      }

      // 2. Fetch Recipes for all menu items
      await _fetchRecipesForItems(_menuItems);

      // 3. Calculate Metrics
      _calculateAnalytics();

    } catch (e) {
      print("Error fetching analytics data: $e");
    } finally {
      _isAnalyticsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchRecipesForItems(List<FoodItem> items) async {
    for (var item in items) {
      if (_recipes.containsKey(item.id)) continue; 
      try {
        final res = await _apiService.client.get('/recipes', queryParameters: {'food_item_id': item.id});
        if (res.statusCode == 200 && res.data is List && (res.data as List).isNotEmpty) {
          _recipes[item.id] = res.data[0];
        }
      } catch (e) {
        // Ignore single failures
      }
    }
  }

  void _calculateAnalytics() {
    // 1. Basic Counts & Revenue (Completed Orders)
    _totalCompletedOrders = historyOrders.length;
    _totalRevenue = historyOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
    _totalItemsSold = historyOrders.fold(0, (sum, o) => sum + o.items.fold(0, (s, i) => s + i.quantity));
    
    _avgOrderValue = _totalCompletedOrders > 0 ? _totalRevenue / _totalCompletedOrders : 0;

    // 2. Daily Revenue
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    _dailyRevenue = _orders.where((o) {
      if (o.status.toLowerCase() == 'cancelled') return false;
      try {
        final date = DateTime.parse(o.createdAt);
        return date.isAfter(todayStart);
      } catch (e) {
        return false;
      }
    }).fold(0.0, (sum, o) => sum + o.totalAmount);

    // 3. COGS & Profit
    double tempCOGS = 0;
    Map<int, double> itemUsageMap = {}; // inventory_id -> quantity
    Map<String, double> revenueByType = {'dine_in': 0, 'room_service': 0};
    Map<int, Map<String, dynamic>> empPerf = {}; // empId -> {name, orders, revenue}
    Map<DateTime, double> trend = {};

    for (var order in historyOrders) {
      // Order Type Revenue
      final type = (order.orderType.isEmpty || order.orderType == 'null') ? 'room_service' : order.orderType; // Default fallback
      revenueByType[type] = (revenueByType[type] ?? 0) + order.totalAmount;

      // Sales Trend
      try {
        final date = DateTime.parse(order.createdAt);
        final day = DateTime(date.year, date.month, date.day);
        trend[day] = (trend[day] ?? 0) + order.totalAmount;
      } catch (e) {}

      // Employee Performance
      if (order.assignedEmployeeId != null) {
        final eid = order.assignedEmployeeId!;
        if (!empPerf.containsKey(eid)) {
          final empName = _employees.firstWhere((e) => e['id'] == eid, orElse: () => {'name': 'Staff #$eid'})['name'];
          empPerf[eid] = {'name': empName, 'orders': 0, 'revenue': 0.0};
        }
        empPerf[eid]!['orders'] += 1;
        empPerf[eid]!['revenue'] += order.totalAmount;
      }

      // Ingredients COGS
      for (var item in order.items) {
        final quantity = item.quantity;
        final recipe = _recipes[item.foodItemId];
        
        if (recipe != null && recipe['ingredients'] != null) {
          for (var ing in recipe['ingredients']) {
            final invId = ing['inventory_item_id'];
            final ingQty = (ing['quantity'] ?? 0) * quantity;
            
            // Usage
            itemUsageMap[invId] = (itemUsageMap[invId] ?? 0) + ingQty;

            // Cost
            final invItem = _inventoryItems.firstWhere((element) => element['id'] == invId, orElse: () => null);
            if (invItem != null) {
              tempCOGS += ingQty * (invItem['unit_price'] ?? 0);
            }
          }
        }
      }
    }

    _totalCOGS = tempCOGS;
    _totalProfit = _totalRevenue - _totalCOGS;
    _avgProfitPerOrder = _totalCompletedOrders > 0 ? _totalProfit / _totalCompletedOrders : 0;
    _revenueByOrderType = revenueByType;
    _salesTrend = trend;
    _employeePerformance = empPerf.values.toList()..sort((a, b) => b['revenue'].compareTo(a['revenue']));

    // Top Items
    Map<String, int> qtyMap = {};
    for (var o in historyOrders) {
      for (var i in o.items) {
        qtyMap[i.name] = (qtyMap[i.name] ?? 0) + i.quantity;
      }
    }
    _topItems = qtyMap.entries.map((e) => {'name': e.key, 'quantity': e.value}).toList();
    _topItems.sort((a, b) => b['quantity'].compareTo(a['quantity']));

    // Top Inventory Usage
    _inventoryUsage = itemUsageMap.entries.map((e) {
       final invItem = _inventoryItems.firstWhere((element) => element['id'] == e.key, orElse: () => {'name': 'Unknown'});
       return {'name': invItem['name'], 'quantity': e.value};
    }).toList();
    _inventoryUsage.sort((a, b) => (b['quantity'] as num).compareTo(a['quantity'] as num));

    // Order Status Distribution (All Orders)
    Map<String, int> statusDist = {};
    for (var o in _orders) {
      statusDist[o.status] = (statusDist[o.status] ?? 0) + 1;
    }
    _orderStatusDist = statusDist;

    notifyListeners();
  }

  Future<void> updateOrderStatus(int id, String status) async {
      try {
        await _apiService.client.put('/food-orders/$id', data: {'status': status});
        await fetchFoodData(); // Refresh
      } catch (e) {
        print("Error updating food order: $e");
        rethrow;
      }
  }

  Future<void> assignEmployee(int orderId, int employeeId) async {
    try {
      await _apiService.client.put('/food-orders/$orderId', data: {'assigned_employee_id': employeeId});
      await fetchFoodData();
    } catch (e) {
      print("Error assigning employee: $e");
      rethrow;
    }
  }

  Future<void> updateItemAvailability(int id, bool isAvailable) async {
    try {
      await _apiService.client.patch('/food-items/$id/toggle-availability', queryParameters: {'available': isAvailable});
      await fetchFoodData(); 
    } catch (e) {
      print("Error toggling item availability: $e");
    }
  }
  
  Future<void> addFoodItem(Map<String, dynamic> data) async {
    try {
       final formData = FormData.fromMap(data);
       await _apiService.client.post('/food-items', data: formData);
       await fetchFoodData();
    } catch (e) {
      print("Error adding food item: $e");
      rethrow;
    }
  }

  Future<void> updateFoodItem(int id, Map<String, dynamic> data) async {
    try {
       final formData = FormData.fromMap(data);
       await _apiService.client.put('/food-items/$id', data: formData);
       await fetchFoodData();
    } catch (e) {
      print("Error updating food item: $e");
      rethrow;
    }
  }
}
