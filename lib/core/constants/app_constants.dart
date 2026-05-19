import 'package:loadstock/core/config/env_config.dart';

class AppConstants {
  // App Info (usando EnvConfig)
  static String get appName => EnvConfig.appName;
  static String get appSubtitle => EnvConfig.appSubtitle;
  static String get appVersion => EnvConfig.appVersion;
  
  // API Configuration (usando EnvConfig)
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;
  static Duration get apiTimeout => Duration(milliseconds: EnvConfig.apiTimeout);
  
  // Storage Keys (usando EnvConfig)
  static String get tokenKey => EnvConfig.authTokenKey;
  static String get userKey => EnvConfig.authUserKey;
  static String get refreshTokenKey => EnvConfig.authRefreshTokenKey;
  static String get themeKey => EnvConfig.themeKey;
  static String get languageKey => EnvConfig.languageKey;
  static String get firstRunKey => EnvConfig.firstRunKey;
  
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
