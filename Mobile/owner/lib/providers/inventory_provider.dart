import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inventory_item.dart';
import '../models/purchase_order.dart'; // Added import for PurchaseOrder

class InventoryProvider with ChangeNotifier {
  final ApiService _apiService;
  List<InventoryItem> _items = [];
  bool _isLoading = false;

  List<InventoryItem> _lowStockItems = [];
  List<PurchaseOrder> _pendingPOs = [];
  List<PurchaseOrder> _purchaseHistory = []; // Added
  List<dynamic> _categories = [];
  List<dynamic> _vendors = [];
  List<dynamic> _transactions = [];
  List<dynamic> _wasteLogs = []; // Added
  List<dynamic> _requisitions = []; // Added
  List<dynamic> _locations = []; // Added
  List<dynamic> _recipes = []; // Added
  List<dynamic> _stockIssues = []; // Added
  List<dynamic> _assetRegistry = []; // Added
  Map<int, List<dynamic>> _locationStocks = {}; // Cache for location stocks

  InventoryProvider(this._apiService);

  List<InventoryItem> get items => _items;
  List<InventoryItem> get lowStockItems => _lowStockItems;
  List<PurchaseOrder> get pendingPOs => _pendingPOs;
  List<PurchaseOrder> get purchaseHistory => _purchaseHistory; // Added
  List<dynamic> get categories => _categories;
  List<dynamic> get vendors => _vendors;
  List<dynamic> get transactions => _transactions;
  List<dynamic> get wasteLogs => _wasteLogs; // Added
  List<dynamic> get requisitions => _requisitions; // Added
  List<dynamic> get locations => _locations; // Added
  List<dynamic> get recipes => _recipes; // Added
  List<dynamic> get stockIssues => _stockIssues; // Added
  List<dynamic> get assetRegistry => _assetRegistry; // Added
  
  List<dynamic> getLocationStock(int locationId) => _locationStocks[locationId] ?? [];

  bool get isLoading => _isLoading;

  // ... existing methods ...

  Future<void> fetchLocationStock(int locationId) async {
    try {
      final response = await _apiService.client.get('/inventory/locations/$locationId/items');
      if (response.statusCode == 200) {
        List<dynamic> rawList = [];
        if (response.data is List) {
          rawList = response.data;
        } else if (response.data is Map && response.data['items'] != null) {
          rawList = response.data['items'];
        }

        // Normalize 'quantity' field from 'current_stock' if missing
        _locationStocks[locationId] = rawList.map((item) {
            if (item is Map) {
                // Ensure quantity is available for UI
                if (item['quantity'] == null && item['current_stock'] != null) {
                    item['quantity'] = item['current_stock'];
                }
                // Ensure item_name is available for UI
                if (item['item_name'] == null && item['name'] != null) {
                    item['item_name'] = item['name'];
                }
            }
            return item;
        }).toList();
        notifyListeners();
        print('DEBUG: Successfully fetched ${_locationStocks[locationId]?.length ?? 0} items for location $locationId');
      }
    } catch (e) {
      print('Error fetching location stock for $locationId: $e');
      _locationStocks[locationId] = []; // Set empty list on error
      notifyListeners();
    }
  }

  Future<void> fetchAssetRegistry() async {
    try {
      final response = await _apiService.client.get('/inventory/assets/registry');
      if (response.statusCode == 200) {
        _assetRegistry = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching asset registry: $e');
    }
  }

  Future<void> fetchStockIssues() async {
    try {
      final response = await _apiService.client.get('/inventory/issues');
      if (response.statusCode == 200) {
        _stockIssues = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching stock issues: $e');
    }
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await _apiService.client.get('/recipes');
      if (response.statusCode == 200) {
        _recipes = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  Future<void> fetchLocations() async {
    try {
      final response = await _apiService.client.get('/inventory/locations');
      if (response.statusCode == 200) {
        _locations = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  Future<void> fetchRequisitions() async {
    try {
      final response = await _apiService.client.get('/inventory/requisitions');
      if (response.statusCode == 200) {
        _requisitions = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching requisitions: $e');
    }
  }

  Future<bool> approveRequisition(int id) async {
    try {
      final response = await _apiService.client.patch('/inventory/requisitions/$id/status?status=approved');
      if (response.statusCode == 200) {
        // Refresh list
        await fetchRequisitions();
        return true;
      }
    } catch (e) {
      print('Error approving requisition: $e');
    }
    return false;
  }

  Future<void> fetchWasteLogs() async {
    try {
      final response = await _apiService.client.get('/inventory/waste-logs');
      if (response.statusCode == 200) {
        _wasteLogs = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching waste logs: $e');
    }
  }

  Future<void> fetchPurchaseHistory() async {
    try {
      // Fetch confirmed and received (completed) orders
      // We might need to make two calls or backend supports comma separation? 
      // Assuming fetching all and filtering or just fetching 'received' for now.
      // Let's try fetching all non-draft if possible, or just fetch 'received' to show history.
      // The backend check: get_purchases(status) takes a string. 
      // I'll fetch 'received' for history.
      final response = await _apiService.client.get('/inventory/purchases?status=received');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _purchaseHistory = data.map((json) => PurchaseOrder.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching PO history: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.client.get('/inventory/categories');
      if (response.statusCode == 200) {
        _categories = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchVendors() async {
    try {
      final response = await _apiService.client.get('/inventory/vendors');
      if (response.statusCode == 200) {
        _vendors = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching vendors: $e');
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await _apiService.client.get('/inventory/transactions?limit=50');
      if (response.statusCode == 200) {
        _transactions = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> fetchInventory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/inventory/items');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _items = data.map((json) => InventoryItem.fromJson(json)).toList();
        _lowStockItems = _items.where((item) => item.isLowStock).toList();
      }
    } catch (e) {
      print('Error fetching inventory: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPendingPOs() async {
    try {
      final response = await _apiService.client.get('/inventory/purchases?status=draft');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _pendingPOs = data.map((json) => PurchaseOrder.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching POs: $e');
    }
  }

  Future<List<dynamic>> fetchItemStocks(int itemId) async {
    try {
      final response = await _apiService.client.get('/inventory/items/$itemId/stocks');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Error fetching item stocks: $e');
    }
    return [];
  }

  Future<List<dynamic>> fetchItemTransactions(int itemId) async {
     try {
       final response = await _apiService.client.get('/inventory/items/$itemId/transactions');
       if (response.statusCode == 200) {
         return response.data;
       }
     } catch (e) {
       print('Error fetching item transactions: $e');
     }
     return [];
  }

  Future<List<dynamic>> fetchVendorPurchases(int vendorId) async {
    try {
      // Trying filter by vendor_id if supported, otherwise fetch all and filter client side
      // Assuming backend supports filter: /inventory/purchases?vendor_id=X
      // If not, we might get all. Let's try to be safe: fetch all and filter manually if query param ignored.
      final response = await _apiService.client.get('/inventory/purchases?vendor_id=$vendorId');
      if (response.statusCode == 200) {
        List<dynamic> all = response.data;
        // Client side filtering just in case backend ignores param
        return all.where((p) => p['vendor_id'] == vendorId).toList();
      }
    } catch (e) {
      print('Error fetching vendor purchases: $e');
    }
    return [];
  }

  Future<bool> approvePO(int id) async {
    try {
      final response = await _apiService.client.put('/inventory/purchases/$id', data: {'status': 'confirmed'});
      if (response.statusCode == 200) {
        _pendingPOs.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error approving PO: $e');
    }
    return false;
  }
}
