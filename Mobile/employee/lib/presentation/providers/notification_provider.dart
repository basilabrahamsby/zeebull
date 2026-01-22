import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;

  NotificationProvider(this._apiService);

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getNotifications();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
        await fetchUnreadCount();
      } else {
        _error = "Failed to fetch notifications";
      }
    } catch (e) {
      _error = e.toString();
      print("[NOTIF] Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.getUnreadNotificationCount();
      if (response.statusCode == 200) {
        _unreadCount = response.data['count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("[NOTIF] Error fetching unread count: $e");
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await _apiService.markNotificationRead(id);
      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          // We can't update final fields, so we just refetch or replace if we had a non-final copy
          // Simpler to just refetch for accuracy
          fetchNotifications();
        }
      }
    } catch (e) {
      print("[NOTIF] Error marking as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsRead();
      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (e) {
      print("[NOTIF] Error marking all as read: $e");
    }
  }

  Future<void> clearAll() async {
    try {
      final response = await _apiService.clearAllNotifications();
      if (response.statusCode == 200) {
        _notifications = [];
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      print("[NOTIF] Error clearing all: $e");
    }
  }
}
