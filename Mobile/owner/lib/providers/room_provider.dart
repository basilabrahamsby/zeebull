import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/room.dart';

class RoomProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Room> _rooms = [];
  bool _isLoading = false;

  RoomProvider(this._apiService);

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/rooms');
      if (response.statusCode == 200 && response.data is List) {
        _rooms = (response.data as List).map((e) => Room.fromJson(e)).toList();
        
        // DEBUG: Print room statuses
        print('DEBUG: Fetched ${_rooms.length} rooms');
        for (var room in _rooms) {
          print('DEBUG: Room ${room.roomNumber} - Status: "${room.status}" (lowercase: "${room.status.toLowerCase()}")');
        }
      }
    } catch (e) {
      print("Error fetching rooms: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRoom({required int roomId, String? status, String? housekeepingStatus}) async {
    try {
      final formData = FormData.fromMap({
        if (status != null) 'status': status,
        if (housekeepingStatus != null) 'housekeeping_status': housekeepingStatus,
      });

      final response = await _apiService.client.put('/rooms/$roomId', data: formData);
      
      if (response.statusCode == 200) {
        await fetchRooms();
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating room: $e");
      return false;
    }
  }
}
