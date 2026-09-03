@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/i18n_client.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/dio_client.dart';
import 'package:rawwers/core/api/result.dart';

import '../../support/in_memory_session_storage.dart';

/// F-3's deliverable: one real call, through the full transport stack
/// (interceptors included), against the actual local backend - not a fake.
/// Requires `docker compose up` in api/ to be running.
void main() {
  test('GET /v1/i18n/bundles round-trips through the real transport stack against the local backend', () async {
    final dio = createDio(baseUrl: 'http://localhost:8000', sessionStorage: InMemorySessionStorage());
    final client = I18nClient(dio);

    final result = await apiCall(
      () => client.getI18nBundleV1I18nBundlesGet(locale: 'en-GB', namespace: 'core'),
    );

    switch (result) {
      case Ok(:final value):
        expect(value.locale, 'en-GB');
        expect(value.namespace, 'core');
        expect(value.content, isNotEmpty);
      case Err(:final failure):
        fail('expected the local backend to be reachable and return 200, got $failure');
    }
  });
}
