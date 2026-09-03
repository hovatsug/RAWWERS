import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only. Logs method/URL/status, never the request or response body
/// (the simplest way to guarantee a token field buried in some payload -
/// login, refresh, register - never reaches the log), and redacts the
/// Authorization header value.
class DebugLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method} ${options.uri} ${_redactedHeaders(options.headers)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}');
    }
    handler.next(err);
  }

  Map<String, dynamic> _redactedHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') return MapEntry(key, 'Bearer <redacted>');
      return MapEntry(key, value);
    });
  }
}
