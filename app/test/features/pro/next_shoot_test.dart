// The You tab's next shoot: the soonest still to happen, wherever it falls in
// the gigs list (which is paged by booking, not by shoot date).
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/features/pro/dashboard/next_shoot.dart';

import '../../support/fake_http_client_adapter.dart';
import 'you_tab_fixtures.dart';

Map<String, dynamic> _json(String id, GigStatus status, DateTime start) => gig(id: id, status: status, start: start).toJson();

void main() {
  test('the soonest active shoot, from any page; cancelled ones never count', () async {
    final now = DateTime.now().toUtc();
    final requested = <String?>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = FakeHttpClientAdapter((o) async {
        final cursor = o.uri.queryParameters['cursor'];
        requested.add(o.uri.queryParameters['scheduled_from']);
        if (cursor == null) {
          return jsonResponseBody(
            jsonEncode({
              'items': [_json('late', GigStatus.scheduled, now.add(const Duration(days: 20)))],
              'next_cursor': 'p2',
            }),
            200,
          );
        }
        return jsonResponseBody(
          jsonEncode({
            'items': [
              _json('cancelled', GigStatus.cancelledByClient, now.add(const Duration(days: 1))),
              _json('soon', GigStatus.paid, now.add(const Duration(days: 3))),
            ],
            'next_cursor': null,
          }),
          200,
        );
      });
    final container = ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    addTearDown(container.dispose);

    final next = await container.read(nextShootProvider.future);
    expect(next?.id, 'soon');
    expect(requested, everyElement(isNotNull), reason: 'only shoots from now on are asked for');
  });

  test('none booked is null, not an error', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = FakeHttpClientAdapter((o) async => jsonResponseBody('{"items": [], "next_cursor": null}', 200));
    final container = ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    addTearDown(container.dispose);
    expect(await container.read(nextShootProvider.future), isNull);
  });
}
