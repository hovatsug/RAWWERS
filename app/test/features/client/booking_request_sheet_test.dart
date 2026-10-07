import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/client_launch_client.dart';
import 'package:rawwers/api/models/client_availability_start.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/booking_request/booking_request_controller.dart';
import 'package:rawwers/features/client/booking_request/booking_request_sheet.dart';
import 'package:rawwers/features/client/pro_profile/availability_calendar.dart';

import '../../support/fake_http_client_adapter.dart';

/// The booking request form is the highest-intent action in the client app,
/// so what it must not do is lose someone's request or send a nonsensical one.
class _FakeRequests extends BookingRequestController {
  _FakeRequests(this._outcome);

  final BookingRequestOutcome _outcome;

  DateTime? sentStart;
  DateTime? sentEnd;
  String? sentNiche;

  @override
  void build() {}

  @override
  Future<BookingRequestOutcome> submit({
    required String proUserId,
    required String packageId,
    required String nicheSlug,
    required DateTime startAt,
    required DateTime endAt,
    String? location,
    String? notes,
  }) async {
    sentStart = startAt;
    sentEnd = endAt;
    sentNiche = nicheSlug;
    return _outcome;
  }
}

const _package = ClientProfilePackage(
  id: 'pkg-1',
  nicheSlug: 'portraits',
  title: 'Portrait session',
  description: 'An hour in your neighbourhood.',
  durationMinutes: 90,
  price: '180.00',
  currency: 'EUR',
  includedPhotos: 15,
  entryRate: '180.00',
  minimumPhotos: 15,
  // Not 180 x 15: portraits decay past the tenth photo, so the server's
  // figure is lower than the multiplication.
  startingTotal: '2405.88',
  extraPhotoPrice: '7.00',
  proofsSlaDays: 3,
  finalsSlaDays: 7,
);

/// A time picked on the profile's calendar: 10:00 in Lisbon, 09:00Z.
final _pick = PickedStart(
  day: DateTime.utc(2030, 6, 12),
  start: ClientAvailabilityStart(
    startAt: DateTime.parse('2030-06-12T10:00:00+01:00'),
    localTime: '10:00',
    endAt: DateTime.parse('2030-06-12T11:00:00+01:00'),
    localEndTime: '11:00',
  ),
  timezone: 'Europe/Lisbon',
);

/// Availability with nothing open, for a sheet opened without a time - its
/// calendar has to load from somewhere.
Dio _emptyCalendar() => Dio(BaseOptions(baseUrl: 'https://example.invalid'))
  ..httpClientAdapter = FakeHttpClientAdapter(
    (o) async => jsonResponseBody(
      jsonEncode({'timezone': 'Europe/Lisbon', 'has_schedule': true, 'notice_hours': 24, 'days': <Object>[]}),
      200,
    ),
  );

/// Opens the sheet from a host screen, the way the profile does - with a time
/// already picked on its calendar unless [pick] is null.
Widget _host(_FakeRequests fake, {void Function(String?)? onClosed, PickedStart? pick}) => ProviderScope(
      overrides: [
        bookingRequestControllerProvider.overrideWith(() => fake),
        clientLaunchClientProvider.overrideWithValue(ClientLaunchClient(_emptyCalendar())),
      ],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showBookingRequestSheet(
                    context,
                    proUserId: 'pro-1',
                    proName: 'Alex Lens',
                    package: _package,
                    defaultLocation: 'New York',
                    initialPick: pick,
                  );
                  onClosed?.call(result);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opened without a time, it asks through the calendar and will not send without one', (tester) async {
    final fake = _FakeRequests(const BookingRequestSent('booking-1'));
    await tester.pumpWidget(_host(fake));
    await _openSheet(tester);

    // The real availability, not a bare date picker the server would refuse.
    expect(find.byType(AvailabilityCalendar), findsOneWidget);
    expect(find.byType(DatePickerDialog), findsNothing);

    await tester.ensureVisible(find.text('Send request'));
    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a start time.'), findsOneWidget);
    // Nothing reached the API - an incomplete request is caught here, not by
    // a 422 the person has to interpret.
    expect(fake.sentStart, isNull);
  });

  testWidgets('states the package, price and who it is for', (tester) async {
    await tester.pumpWidget(_host(_FakeRequests(const BookingRequestSent('b')), pick: _pick));
    await _openSheet(tester);

    expect(find.text('Request Portrait session'), findsOneWidget);
    expect(find.textContaining('Alex Lens'), findsWidgets);
    expect(find.textContaining('€180.00'), findsOneWidget);
    expect(find.textContaining('1 hour 30 min'), findsOneWidget);
  });

  testWidgets('sets the expectation before the request goes out', (tester) async {
    await tester.pumpWidget(_host(_FakeRequests(const BookingRequestSent('b')), pick: _pick));
    await _openSheet(tester);

    // 24, matching the backend's expires_at. Saying 48 would cost someone
    // the booking they are about to request.
    expect(find.textContaining('24 hours to reply'), findsOneWidget);
    expect(find.textContaining('only pay once they accept'), findsOneWidget);
  });

  testWidgets('prefills where the photographer works', (tester) async {
    await tester.pumpWidget(_host(_FakeRequests(const BookingRequestSent('b')), pick: _pick));
    await _openSheet(tester);

    expect(find.text('New York'), findsOneWidget);
  });

  testWidgets('derives the end time from the package rather than asking', (tester) async {
    final fake = _FakeRequests(const BookingRequestSent('booking-1'));
    String? closedWith;
    await tester.pumpWidget(_host(fake, onClosed: (id) => closedWith = id, pick: _pick));
    await _openSheet(tester);

    // The picked time, stated in the photographer's own time - not asked again.
    expect(find.text('Wed 12 Jun at 10:00'), findsOneWidget);
    expect(find.textContaining('Lisbon time · ends around 11:30'), findsOneWidget);

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    // The instant the server offered, unchanged by the phone's time zone.
    expect(fake.sentStart, DateTime.utc(2030, 6, 12, 9));
    expect(fake.sentEnd!.difference(fake.sentStart!), const Duration(minutes: 90));
    // The niche the booking endpoint validates against the package comes from
    // the package itself, so the two can never disagree.
    expect(fake.sentNiche, 'portraits');
    expect(closedWith, 'booking-1');
    // The conversion to UTC happens a layer down, in the controller - see
    // booking_request_controller_test.dart, which asserts the wire payload.
  });

  testWidgets('a rejected request keeps the sheet and the form open', (tester) async {
    final fake = _FakeRequests(const BookingRequestFailed('That time clashes with another booking.'));
    String? closedWith = 'not-called';
    await tester.pumpWidget(_host(fake, onClosed: (id) => closedWith = id, pick: _pick));
    await _openSheet(tester);

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(find.text('That time clashes with another booking.'), findsOneWidget);
    // Still open, with the time still chosen - a failed send must not throw
    // away what the person already entered.
    expect(find.text('Send request'), findsOneWidget);
    expect(find.text('Wed 12 Jun at 10:00'), findsOneWidget);
    expect(closedWith, 'not-called');
  });

  testWidgets('"Change time" goes back to the calendar rather than a date picker', (tester) async {
    await tester.pumpWidget(_host(_FakeRequests(const BookingRequestSent('b')), pick: _pick));
    await _openSheet(tester);

    await tester.tap(find.text('Change time'));
    await tester.pumpAndSettle();

    expect(find.byType(AvailabilityCalendar), findsOneWidget);
    expect(find.text('Wed 12 Jun at 10:00'), findsNothing);
  });
}
