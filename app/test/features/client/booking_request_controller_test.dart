import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/client_launch_client.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/features/client/booking_request/booking_request_controller.dart';

import '../../support/fake_http_client_adapter.dart';

/// Asserts the request that actually goes over the wire, through the real
/// generated client rather than a hand-written body. The date window is the
/// part worth pinning: the API stores instants, so a naive local time would
/// book the shoot in the wrong hour for everyone outside UTC.
ProviderContainer _container(FakeHandler handler) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  dio.httpClientAdapter = FakeHttpClientAdapter(handler);

  final container = ProviderContainer(
    overrides: [clientLaunchClientProvider.overrideWithValue(ClientLaunchClient(dio))],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('sends the shoot window as UTC instants', () async {
    Map<String, dynamic>? body;
    final container = _container((options) async {
      body = jsonDecode(jsonEncode(options.data)) as Map<String, dynamic>;
      return jsonResponseBody(
        jsonEncode({'booking_id': 'booking-1', 'status': 'pending'}),
        200,
      );
    });

    // A local wall-clock time, the way the form produces it.
    final start = DateTime(2026, 9, 20, 14);
    final outcome = await container.read(bookingRequestControllerProvider.notifier).submit(
          proUserId: 'pro-1',
          packageId: 'pkg-1',
          nicheSlug: 'portraits',
          startAt: start,
          endAt: start.add(const Duration(minutes: 90)),
          location: 'Lisbon, Alfama',
          notes: 'Golden hour please.',
        );

    expect(outcome, isA<BookingRequestSent>());
    expect((outcome as BookingRequestSent).bookingId, 'booking-1');

    final window = body!['date_window'] as Map<String, dynamic>;
    expect(DateTime.parse(window['start_at'] as String).isUtc, isTrue);
    expect(
      DateTime.parse(window['start_at'] as String).toUtc(),
      start.toUtc(),
    );
    expect(
      DateTime.parse(window['end_at'] as String).difference(DateTime.parse(window['start_at'] as String)),
      const Duration(minutes: 90),
    );
  });

  test('omits blank optional fields rather than sending empty strings', () async {
    Map<String, dynamic>? body;
    final container = _container((options) async {
      body = jsonDecode(jsonEncode(options.data)) as Map<String, dynamic>;
      return jsonResponseBody(jsonEncode({'booking_id': 'b', 'status': 'pending'}), 200);
    });

    await container.read(bookingRequestControllerProvider.notifier).submit(
          proUserId: 'pro-1',
          packageId: 'pkg-1',
          nicheSlug: 'portraits',
          startAt: DateTime(2026, 9, 20, 14),
          endAt: DateTime(2026, 9, 20, 15),
          location: '   ',
          notes: '',
        );

    // An empty location on a booking is worse than no location: it looks
    // like the client answered when they did not.
    expect(body!['location'], isNull);
    expect(body!['notes'], isNull);
    // consent_level stays null so the account's own default applies.
    expect(body!['consent_level'], isNull);
  });

  test('a 409 explains it is the photographer who is not ready', () async {
    final container = _container((options) async {
      return jsonResponseBody(
        jsonEncode({
          'error': {'code': 'invalid_state', 'message': 'Pro has no availability configured'},
        }),
        409,
      );
    });

    final outcome = await container.read(bookingRequestControllerProvider.notifier).submit(
          proUserId: 'pro-1',
          packageId: 'pkg-1',
          nicheSlug: 'portraits',
          startAt: DateTime(2026, 9, 20, 14),
          endAt: DateTime(2026, 9, 20, 15),
        );

    expect(outcome, isA<BookingRequestFailed>());
    expect(
      (outcome as BookingRequestFailed).message,
      'This photographer has not opened their calendar yet.',
    );
  });

  test('the daily cap reads as a cap, not a fault', () async {
    final container = _container((options) async {
      return jsonResponseBody(
        jsonEncode({
          'error': {'code': 'rate_limited', 'message': 'Too many requests'},
        }),
        429,
      );
    });

    final outcome = await container.read(bookingRequestControllerProvider.notifier).submit(
          proUserId: 'pro-1',
          packageId: 'pkg-1',
          nicheSlug: 'portraits',
          startAt: DateTime(2026, 9, 20, 14),
          endAt: DateTime(2026, 9, 20, 15),
        );

    expect((outcome as BookingRequestFailed).message, contains('Try again tomorrow'));
  });
}
