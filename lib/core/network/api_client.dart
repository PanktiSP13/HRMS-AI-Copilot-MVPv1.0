import 'package:dio/dio.dart';
import 'package:hrms_ai_copilot/core/network/api_config.dart';

import '../storage/token_storage.dart';
import 'api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  bool _isRefreshing = false;
  Future<String?>? _refreshFuture;

  ApiClient({
    required TokenStorage tokenStorage,
  })  : _tokenStorage = tokenStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiRoot,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            sendTimeout: AppConfig.sendTimeout,
            headers: {
              ApiHeaders.contentType: ApiContentTypes.json,
              ApiHeaders.accept: ApiContentTypes.json,
            },
          ),
        ) {
    _configureInterceptors();
  }

  void _configureInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers[ApiHeaders.authorization] = '${ApiAuthConstants.bearerScheme} $accessToken';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (!_shouldRefresh(error)) {
            handler.next(error);
            return;
          }

          try {
            final newAccessToken = await _refreshAccessToken();

            if (newAccessToken == null || newAccessToken.isEmpty) {
              handler.next(error);
              return;
            }

            final retryResponse = await _retryRequest(
              error.requestOptions,
              newAccessToken,
            );

            handler.resolve(retryResponse);
          } on DioException {
            await _tokenStorage.clearTokens();
            handler.next(error);
          } catch (_) {
            await _tokenStorage.clearTokens();
            handler.next(error);
          }
        },
      ),
    );
  }

  bool _shouldRefresh(DioException error) {
    return error.response?.statusCode == ApiStatusCodes.unauthorized && error.requestOptions.extra[ApiRequestOptions.skipRefresh] != true;
  }

  Future<String?> _refreshAccessToken() async {
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture;
    }

    _isRefreshing = true;

    _refreshFuture = _performTokenRefresh();

    try {
      return await _refreshFuture;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  Future<String?> _performTokenRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clearTokens();
      return null;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiRoot,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          ApiHeaders.contentType: ApiContentTypes.json,
          ApiHeaders.accept: ApiContentTypes.json,
        },
      ),
    );

    try {
      final response = await refreshDio.post(
        ApiRoutes.refreshToken,
        data: {
          ApiAuthConstants.refreshTokenKey: refreshToken,
        },
      );

      final responseData = Map<String, dynamic>.from(
        response.data as Map,
      );

      final accessToken = responseData[ApiAuthConstants.accessTokenKey] as String?;

      final newRefreshToken = responseData[ApiAuthConstants.refreshTokenKey] as String?;

      if (accessToken == null || accessToken.isEmpty || newRefreshToken == null || newRefreshToken.isEmpty) {
        await _tokenStorage.clearTokens();
        return null;
      }

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );

      return accessToken;
    } on DioException {
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) async {
    final headers = Map<String, dynamic>.from(
      requestOptions.headers,
    );

    headers[ApiHeaders.authorization] = '${ApiAuthConstants.bearerScheme} $accessToken';

    final extra = Map<String, dynamic>.from(
      requestOptions.extra,
    );

    extra[ApiRequestOptions.skipRefresh] = true;

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        extra: extra,
        followRedirects: requestOptions.followRedirects,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
      ),
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _convertError(error);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _convertError(error);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      throw _convertError(error);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      throw _convertError(error);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      throw _convertError(error);
    }
  }

  Future<Response<dynamic>> upload(
    String path, {
    required FormData data,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: Options(
          contentType: ApiContentTypes.multipartFormData,
          sendTimeout: AppConfig.uploadTimeout,
          receiveTimeout: AppConfig.uploadTimeout,
        ),
      );
    } on DioException catch (error) {
      throw _convertError(error);
    }
  }

  Future<Response<dynamic>> download(
    String path,
  ) async {
    try {
      return await _dio.get(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: AppConfig.uploadTimeout,
        ),
      );
    } on DioException catch (error) {
      throw _convertError(error);
    }
  }

  ApiException _convertError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = ApiErrorMessages.somethingWentWrong;

    if (responseData is Map) {
      final detail = responseData[ApiResponseKeys.detail];

      if (detail is String && detail.isNotEmpty) {
        message = detail;
      }
    }

    if (statusCode == ApiStatusCodes.badRequest) {
      message = _extractDetail(
        responseData,
        fallback: ApiErrorMessages.invalidRequest,
      );
    } else if (statusCode == ApiStatusCodes.unauthorized) {
      message = ApiErrorMessages.authenticationRequired;
    } else if (statusCode == ApiStatusCodes.forbidden) {
      message = _extractDetail(
        responseData,
        fallback: ApiErrorMessages.permissionDenied,
      );
    } else if (statusCode == ApiStatusCodes.notFound) {
      message = ApiErrorMessages.resourceNotFound;
    } else if (statusCode == ApiStatusCodes.conflict) {
      message = _extractDetail(
        responseData,
        fallback: ApiErrorMessages.resourceAlreadyExists,
      );
    } else if (statusCode != null && statusCode >= ApiStatusCodes.internalServerError) {
      message = ApiErrorMessages.serverError;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = ApiErrorMessages.requestTimedOut;
    } else if (error.type == DioExceptionType.connectionError) {
      message = ApiErrorMessages.unableToConnect;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
    );
  }

  String _extractDetail(
    dynamic responseData, {
    required String fallback,
  }) {
    if (responseData is Map) {
      final detail = responseData[ApiResponseKeys.detail];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    }

    return fallback;
  }
}
