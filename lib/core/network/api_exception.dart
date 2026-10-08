class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;
  const ApiException(this.message, {
    this.statusCode, this.cause
  }
  );
  bool get isUnauthorized => statusCode == 401;
  @override
  String toString() => message;
}
