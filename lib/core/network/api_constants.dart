/// Centralized constants used by the networking layer.
///
/// Keep backend-related values here:
/// - API routes
/// - API configuration
/// - HTTP headers
/// - authentication values
/// - storage keys
/// - HTTP status codes
///
/// UI/common constants should remain inside:
/// lib/common/constants/app_constants.dart
class ApiConstants {
  ApiConstants._();
}

/// Backend API configuration.
class ApiConfig {
  ApiConfig._();

  /// Environment variable used to provide a custom backend URL.
  ///
  /// Example:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const String apiBaseUrlEnvironmentKey = 'API_BASE_URL';

  /// Default backend URL when running Flutter Web.
  static const String webBaseUrl = 'http://localhost:8000';

  /// Default backend URL when running on Android Emulator.
  ///
  /// 10.0.2.2 points to the host machine from
  /// the Android Emulator.
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8000';

  /// API version prefix used by FastAPI.
  static const String apiVersion = '/api/v1';

  /// Request timeout.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Response timeout.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Request upload/send timeout.
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Multipart upload timeout.
  static const Duration uploadTimeout = Duration(seconds: 60);
}

/// API routes defined by the HRMS backend contract.
///
/// These routes are relative to:
/// ApiConfig.apiVersion
///
/// Example:
/// ApiRoutes.login
/// -> /auth/login
///
/// ApiClient adds /api/v1 automatically through AppConfig.apiRoot.
class ApiRoutes {
  ApiRoutes._();

  // ===========================================================================
  // Authentication
  // ===========================================================================

  static const String login = '/auth/login';

  static const String register = '/auth/register';

  static const String refreshToken = '/auth/refresh';

  static const String logout = '/auth/logout';

  static const String currentUser = '/auth/user';

  // ===========================================================================
  // Employee self-service / profile
  // ===========================================================================

  static const String profile = '/profile';

  static const String profileAvatar = '/profile/avatar';

  static const String profileLeaveBalances = '/profile/leave-balances';

  static const String profileLeaveRequests = '/profile/leave-requests';

  static String profileLeaveRequest(int id) {
    return '$profileLeaveRequests/$id';
  }

  // ===========================================================================
  // Employees
  // ===========================================================================

  static const String employees = '/employees';

  static String employee(int id) {
    return '$employees/$id';
  }

  static String employeeAvatar(int id) {
    return '${employee(id)}/avatar';
  }

  static String employeeLeaveBalances(int id) {
    return '${employee(id)}/leave-balances';
  }

  // ===========================================================================
  // Leave requests
  // ===========================================================================

  static const String leaveRequests = '/leave-requests';

  static String leaveRequest(int id) {
    return '$leaveRequests/$id';
  }

  static String leaveRequestStatus(int id) {
    return '${leaveRequest(id)}/status';
  }

  // ===========================================================================
  // Departments
  // ===========================================================================

  static const String departments = '/departments';

  static String department(int id) {
    return '$departments/$id';
  }

  // ===========================================================================
  // Policies
  // ===========================================================================

  static const String policies = '/policies';

  static String policy(int id) {
    return '$policies/$id';
  }

  static const String policyUpload = '$policies/upload';

  static String policyDownload(int id) {
    return '${policy(id)}/download';
  }

  // ===========================================================================
  // Audit logs
  // ===========================================================================

  static const String auditLogs = '/audit-logs';

  // ===========================================================================
  // AI Copilot
  // ===========================================================================

  static const String aiChat = '/ai/chat';

  static const String aiConversations = '/ai/conversations';

  static String aiConversation(String conversationId) => '$aiConversations/$conversationId';

  static String aiConversationMessages(String conversationId) => '${aiConversation(conversationId)}/messages';
}

/// HTTP header names.
class ApiHeaders {
  ApiHeaders._();

  static const String contentType = 'Content-Type';

  static const String accept = 'Accept';

  static const String authorization = 'Authorization';
}

/// HTTP content types.
class ApiContentTypes {
  ApiContentTypes._();

  static const String json = 'application/json';

  static const String multipartFormData = 'multipart/form-data';
}

/// Authentication-related API constants.
class ApiAuthConstants {
  ApiAuthConstants._();

  /// Authentication scheme used by the backend.
  static const String bearerScheme = 'Bearer';

  /// Token type returned by the backend.
  static const String bearerTokenType = 'bearer';

  /// JSON field names returned by authentication APIs.
  static const String accessTokenKey = 'access_token';

  static const String refreshTokenKey = 'refresh_token';

  static const String tokenTypeKey = 'token_type';
}

/// Secure-storage keys used by the authentication layer.
class ApiStorageKeys {
  ApiStorageKeys._();

  static const String accessToken = 'access_token';

  static const String refreshToken = 'refresh_token';
}

/// HTTP status codes used by the networking layer.
///
/// Keeping these here avoids magic numbers such as 401, 403 and 404
/// throughout ApiClient and future interceptors.
class ApiStatusCodes {
  ApiStatusCodes._();

  static const int badRequest = 400;

  static const int unauthorized = 401;

  static const int forbidden = 403;

  static const int notFound = 404;

  static const int conflict = 409;

  static const int internalServerError = 500;
}

/// Common backend response keys.
class ApiResponseKeys {
  ApiResponseKeys._();

  /// FastAPI commonly returns:
  ///
  /// {
  ///   "detail": "Error message"
  /// }
  static const String detail = 'detail';
}

/// Multipart upload constants.
class ApiMultipartKeys {
  ApiMultipartKeys._();

  /// Field name expected by FastAPI UploadFile endpoints.
  static const String file = 'file';
}

class ApiErrorMessages {
  ApiErrorMessages._();

  static const String somethingWentWrong = 'Something went wrong';
  static const String invalidRequest = 'Invalid request';
  static const String authenticationRequired = 'Authentication required';
  static const String permissionDenied = 'You do not have permission to perform this action';
  static const String resourceNotFound = 'Requested resource was not found';
  static const String resourceAlreadyExists = 'Resource already exists';
  static const String serverError = 'Server error. Please try again later.';
  static const String requestTimedOut = 'Request timed out. Please try again.';
  static const String unableToConnect = 'Unable to connect to the server.';
  static const String refreshTokenUnavailable = 'Refresh token is not available';
}

class ApiRequestOptions {
  ApiRequestOptions._();

  static const String skipRefresh = 'skip_refresh';
}
