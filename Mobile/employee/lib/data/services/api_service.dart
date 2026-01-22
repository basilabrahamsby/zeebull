import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orchid_employee/core/constants/api_constants.dart';
import 'package:orchid_employee/core/constants/app_constants.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  VoidCallback? onUnauthorized;

  ApiService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          print("[AUTH] 401 Unauthorized detected globally");
          onUnauthorized?.call();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> login(String username, String password) async {
    // This assumes form-url-encoded body as per OAuth2 spec usually, or JSON depending on backend
    // Adjust content-type or body format as per existing backend
     return await _dio.post(
      ApiConstants.login,
      data: {
        'email': username,
        'password': password,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500, // Handle 400 nicely without throwing immediately
      ),
    );
  }

  Future<Response> clockIn(int employeeId, String location) async {
    return await _dio.post(
      '/attendance/clock-in',
      data: {
        'employee_id': employeeId,
        'location': location,
      },
    );
  }

  Future<Response> clockOut(int employeeId) async {
    return await _dio.post(
      '/attendance/clock-out',
      data: {
        'employee_id': employeeId,
      },
    );
  }

  Future<Response> getWorkLogs(int employeeId) async {
    return await _dio.get('/attendance/work-logs/$employeeId');
  }

  Future<Response> getMonthlyReport(int employeeId, int year, int month) async {
    return await _dio.get(
      '/attendance/monthly-report/$employeeId',
      queryParameters: {
        'year': year,
        'month': month,
      },
    );
  }

  // Leave Management
  Future<Response> getEmployeeLeaves(int employeeId) async {
    return await _dio.get('/employees/leave/$employeeId');
  }

  Future<Response> applyLeave(Map<String, dynamic> leaveData) async {
    return await _dio.post('/employees/leave', data: leaveData);
  }

  Future<Response> getPendingLeaves() async {
    return await _dio.get('/employees/pending-leaves');
  }

  // Employee Details
  Future<Response> getEmployeeDetails(int employeeId) async {
    return await _dio.get('/employees/$employeeId');
  }

  // Salary Payments
  Future<Response> getSalaryPayments(int employeeId) async {
    return await _dio.get('/employees/$employeeId/salary-payments');
  }

  // Food Orders (Kitchen / KOT)
  Future<Response> getFoodOrders() async {
    return await _dio.get('/food-orders');
  }

  Future<Response> createFoodOrder(Map<String, dynamic> data) async {
    return await _dio.post('/food-orders', data: data);
  }

  Future<Response> updateFoodOrderStatus(int orderId, String status) async {
    return await _dio.put(
      '/food-orders/$orderId',
      data: {'status': status},
    );
  }

  // Stock Requisitions
  Future<Response> createStockRequisition(Map<String, dynamic> data) async {
    return await _dio.post('/inventory/requisitions', data: data);
  }

  Future<Response> getStockRequisitions() async {
    return await _dio.get('/inventory/requisitions');
  }

  // Waste Logs
  Future<Response> createWasteLog(FormData data) async {
    return await _dio.post('/inventory/waste-logs', data: data);
  }

  Future<Response> getWasteLogs() async {
    return await _dio.get('/inventory/waste-logs');
  }

  // Food Items (Menu)
  Future<Response> getFoodItems() async {
    return await _dio.get(ApiConstants.foodItems);
  }

  Future<Response> getRooms() async {
    return await _dio.get(ApiConstants.rooms);
  }

  Future<Response> getRecipe(int foodItemId) async {
    return await _dio.get('/recipes', queryParameters: {'food_item_id': foodItemId});
  }

  Future<Response> getEmployees() async {
    return await _dio.get(ApiConstants.employees);
  }

  Future<Response> assignFoodOrder(int orderId, int employeeId) async {
    return await _dio.put(
      '/food-orders/$orderId',
      data: {'assigned_employee_id': employeeId},
    );
  }

  // Notifications
  Future<Response> getNotifications({int skip = 0, int limit = 50, bool unreadOnly = false}) async {
    return await _dio.get(
      '/notifications',
      queryParameters: {
        'skip': skip,
        'limit': limit,
        'unread_only': unreadOnly,
      },
    );
  }

  Future<Response> markNotificationRead(int notificationId) async {
    return await _dio.put('/notifications/$notificationId/read');
  }

  Future<Response> markAllNotificationsRead() async {
    return await _dio.put('/notifications/mark-all-read');
  }

  Future<Response> getUnreadNotificationCount() async {
    return await _dio.get('/notifications/unread-count');
  }

  Future<Response> clearAllNotifications() async {
    return await _dio.delete('/notifications/clear-all');
  }

  // Work Reports
  Future<Response> getUserActivityReport(int userId, {String? fromDate, String? toDate}) async {
    return await _dio.get(
      '/reports/user-history',
      queryParameters: {
        'user_id': userId,
        if (fromDate != null) 'from_date': fromDate,
        if (toDate != null) 'to_date': toDate,
      },
    );
  }

  Future<Response> getGlobalActivityReport({String? fromDate, String? toDate}) async {
    return await _dio.get(
      '/reports/global-activity',
      queryParameters: {
        if (fromDate != null) 'from_date': fromDate,
        if (toDate != null) 'to_date': toDate,
      },
    );
  }
}
