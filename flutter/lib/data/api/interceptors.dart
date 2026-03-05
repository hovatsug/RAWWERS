import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import 'models/api_error.dart';
import 'token_store.dart';

typedef RefreshCallback = Future<TokenResponse?> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required TokenStore tokenStore, required RefreshCallback onRefresh, required Dio retryClient})
      : _tokenStore = tokenStore,
        _onRefresh = onRefresh,
        _retryClient = retryClient;

  final TokenStore _tokenStore;
  final RefreshCallback _onRefresh;
  final Dio _retryClient;

  Future<TokenResponse?>? _refreshFuture;

  bool _isAuthPath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/password-reset') ||
        path.contains('/auth/verify-email');
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = _tokenStore.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final options = err.requestOptions;
    final alreadyRetried = options.extra['retried'] == true;

    if (statusCode == 401 && !alreadyRetried && !_isAuthPath(options.path)) {
      _refreshFuture ??= _onRefresh();
      final refreshed = await _refreshFuture;
      _refreshFuture = null;

      if (refreshed != null) {
        final retryOptions = options.copyWith(
          headers: {
            ...options.headers,
            'Authorization': 'Bearer ${refreshed.accessToken}',
          },
          extra: {...options.extra, 'retried': true},
        );
        final response = await _retryClient.fetch(retryOptions);
        handler.resolve(response);
        return;
      }
    }

    handler.next(err);
  }
}

class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final payload = err.response?.data;
    if (payload is Map<String, dynamic> && payload['error'] is Map<String, dynamic>) {
      final data = payload['error'] as Map<String, dynamic>;
      final requestId = (data['details'] is Map<String, dynamic>) ? (data['details']['request_id'] as String?) : null;
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: ApiError(
            code: data['code'] as String? ?? 'unknown_error',
            message: data['message'] as String? ?? 'Request failed',
            requestId: requestId,
          ),
          type: err.type,
        ),
      );
      return;
    }
    handler.next(err);
  }
}

class SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only log method and path to avoid leaking tokens, payloads, or user fields.
    // ignore: avoid_print
    print('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }
}
