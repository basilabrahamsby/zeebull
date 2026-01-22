import 'package:flutter/material.dart';
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
      }
    } catch (e) {
      print("Error fetching rooms: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRoomStatus(int roomId, String newStatus) async {
    try {
      // Assuming endpoint to update status
      final response = await _apiService.client.put('/rooms/$roomId', data: {
        'status': newStatus
      });
      if (response.statusCode == 200) {
        await fetchRooms(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating room: $e");
      return false;
    }
  }
}
