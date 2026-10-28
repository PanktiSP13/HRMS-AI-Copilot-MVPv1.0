import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/auth.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(
      email: email,
      password: password,
    );

    final response = await _apiClient.post(
      ApiRoutes.login,
      data: request.toJson(),
    );

    final tokenResponse = TokenResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );

    await _tokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

    return tokenResponse;
  }

  Future<TokenResponse> register({
    required String employeeCode,
    required String name,
    required String email,
    required String password,
    required String role,
    String? department,
    String? phone,
    String? address,
    int? departmentId,
    int? managerId,
  }) async {
    final request = RegisterRequest(
      employeeCode: employeeCode,
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
      phone: phone,
      address: address,
      departmentId: departmentId,
      managerId: managerId,
    );

    final response = await _apiClient.post(
      ApiRoutes.register,
      data: request.toJson(),
    );

    final tokenResponse = TokenResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );

    await _tokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

    return tokenResponse;
  }

  Future<TokenResponse> refreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError(
        ApiErrorMessages.refreshTokenUnavailable,
      );
    }

    final request = RefreshTokenRequest(
      refreshToken: refreshToken,
    );

    final response = await _apiClient.post(
      ApiRoutes.refreshToken,
      data: request.toJson(),
      options: Options(
        extra: {
          // failed refresh request doesn't trigger another refresh attempt
          ApiRequestOptions.skipRefresh: true,
        },
      ),
    );

    final tokenResponse = TokenResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );

    await _tokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

    return tokenResponse;
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final request = RefreshTokenRequest(
          refreshToken: refreshToken,
        );

        await _apiClient.post(
          ApiRoutes.logout,
          data: request.toJson(),
          options: Options(
            extra: {
              ApiRequestOptions.skipRefresh: true,
            },
          ),
        );
      }
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  Future<MeResponse> getCurrentUser() async {
    final response = await _apiClient.get(
      ApiRoutes.currentUser,
    );

    return MeResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<bool> isLoggedIn() {
    return _tokenStorage.hasAccessToken();
  }

  Future<void> clearLocalSession() async {
    await _tokenStorage.clearTokens();
  }
}
