import 'package:flutter/foundation.dart';

class ApiConstants {
  // Local Development URLs
  static String get baseUrl => kIsWeb ? 'http://localhost:8011/api' : 'http://10.0.2.2:8011/api';
  static String get imageBaseUrl => kIsWeb ? 'http://localhost:8011' : 'http://10.0.2.2:8011';

  // Production URLs
  // static const String baseUrl = 'https://zeebull.com/api';
  // static const String imageBaseUrl = 'https://zeebull.com';
  static const String login = '/auth/login';
  static const String profile = '/auth/me';
  
  // Housekeeping & Rooms
  static const String rooms = '/rooms';
  static const String roomStats = '/rooms/stats';
  static const String restaurantTables = '/restaurant-tables';
  
  // Service Requests
  static const String serviceRequests = '/service-requests';
  
  // Attendance
  static const String attendance = '/attendance';
  static const String clockIn = '/attendance/clock-in';
  static const String clockOut = '/attendance/clock-out';
  
  // Kitchen (KOT)
  static const String kot = '/food-orders';
  
  static const String notifications = '/notifications';
  
  // Inventory
  static const String locations = '/inventory/locations';
  static const String inventoryItems = '/inventory/items';
  static const String stockIssues = '/inventory/issues';
  static const String stocks = '/inventory/stocks';
  static const String foodItems = '/food-items';
  static const String foodCategories = '/food-categories';
  static const String employees = '/employees';
}
