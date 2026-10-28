import 'package:flutter/foundation.dart';

import '../network/api_constants.dart';

class AppConfig {
  AppConfig._();

  /// Allows the backend URL to be overridden at runtime.
  ///
  /// Example:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const String _configuredBaseUrl = String.fromEnvironment(
    ApiConfig.apiBaseUrlEnvironmentKey,
  );

  /// Base URL of the backend server.
  ///
  /// Priority:
  /// 1. API_BASE_URL from --dart-define
  /// 2. localhost for Web
  /// 3. 10.0.2.2 for Android Emulator
  ///
  /// For iOS Simulator, localhost works because the simulator
  /// can access the host machine through localhost.
  static String get apiBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return ApiConfig.webBaseUrl;
    }

    return ApiConfig.androidEmulatorBaseUrl;
  }

  /// Complete API root.
  ///
  /// Example:
  /// http://localhost:8000/api/v1
  static String get apiRoot {
    return '$apiBaseUrl${ApiConfig.apiVersion}';
  }

  static Duration get connectTimeout {
    return ApiConfig.connectTimeout;
  }

  static Duration get receiveTimeout {
    return ApiConfig.receiveTimeout;
  }

  static Duration get sendTimeout {
    return ApiConfig.sendTimeout;
  }

  static Duration get uploadTimeout {
    return ApiConfig.uploadTimeout;
  }
}