import 'dart:async';

import 'package:dio/dio.dart';
import 'package:rawwers/api/models/refresh_request.dart';
import 'package:rawwers/api/models/token_response.dart';
import 'package:rawwers/core/api/session.dart';

/// Marks a request as exempt from auth-header attachment and 401-refresh
/// handling. Used for the refresh call itself so it can never trigger
/// another refresh of itself.
const skipAuthExtraKey = 'rawwers_skip_auth';

const _retriedExtraKey = 'rawwers_retried_after_refresh';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.sessionStorage});

  final SessionStorage sessionStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[skipAuthExtraKey] != true) {
      final session = await sessionStorage.read();
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
    }
    handler.next(options);
  }
}

/// Single-flight 401-refresh-and-retry. Rotation makes this a correctness
/// requirement, not an optimization: /v1/auth/refresh returns a new
/// refresh_token and invalidates the old one, so two concurrent refreshes
/// with the same (stale-after-the-first-succeeds) refresh token would have
/// the second one rejected. Every 401 arriving while a refresh is already
/// in flight awaits that same refresh instead of starting a second one.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({required this.dio, required this.sessionStorage});

  final Dio dio;
  final SessionStorage sessionStorage;

  Future<bool>? _refreshInFlight;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthExempt = err.requestOptions.extra[skipAuthExtraKey] == true;
    final alreadyRetried = err.requestOptions.extra[_retriedExtraKey] == true;

    if (isAuthExempt || err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      await sessionStorage.clear();
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.extra[_retriedExtraKey] = true;
      final response = await dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refreshOnce() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<bool> _doRefresh() async {
    final session = await sessionStorage.read();
    if (session == null) return false;

    // A raw dio.post() rather than the generated AuthClient here: marking
    // this request exempt (skipAuthExtraKey) needs direct control of
    // RequestOptions.extra, which retrofit's generated method signature
    // doesn't expose. The wire shape still comes entirely from the
    // generated RefreshRequest/TokenResponse models below.
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/v1/auth/refresh',
        data: RefreshRequest(refreshToken: session.refreshToken).toJson(),
        options: Options(extra: {skipAuthExtraKey: true}),
      );
      final token = TokenResponse.fromJson(response.data!);
      // Both tokens are new after rotation - write them as one record.
      await sessionStorage.write(
        Session(accessToken: token.accessToken, refreshToken: token.refreshToken),
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
