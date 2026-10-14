// The guard the integration tests run behind, and the teardown that deletes
// what they register - checked against a fake backend on this machine, so
// they run in every ordinary `flutter test`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rawwers/core/env.dart';

import '../support/local_backend.dart';

class _FakeBackend {
  late HttpServer server;
  String environment = 'development';
  int environmentStatus = 200;
  int loginStatus = 200;
  int deleteStatus = 204;
  final calls = <String>[];

  String get url => 'http://127.0.0.1:${server.port}';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      calls.add('${request.method} ${request.uri.path}');
      final response = request.response;
      switch ('${request.method} ${request.uri.path}') {
        case 'GET /v1/dev/environment':
          response.statusCode = environmentStatus;
          response.write(jsonEncode({'environment': environment}));
        case 'POST /v1/auth/login':
          response.statusCode = loginStatus;
          response.write(jsonEncode({'access_token': 'token-1'}));
        case 'DELETE /v1/dev/test-accounts/me':
          calls.add('auth ${request.headers.value(HttpHeaders.authorizationHeader)}');
          response.statusCode = deleteStatus;
        default:
          response.statusCode = 404;
      }
      await response.close();
    });
  }
}

void main() {
  late _FakeBackend backend;

  setUp(() async {
    backend = _FakeBackend();
    await backend.start();
  });

  tearDown(() => backend.server.close(force: true));

  group('the guard', () {
    test('allows a development backend on this machine', () async {
      expect(await integrationRefusal(baseUrl: backend.url), isNull);
    });

    test('allows a test backend on this machine', () async {
      backend.environment = 'test';
      expect(await integrationRefusal(baseUrl: backend.url), isNull);
    });

    for (final environment in ['production', 'staging', '']) {
      test('refuses a backend that says it is "$environment"', () async {
        backend.environment = environment;
        expect(await integrationRefusal(baseUrl: backend.url), contains('refusing'));
      });
    }

    test('refuses a backend with no development route - production has none', () async {
      backend.environmentStatus = 404;
      expect(await integrationRefusal(baseUrl: backend.url), contains('404'));
    });

    test('refuses anything not on this machine, without sending it a request', () async {
      final refusal = await integrationRefusal(baseUrl: 'https://api.rawwers.com');
      expect(refusal, contains('only a backend on this machine'));
      expect(backend.calls, isEmpty);
    });

    test('says how to start one when nothing answers', () async {
      final url = backend.url;
      await backend.server.close(force: true);
      expect(await integrationRefusal(baseUrl: url), contains('docker compose up'));
    });
  });

  group('the teardown', () {
    test('signs in as the account and deletes it', () async {
      await deleteTestAccount(email: 'f5-1@rawwers.test', password: 'pw', baseUrl: backend.url);
      expect(backend.calls, ['POST /v1/auth/login', 'DELETE /v1/dev/test-accounts/me', 'auth Bearer token-1']);
    });

    test('has nothing to do for an account that was never made', () async {
      backend.loginStatus = 401;
      await deleteTestAccount(email: 'f5-1@rawwers.test', password: 'pw', baseUrl: backend.url);
      expect(backend.calls, ['POST /v1/auth/login']);
    });

    test('fails the test when the account is left behind', () async {
      backend.deleteStatus = 409;
      await expectLater(
        deleteTestAccount(email: 'f5-1@rawwers.test', password: 'pw', baseUrl: backend.url),
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('left behind'))),
      );
    });
  });

  group('the setup', () {
    test('the guard checks the address the app really calls', () {
      expect(localBackendUrl, Env.apiBaseUrl);
    });


    test('an ordinary run skips the integration tag', () {
      final config = File('dart_test.yaml').readAsStringSync();
      final integration = RegExp(r'^  integration:\n((?:    .*\n|\s*\n)*)', multiLine: true).firstMatch('$config\n');
      expect(integration, isNotNull);
      expect(integration!.group(1), contains('skip:'));
    });

    test('every integration test file runs behind the guard', () {
      final tagged = Directory('test')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('_test.dart'))
          .where((f) => f.readAsStringSync().contains("@Tags(['integration'])"))
          .toList();
      expect(tagged, isNotEmpty);
      for (final file in tagged) {
        expect(file.readAsStringSync(), contains('requireLocalDevBackend('), reason: file.path);
      }
    });
  });
}
