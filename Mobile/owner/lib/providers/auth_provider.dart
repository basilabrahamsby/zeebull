import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data != null && response.data['access_token'] != null) {
        final token = response.data['access_token'];
        await _storage.write(key: 'auth_token', value: token);
        
        // Mock User for now (TODO: Decode JWT or fetch profile)
        _user = User(id: 1, email: email, role: 'owner', name: 'Owner'); 
        
        notifyListeners();
        return true;
      }
      _error = 'Invalid response from server';
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['detail'] ?? 'Login failed. Please check your credentials.';
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return false;

    // TODO: Verify token validity via API or locally (check expiry)
    // For now, assume valid if present
    _user = User(id: 1, email: 'owner@resort.com', role: 'owner', name: 'Owner'); 
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _user = null;
    notifyListeners();
  }
}
