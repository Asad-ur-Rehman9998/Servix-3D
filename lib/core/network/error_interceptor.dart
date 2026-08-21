import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final message = _extractMessage(err);

    if (status == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: UnauthorizedException(message),
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }

    if (status == 404) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: NotFoundException(message),
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: AppException(message, statusCode: status),
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _extractMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return err.message ?? 'Request failed';
  }
}
