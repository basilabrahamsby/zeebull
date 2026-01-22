import 'package:flutter/material.dart';
import 'package:orchid_employee/data/models/inventory_item_model.dart';
import 'package:orchid_employee/data/services/api_service.dart';
import 'package:orchid_employee/core/constants/api_constants.dart';

class InventoryProvider with ChangeNotifier {
  final ApiService _apiService;
  List<InventoryItem> _sellableItems = [];
  bool _isLoading = false;
  String? _error;

  InventoryProvider(this._apiService);

  List<InventoryItem> get sellableItems => _sellableItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<InventoryItem> _allItems = [];
  List<dynamic> _locations = [];
  List<dynamic> _rooms = [];
  List<InventoryItem> get allItems => _allItems;
  List<dynamic> get locations => _locations;
  List<dynamic> get rooms => _rooms;

  Future<void> fetchRooms() async {
    try {
      final response = await _apiService.getRooms();
      if (response.statusCode == 200) {
        _rooms = response.data;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching rooms: $e");
    }
  }

  Future<void> fetchSellableItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('${ApiConstants.inventoryItems}?limit=1000');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _allItems = data.map((json) => InventoryItem.fromJson(json)).toList();
        
        _sellableItems = _allItems
            .where((item) => item.isSellable)
            .toList();
      } else {
        _error = "Failed to load items: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error fetching inventory: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLocations() async {
    try {
      final response = await _apiService.dio.get('${ApiConstants.locations}?limit=100');
      if (response.statusCode == 200) {
        _locations = response.data;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  Map<int, double> _locationStocks = {};
  Map<int, double> get locationStocks => _locationStocks;

  Future<void> fetchLocationStock(int locationId) async {
    try {
      // Assuming there's an endpoint or filtering logic? 
      // The /stocks endpoint returns all. We can filter.
      final response = await _apiService.dio.get('/inventory/stocks');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _locationStocks = {
          for (var s in data.where((x) => x['location_id'] == locationId))
            s['item_id']: (s['quantity'] as num).toDouble()
        };
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching location stock: $e");
    }
  }

  Future<bool> createStockIssue({
    required int sourceLocationId,
    required List<Map<String, dynamic>> items, // {item_id, quantity}
    String? notes,
    int? destinationLocationId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.stockIssues,
        data: {
          'source_location_id': sourceLocationId,
          'destination_location_id': destinationLocationId, // Optional, implies consumption if null? Backend logic varies.
          'status': 'issued', 
          'issue_date': DateTime.now().toIso8601String(),
          'notes': notes,
          'details': items,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating stock issue: $e");
      return false;
    }
  }
}
