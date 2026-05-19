class AppConstants {
  // App Info
  static const String appName = 'LoadStock';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String productsRoute = '/products';
  static const String salesRoute = '/sales';
  static const String stockRoute = '/stock';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
}
