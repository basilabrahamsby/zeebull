import 'package:flutter/material.dart';
import 'package:orchid_employee/data/models/room_model.dart';
import 'package:orchid_employee/data/models/room_type_model.dart';
import 'package:orchid_employee/data/models/restaurant_table_model.dart';
import 'package:orchid_employee/data/services/api_service.dart';
import 'package:orchid_employee/core/constants/api_constants.dart';

class RoomProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Room> _rooms = [];
  List<RoomType> _roomTypes = [];
  List<RestaurantTable> _restaurantTables = [];
  Map<String, dynamic> _roomStats = {};
  bool _isLoading = false;
  String? _error;

  RoomProvider(this._apiService);

  List<Room> get rooms => _rooms;
  List<RoomType> get roomTypes => _roomTypes;
  List<RestaurantTable> get restaurantTables => _restaurantTables;
  Map<String, dynamic> get roomStats => _roomStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRooms() async {
    final softLoading = _rooms.isNotEmpty;
    if (!softLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await _apiService.dio.get(ApiConstants.rooms);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _rooms = data.map((json) => Room.fromJson(json)).toList();
        fetchRoomStats(); // Concurrent fetch
      } else {
        _error = "Failed to load rooms: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error fetching rooms: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoomStats() async {
    try {
      final response = await _apiService.getRoomStats();
      if (response.statusCode == 200) {
        _roomStats = response.data;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching room stats: $e");
    }
  }

  Future<void> fetchRoomTypes() async {
    try {
      final response = await _apiService.getRoomTypes();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _roomTypes = data.map((json) => RoomType.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching room types: $e");
    }
  }

  Future<bool> updateRoomStatus(int roomId, String status) async {
    try {
      // Backend uses 'housekeeping_status' for Cleaning/Clean/Dirty
      final response = await _apiService.dio.put(
        '${ApiConstants.rooms}/$roomId',
        data: {
          'housekeeping_status': status,
        },
      );
      if (response.statusCode == 200) {
        // Update local state
        final index = _rooms.indexWhere((r) => r.id == roomId);
        if (index != -1) {
          _rooms[index].status = status; 
          notifyListeners();
        }
        fetchRooms(); // Silent refresh
        return true;
      }
    } catch (e) {
      print("Error updating room status: $e");
    }
    return false;
  }

  Future<bool> createRoom(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createRoom(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchRooms();
        return true;
      }
    } catch (e) {
      print("Error creating room: $e");
    }
    return false;
  }

  Future<void> fetchRestaurantTables() async {
    final softLoading = _restaurantTables.isNotEmpty;
    if (!softLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await _apiService.getRestaurantTables();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _restaurantTables = data.map((json) => RestaurantTable.fromJson(json)).toList();
      } else {
        _error = "Failed to load restaurant tables: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error fetching restaurant tables: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRestaurantTable(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createRestaurantTable(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchRestaurantTables();
        return true;
      }
    } catch (e) {
      print("Error creating restaurant table: $e");
    }
    return false;
  }
}
