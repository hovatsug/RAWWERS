import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/env.dart';

/// The backend the `integration`-tagged tests run against: the app's own
/// API_BASE_URL - the address their requests really go to - so the guard
/// checks that address and no other. `--dart-define=API_BASE_URL=...` moves
/// both together.
///
/// Those tests run only on request - `dart_test.yaml` skips the tag, and
/// `flutter test --tags integration --run-skipped` runs them (app/README.md).
/// When they do run they register real accounts, so they first make sure the
/// backend is this machine's and says it is a development or test
/// environment, and they delete what they made.
const localBackendUrl = Env.apiBaseUrl;

const _loopbackHosts = {'localhost', '127.0.0.1', '::1'};
const _devEnvironments = {'development', 'dev', 'local', 'test'};

/// Why the integration tests must not run against [baseUrl], or null when
/// they may. Nothing is sent anywhere but this machine.
Future<String?> integrationRefusal({String baseUrl = localBackendUrl}) async {
  final uri = Uri.parse(baseUrl);
  if (!_loopbackHosts.contains(uri.host)) {
    return 'refusing to run integration tests against $baseUrl: only a backend on this machine';
  }
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  try {
    final request = await client.getUrl(uri.resolve('/v1/dev/environment'));
    final response = await request.close().timeout(const Duration(seconds: 2));
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != HttpStatus.ok) {
      return 'refusing to run integration tests: the backend at $baseUrl does not say it is a development or '
          'test environment (/v1/dev/environment answered ${response.statusCode})';
    }
    final environment = (jsonDecode(body) as Map<String, dynamic>)['environment'];
    if (!_devEnvironments.contains(environment)) {
      return 'refusing to run integration tests: the backend at $baseUrl is "$environment"';
    }
    return null;
  } on Exception {
    return 'no backend at $baseUrl - start api/ with docker compose up, then run the integration tests again';
  } finally {
    client.close(force: true);
  }
}

/// Fails every test in the file, before any of them touches the backend,
/// unless [integrationRefusal] allows it. Failing, not skipping: these run
/// only when asked for, and a requested run that skips has proved nothing.
void requireLocalDevBackend({String baseUrl = localBackendUrl}) {
  setUpAll(() async {
    final refusal = await integrationRefusal(baseUrl: baseUrl);
    if (refusal != null) fail(refusal);
  });
}

/// Deletes the account an integration test registered, through the
/// backend's development-only route: signs in as it, then deletes it. An
/// account that never got made (login refused) has nothing to delete;
/// anything else that stops the deletion fails the test, so a run that
/// leaves an account behind says so.
Future<void> deleteTestAccount({
  required String email,
  required String password,
  String baseUrl = localBackendUrl,
}) async {
  final uri = Uri.parse(baseUrl);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  try {
    final login = await client.postUrl(uri.resolve('/v1/auth/login'));
    login.headers.contentType = ContentType.json;
    login.write(jsonEncode({'email': email, 'password': password}));
    final loggedIn = await login.close();
    final loginBody = await loggedIn.transform(utf8.decoder).join();
    if (loggedIn.statusCode == HttpStatus.unauthorized) return;
    if (loggedIn.statusCode != HttpStatus.ok) {
      throw StateError('could not sign in as $email to delete it: ${loggedIn.statusCode} $loginBody');
    }
    final token = (jsonDecode(loginBody) as Map<String, dynamic>)['access_token'] as String;

    final delete = await client.deleteUrl(uri.resolve('/v1/dev/test-accounts/me'));
    delete.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    final deleted = await delete.close();
    final deleteBody = await deleted.transform(utf8.decoder).join();
    if (deleted.statusCode != HttpStatus.noContent) {
      throw StateError('test account $email was left behind: ${deleted.statusCode} $deleteBody');
    }
  } finally {
    client.close(force: true);
  }
}
