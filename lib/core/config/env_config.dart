import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Singleton pattern
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  // Informações do Aplicativo
  static String get appName => dotenv.get('APP_NAME', fallback: 'LoadStock');
  static String get appSubtitle => dotenv.get('APP_SUBTITLE', fallback: 'Sistema PDV Moderno');
  static String get appVersion => dotenv.get('APP_VERSION', fallback: '1.0.0');

  // Assets
  static String get logoPath => dotenv.get('LOGO_PATH', fallback: 'assets/logo/logo.svg');
  static String get logoIcon => dotenv.get('LOGO_ICON', fallback: 'S');

  // API Configuration
  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: 'http://localhost:8000/api');
  static int get apiTimeout => int.parse(dotenv.get('API_TIMEOUT', fallback: '30000'));

  // Autenticação
  static String get authTokenKey => dotenv.get('AUTH_TOKEN_KEY', fallback: 'auth_token');
  static String get authUserKey => dotenv.get('AUTH_USER_KEY', fallback: 'user_data');
  static String get authRefreshTokenKey => dotenv.get('AUTH_REFRESH_TOKEN_KEY', fallback: 'refresh_token');

  // Storage Keys
  static String get themeKey => dotenv.get('THEME_KEY', fallback: 'theme_mode');
  static String get languageKey => dotenv.get('LANGUAGE_KEY', fallback: 'language');
  static String get firstRunKey => dotenv.get('FIRST_RUN_KEY', fallback: 'first_run');

  // Cores do Tema
  static Color get primaryColor {
    final colorString = dotenv.get('PRIMARY_COLOR', fallback: '0xFF2563EB');
    return Color(int.parse(colorString));
  }

  static Color get secondaryColor {
    final colorString = dotenv.get('SECONDARY_COLOR', fallback: '0xFF3B82F6');
    return Color(int.parse(colorString));
  }

  static Color get accentColor {
    final colorString = dotenv.get('ACCENT_COLOR', fallback: '0xFF10B981');
    return Color(int.parse(colorString));
  }

  static Color get errorColor {
    final colorString = dotenv.get('ERROR_COLOR', fallback: '0xFFEF4444');
    return Color(int.parse(colorString));
  }

  static Color get warningColor {
    final colorString = dotenv.get('WARNING_COLOR', fallback: '0xFFF59E0B');
    return Color(int.parse(colorString));
  }

  static Color get successColor {
    final colorString = dotenv.get('SUCCESS_COLOR', fallback: '0xFF10B981');
    return Color(int.parse(colorString));
  }

  // Configurações de Desenvolvimento
  static bool get debugMode => dotenv.get('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';
  static bool get enableLogs => dotenv.get('ENABLE_LOGS', fallback: 'false').toLowerCase() == 'true';

  // Método para verificar se o .env foi carregado
  static bool get isLoaded => dotenv.isEveryDefined([
    'APP_NAME',
    'API_BASE_URL',
  ]);

  // Método para imprimir configurações (apenas em debug)
  static void printConfig() {
    if (debugMode) {
      debugPrint('=== EnvConfig ===');
      debugPrint('App Name: $appName');
      debugPrint('App Subtitle: $appSubtitle');
      debugPrint('App Version: $appVersion');
      debugPrint('API Base URL: $apiBaseUrl');
      debugPrint('Debug Mode: $debugMode');
      debugPrint('================');
    }
  }
}
