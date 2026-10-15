// Signing out tells the server before forgetting the session - so a
// photographer's online dot comes down at once and the server refuses
// anything this session still sends - and never waits long on it.
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/dio_client.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/session.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/in_memory_session_storage.dart';

class _Backend {
  final logouts = <({String? auth, Map<String, dynamic> body})>[];
  Completer<void>? hang;
  bool down = false;

  Future<ResponseBody> handle(RequestOptions o) async {
    if (o.uri.path == '/v1/me') {
      return jsonResponseBody(jsonEncode({'user_id': 'pro-1', 'status': 'active', 'roles': ['pro', 'client']}), 200);
    }
    if (o.uri.path == '/v1/auth/logout') {
      if (down) throw DioException.connectionError(requestOptions: o, reason: 'offline');
      if (hang != null) await hang!.future;
      final body = (o.data is String ? jsonDecode(o.data as String) : o.data) as Map<String, dynamic>;
      logouts.add((auth: o.headers['Authorization'] as String?, body: body));
      return ResponseBody.fromString('', 204);
    }
    return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
  }
}

Future<(ProviderContainer, InMemorySessionStorage)> _signedIn(_Backend backend) async {
  final storage = InMemorySessionStorage();
  await storage.write(const Session(accessToken: 'access-1', refreshToken: 'refresh-1'));
  final dio = createDio(baseUrl: 'https://example.invalid', sessionStorage: storage)
    ..httpClientAdapter = FakeHttpClientAdapter(backend.handle);
  final container = ProviderContainer(
    overrides: [sessionStorageProvider.overrideWithValue(storage), dioProvider.overrideWithValue(dio)],
  );
  addTearDown(container.dispose);
  expect(await container.read(authControllerProvider.future), isA<AuthAuthenticated>());
  return (container, storage);
}

void main() {
  test('signing out tells the server, with this session, before forgetting it', () async {
    final backend = _Backend();
    final (container, storage) = await _signedIn(backend);

    await container.read(authControllerProvider.notifier).logout();

    expect(backend.logouts, hasLength(1));
    expect(backend.logouts.single.body['refresh_token'], 'refresh-1');
    expect(backend.logouts.single.auth, 'Bearer access-1');
    expect(await storage.read(), isNull);
    expect(container.read(authControllerProvider).valueOrNull, isA<AuthUnauthenticated>());
  });

  test('offline, signing out still signs out', () async {
    final backend = _Backend()..down = true;
    final (container, storage) = await _signedIn(backend);

    await container.read(authControllerProvider.notifier).logout();

    expect(await storage.read(), isNull);
    expect(container.read(authControllerProvider).valueOrNull, isA<AuthUnauthenticated>());
  });

  test('a server that does not answer is not waited on for long', () async {
    final backend = _Backend()..hang = Completer<void>();
    final (container, storage) = await _signedIn(backend);

    final watch = Stopwatch()..start();
    await container.read(authControllerProvider.notifier).logout();
    watch.stop();

    expect(watch.elapsed, lessThan(AuthController.serverLogoutTimeout + const Duration(seconds: 1)));
    expect(await storage.read(), isNull);
    backend.hang!.complete();
  });
}
