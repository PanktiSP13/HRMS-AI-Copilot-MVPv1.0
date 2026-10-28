import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_constants.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;

  const TokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: ApiStorageKeys.accessToken,
      value: accessToken,
    );

    await _storage.write(
      key: ApiStorageKeys.refreshToken,
      value: refreshToken,
    );
  }

  Future<String?> getAccessToken() async {
    return _storage.read(
      key: ApiStorageKeys.accessToken,
    );
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(
      key: ApiStorageKeys.refreshToken,
    );
  }

  Future<void> clearTokens() async {
    await _storage.delete(
      key: ApiStorageKeys.accessToken,
    );

    await _storage.delete(
      key: ApiStorageKeys.refreshToken,
    );
  }

  Future<bool> hasAccessToken() async {
    final accessToken = await getAccessToken();

    return accessToken != null && accessToken.isNotEmpty;
  }

  Future<bool> hasRefreshToken() async {
    final refreshToken = await getRefreshToken();

    return refreshToken != null && refreshToken.isNotEmpty;
  }
}
