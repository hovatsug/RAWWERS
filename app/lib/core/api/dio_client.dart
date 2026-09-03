import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rawwers/core/api/auth_interceptors.dart';
import 'package:rawwers/core/api/debug_log_interceptor.dart';
import 'package:rawwers/core/api/session.dart';

/// Default timeout for ordinary JSON calls. Media transfer (upload PUTs,
/// large gallery fetches) overrides receiveTimeout per-call - see
/// lib/core/upload/.
const defaultConnectTimeout = Duration(seconds: 10);
const defaultReceiveTimeout = Duration(seconds: 15);

Dio createDio({required String baseUrl, required SessionStorage sessionStorage}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: defaultConnectTimeout,
      receiveTimeout: defaultReceiveTimeout,
    ),
  );

  dio.interceptors.add(AuthInterceptor(sessionStorage: sessionStorage));
  dio.interceptors.add(RefreshInterceptor(dio: dio, sessionStorage: sessionStorage));
  if (kDebugMode) {
    dio.interceptors.add(DebugLogInterceptor());
  }

  return dio;
}
