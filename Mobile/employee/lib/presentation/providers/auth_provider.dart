import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:orchid_employee/data/services/api_service.dart';
import 'package:orchid_employee/core/constants/app_constants.dart';
import 'package:orchid_employee/core/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // We might need this, or just decode manually
import 'dart:convert';

enum AuthStatus { unknown, authenticated, unauthenticated }
enum UserRole { manager, housekeeping, kitchen, waiter, maintenance, frontOffice, unknown }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  UserRole _role = UserRole.unknown;
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  String? _userName;
  String? _userImage;
  int? _employeeId;
  int? _userId;
  int? _branchId;
  bool _isSuperadmin = false;
  String? _branchName;
  String? _branchImage;
  List<String> _dailyTasks = [];
  String? _error;
  bool _needsUpdate = false;
  String? _playStoreUrl;

  AuthStatus get status => _status;
  UserRole get role => _role;
  String? get userName => _userName;
  String? get userImage => _userImage;
  int? get employeeId => _employeeId;
  int? get userId => _userId;
  int? get branchId => _branchId;
  bool get isSuperadmin => _isSuperadmin;
  String? get branchName => _branchName;
  String? get branchImage => _branchImage;
  List<String> get dailyTasks => _dailyTasks;
  String? get error => _error;
  bool get needsUpdate => _needsUpdate;
  String? get playStoreUrl => _playStoreUrl;


  AuthProvider(this._apiService) {
    _apiService.onUnauthorized = logout;
    _init();
  }

  Future<void> _init() async {
    try {
      // Hard cap: if everything takes > 15s, bail out and show login
      await Future.any([
        _initInternal(),
        Future.delayed(const Duration(seconds: 15)),
      ]);
    } catch (e) {
      print("[AUTH-INIT] Error during init: $e");
    } finally {
      // Always leave the loading screen — never hang forever
      if (_status == AuthStatus.unknown) {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    }
  }

  Future<void> _initInternal() async {
    await checkAppVersion();
    try {
      _token = await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      print("Warning: Secure storage read failed: $e");
      try {
        await _storage.deleteAll();
      } catch (_) {}
      _token = null;
    }
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      _status = AuthStatus.authenticated;
      _decodeRole(_token!);
      await _fetchEmployeeProfile();
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> checkAppVersion() async {
    try {
      // Short 8s timeout — don't block the app startup on version check
      final response = await _apiService.dio.get(
        '/public/app-version',
        options: Options(receiveTimeout: const Duration(seconds: 8), sendTimeout: const Duration(seconds: 8)),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final minVersionStr = data['min_version']?.toString() ?? '1.2.2';
        _playStoreUrl = data['play_store_url']?.toString();
        // Respect the force_update flag from the backend
        final forceUpdate = data['force_update'] == true;

        const currentVersionStr = '1.2.3'; // Matches pubspec.yaml version

        if (forceUpdate && _isVersionOlder(currentVersionStr, minVersionStr)) {
          _needsUpdate = true;
          print("⚠️ [APP-UPDATE] Force update required to version: $minVersionStr (Current: $currentVersionStr)");
        } else {
          _needsUpdate = false;
          print("✅ [APP-UPDATE] No force update. force_update=$forceUpdate, current=$currentVersionStr, min=$minVersionStr");
        }
      }
    } catch (e) {
      // Never block startup due to version check failure
      print("Warning: App version check failed (continuing): $e");
      _needsUpdate = false;
    }
  }

  bool _isVersionOlder(String current, String required) {
    try {
      List<int> currentParts = current.split('.').map((e) => int.parse(e)).toList();
      List<int> requiredParts = required.split('.').map((e) => int.parse(e)).toList();
      
      for (int i = 0; i < requiredParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (currentParts[i] < requiredParts[i]) return true;
        if (currentParts[i] > requiredParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _error = null;
    try {
      final response = await _apiService.login(username, password);
      
      print("LOGIN RESPONSE: ${response.statusCode} - ${response.data}");

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        if (accessToken != null) {
          try {
            await _storage.write(key: AppConstants.tokenKey, value: accessToken);
          } catch (e) {
            print("Warning: Secure storage write failed: $e");
            try {
              await _storage.deleteAll();
              await _storage.write(key: AppConstants.tokenKey, value: accessToken);
            } catch (_) {}
          }
          _token = accessToken;
          _status = AuthStatus.authenticated;
          _decodeRole(accessToken);
          // ✅ Navigate to dashboard immediately — don't wait for profile
          notifyListeners();
          // Fetch profile silently in background after navigation
          _fetchEmployeeProfile().catchError((e) {
            print("Background profile fetch error (non-fatal): $e");
          });
          return true;
        }
      }
      _error = "Invalid response from server";
      notifyListeners();
      return false;
    } catch (e) {
      print("Login error: $e");
      _error = e.toString();
      if (_error!.contains("401")) {
        _error = "Invalid Employee ID or Password";
      } else if (_error!.contains("404")) {
        _error = "Authentication service unavailable (404)";
      }
      notifyListeners();
      rethrow;
    }
  }


  Future<void> logout() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
    } catch (_) {}
    _status = AuthStatus.unauthenticated;
    _role = UserRole.unknown;
    _userName = null;
    _userImage = null;
    _employeeId = null;
    _userId = null;
    _branchId = null;
    _isSuperadmin = false;
    _branchName = null;
    _branchImage = null;
    _dailyTasks = [];
    notifyListeners();
  }

  void _decodeRole(String token) {
     Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
     // Adjust key based on your JWT payload structure for role
     // e.g., 'role', 'roles', 'user_role'
     String? roleStr = decodedToken['role'] ?? decodedToken['sub']?.toString().split(':')[0]; // Example fallback

     // Map string to enum
     _role = _parseRole(roleStr);
     
     // Extract name
     _userName = decodedToken['name'] ?? decodedToken['email'] ?? decodedToken['sub'];
     
     // Extract employee_id
     _employeeId = decodedToken['employee_id'];
     
     // Extract user_id
     _userId = decodedToken['user_id'] ?? (decodedToken['sub'] is int ? decodedToken['sub'] : int.tryParse(decodedToken['sub'].toString()));
      
     // Extract branch scoping info
     _branchId = decodedToken['branch_id'];
     _isSuperadmin = decodedToken['is_superadmin'] ?? false;
  }

  UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.housekeeping;
    roleStr = roleStr.toLowerCase().replaceAll(' ', '');
    if (roleStr.contains('manager') || roleStr.contains('admin')) {
      return UserRole.manager;
    }

    if (roleStr.contains('housekeeping')) return UserRole.housekeeping;
    if (roleStr.contains('kitchen') || roleStr.contains('chef') || roleStr.contains('cook')) return UserRole.kitchen;
    if (roleStr.contains('waiter') || roleStr.contains('server') || roleStr.contains('service') || roleStr.contains('room')) return UserRole.waiter;
    if (roleStr.contains('maintenance')) return UserRole.maintenance;
    if (roleStr.contains('frontoffice') || roleStr.contains('front_office') || roleStr.contains('reception')) {
      return UserRole.frontOffice;
    }
    return UserRole.housekeeping; // Redirect unknown to housekeeping
  }

  Future<void> refreshProfile() async {
    await _fetchEmployeeProfile();
  }

  Future<void> _fetchEmployeeProfile() async {
    try {
      final response = await _apiService.dio.get(ApiConstants.profile);
      if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          
          _branchId = data['branch_id'];
          _isSuperadmin = data['is_superadmin'] ?? false;
          _branchName = data['branch_name'];
          _branchImage = data['branch_image'];

          // IMPORTANT: data['id'] is User ID. We need Employee ID from the 'employee' object.
          if (data['employee'] != null) {
              final empData = data['employee'];
              _employeeId = empData['id'];
              _userName = empData['name'];
              _userImage = empData['image_url'];
              
              if (empData['daily_tasks'] != null) {
                try {
                  print("[DEBUG-AUTH] Raw daily_tasks: ${empData['daily_tasks']}");
                  List<dynamic> parsed = jsonDecode(empData['daily_tasks']);
                  _dailyTasks = parsed.map((e) => e.toString()).toList();
                  print("[DEBUG-AUTH] Parsed dailyTasks: $_dailyTasks");
                } catch (e) {
                  print("[DEBUG-AUTH] Parse error: $e, using raw string");
                  _dailyTasks = [empData['daily_tasks'].toString()];
                }
              } else {
                print("[DEBUG-AUTH] daily_tasks is null in API response");
                _dailyTasks = [];
              }
              
              print("Patched Employee Profile via /me: $_userName, EMID:$_employeeId, Image:$_userImage, Tasks:${_dailyTasks.length}");
              notifyListeners();
          } else {
              // Fallback if no employee record but we have user data
              _userId = data['id'];
              _userName = data['email'];
              _dailyTasks = [];
              print("User logged in but no employee record found for ID: $_userId");
          }
      }
    } catch (e) {
      print("Warning: Failed to fetch employee profile: $e");
    }
  }
}
