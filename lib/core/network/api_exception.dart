class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isConflict => statusCode == 409;

  bool get isServerError =>
      statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return 'ApiException($statusCode): $message';
  }
}