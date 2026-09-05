import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/auth_interceptors.dart';
import 'package:rawwers/core/api/session.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/in_memory_session_storage.dart';

const _oldAccessToken = 'old-access-token';
const _oldRefreshToken = 'old-refresh-token';
const _newAccessToken = 'new-access-token';
const _newRefreshToken = 'new-refresh-token';

void main() {
  test(
    'concurrent 401s trigger exactly one refresh call, and every original request succeeds on retry',
    () async {
      var refreshCallCount = 0;

      final sessionStorage = InMemorySessionStorage(
        const Session(accessToken: _oldAccessToken, refreshToken: _oldRefreshToken),
      );

      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        // Small artificial delay so all concurrent callers are genuinely
        // in flight (past their 401, inside the refresh wait) before any
        // of them resolves - this is what actually exercises the
        // single-flight path rather than incidentally passing because
        // everything ran sequentially.
        await Future<void>.delayed(const Duration(milliseconds: 20));

        if (options.path == '/v1/auth/refresh') {
          refreshCallCount++;
          final body = options.data as Map<String, dynamic>;
          expect(
            body['refresh_token'],
            _oldRefreshToken,
            reason: 'refresh must only ever be called with the token that was current before rotation',
          );
          return jsonResponseBody(
            jsonEncode({
              'access_token': _newAccessToken,
              'refresh_token': _newRefreshToken,
              'expires_in': 900,
            }),
            200,
          );
        }

        if (options.path == '/v1/protected-test') {
          final authHeader = options.headers['Authorization'];
          if (authHeader == 'Bearer $_newAccessToken') {
            return jsonResponseBody(jsonEncode({'ok': true}), 200);
          }
          return jsonResponseBody(
            jsonEncode({
              'error': {'code': 'unauthorized', 'message': 'Invalid access token', 'details': {}},
            }),
            401,
          );
        }

        throw StateError('unexpected request path in test: ${options.path}');
      });

      dio.interceptors.add(AuthInterceptor(sessionStorage: sessionStorage));
      dio.interceptors.add(RefreshInterceptor(dio: dio, sessionStorage: sessionStorage));

      final responses = await Future.wait(
        List.generate(5, (_) => dio.get<Map<String, dynamic>>('/v1/protected-test')),
      );

      expect(refreshCallCount, 1, reason: 'rotation means a second concurrent refresh call would be rejected by the backend');
      for (final response in responses) {
        expect(response.statusCode, 200);
        expect(response.data, {'ok': true});
      }

      final storedSession = await sessionStorage.read();
      expect(storedSession?.accessToken, _newAccessToken);
      expect(storedSession?.refreshToken, _newRefreshToken);
      expect(
        sessionStorage.writeCallCount,
        1,
        reason: 'both rotated tokens must land in a single write - a separate access/refresh write pair '
            'would let one succeed and the other fail, permanently stranding the session',
      );
    },
  );
}
