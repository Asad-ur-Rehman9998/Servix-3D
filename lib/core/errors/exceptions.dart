class AppException implements Exception {
  AppException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppException($statusCode): $message';
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Unauthorized']) : super(statusCode: 401);
}

class NotFoundException extends AppException {
  NotFoundException([super.message = 'Not found']) : super(statusCode: 404);
}
