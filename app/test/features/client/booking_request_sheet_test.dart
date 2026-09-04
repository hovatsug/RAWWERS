import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/booking_request/booking_request_controller.dart';
import 'package:rawwers/features/client/booking_request/booking_request_sheet.dart';

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
  extraPhotoPrice: '7.00',
  proofsSlaDays: 3,
  finalsSlaDays: 7,
);

/// Opens the sheet from a host screen, the way the profile does.
Widget _host(_FakeRequests fake, {void Function(String?)? onClosed}) => ProviderScope(
      overrides: [bookingRequestControllerProvider.overrideWith(() => fake)],
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

/// Drives the Material date picker to the given day of the current month.
Future<void> _pickDay(WidgetTester tester, String day) async {
  await tester.tap(find.text('Date'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(day).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('will not send without a date and time', (tester) async {
    final fake = _FakeRequests(const BookingRequestSent('booking-1'));
    await tester.pumpWidget(_host(fake));
    await _openSheet(tester);

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a date and a start time.'), findsOneWidget);
    // Nothing reached the API - an incomplete request is caught here, not by
    // a 422 the person has to interpret.
    expect(fake.sentStart, isNull);
  });

  testWidgets('states the package, price and who it is for', (tester) async {
    await tester.pumpWidget(_host(_FakeRequests(const BookingRequestSent('b'))));
    await _openSheet(tester);

    expect(find.text('Request Portrait session'), findsOneWidget);
    expect(find.textContaining('Alex Lens'), findsWidgets);
    expect(find.textContaining('€180.00'), findsOneWidget);
    expect(find.textContaining('1 hour 30 min'), findsOneWidget);
  });

  testWidgets('sets the expectation before the request goes out', (tester) async {
    await tester.pumpWidget(_host(_FakeRequests(const BookingRequestSent('b'))));
    await _openSheet(tester);

    // 24, matching the backend's expires_at. Saying 48 would cost someone
    // the booking they are about to request.
    expect(find.textContaining('24 hours to reply'), findsOneWidget);
    expect(find.textContaining('only pay once they accept'), findsOneWidget);
  });

  testWidgets('prefills where the photographer works', (tester) async {
    await tester.pumpWidget(_host(_FakeRequests(const BookingRequestSent('b'))));
    await _openSheet(tester);

    expect(find.text('New York'), findsOneWidget);
  });

  testWidgets('derives the end time from the package rather than asking', (tester) async {
    final fake = _FakeRequests(const BookingRequestSent('booking-1'));
    String? closedWith;
    await tester.pumpWidget(_host(fake, onClosed: (id) => closedWith = id));
    await _openSheet(tester);

    await _pickDay(tester, '15');
    // The time picker defaults to 14:00 and its dial is not drivable here, so
    // the assertion is on the relationship between start and end, which is
    // the part the form is responsible for.
    await tester.tap(find.text('Start time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(fake.sentStart, isNotNull);
    expect(fake.sentEnd!.difference(fake.sentStart!), const Duration(minutes: 90));
    // The niche the booking endpoint validates against the package comes from
    // the package itself, so the two can never disagree.
    expect(fake.sentNiche, 'portraits');
    expect(closedWith, 'booking-1');
    // The conversion to UTC happens a layer down, in the controller - see
    // booking_request_controller_test.dart, which asserts the wire payload.
  });

  testWidgets('a rejected request keeps the sheet and the form open', (tester) async {
    final fake = _FakeRequests(const BookingRequestFailed('This photographer has not opened their calendar yet.'));
    String? closedWith = 'not-called';
    await tester.pumpWidget(_host(fake, onClosed: (id) => closedWith = id));
    await _openSheet(tester);

    await _pickDay(tester, '15');
    await tester.tap(find.text('Start time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(find.text('This photographer has not opened their calendar yet.'), findsOneWidget);
    // Still open, with the date still chosen - a failed send must not throw
    // away what the person already entered.
    expect(find.text('Send request'), findsOneWidget);
    expect(closedWith, 'not-called');
  });
}
