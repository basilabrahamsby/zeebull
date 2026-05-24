import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Zeebull';
  
  // Local Development URL
  static String get baseUrl => kIsWeb ? 'http://localhost:8011/api' : 'http://10.0.2.2:8011/api';
  
  // Production URL
  // static const String baseUrl = 'https://zeebull.com/api';
}

