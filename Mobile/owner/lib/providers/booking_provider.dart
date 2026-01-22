import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/booking.dart';
import '../models/booking_details.dart';
import '../models/guest_history.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Booking> _bookings = [];
  bool _isLoading = false;

  BookingProvider(this._apiService);

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  BookingDetails? _selectedBookingDetails;
  BookingDetails? get selectedBookingDetails => _selectedBookingDetails;

  Future<void> fetchBookingDetails(int id, bool isPackage) async {
    _isLoading = true;
    _selectedBookingDetails = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/bookings/details/$id', queryParameters: {'is_package': isPackage});
      if (response.statusCode == 200 && response.data != null) {
        _selectedBookingDetails = BookingDetails.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching booking details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/bookings', queryParameters: {'limit': 50});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = (response.data is List) ? response.data : (response.data['bookings'] ?? []);
        _bookings = list.map((e) => Booking.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching bookings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Booking>> fetchRoomHistory(int roomId) async {
    try {
      final response = await _apiService.client.get('/bookings', queryParameters: {'room_id': roomId, 'limit': 20});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = (response.data is List) ? response.data : (response.data['bookings'] ?? []);
        return list.map((e) => Booking.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching room history: $e");
    }
    return [];
  }

  Future<GuestProfile?> fetchGuestProfile({String? mobile, String? email, String? name}) async {
    try {
      final Map<String, dynamic> params = {};
      if (mobile != null && mobile.isNotEmpty) params['guest_mobile'] = mobile;
      if (email != null && email.isNotEmpty) params['guest_email'] = email;
      if (name != null && name.isNotEmpty) params['guest_name'] = name;

      if (params.isEmpty) return null;

      final response = await _apiService.client.get('/reports/guest-profile', queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return GuestProfile.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching guest profile: $e");
    }
    return null;
  }
}
