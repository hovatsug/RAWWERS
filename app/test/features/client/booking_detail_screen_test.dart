import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_detail_screen.dart';

const _bookingId = 'booking-1';

ClientBookingStatusResponse _booking({
  String bookingStatus = 'accepted',
  String? gigStatus = 'payment_pending',
  List<Map<String, dynamic>>? timeline,
}) =>
    ClientBookingStatusResponse(
      bookingId: _bookingId,
      bookingStatus: bookingStatus,
      gigStatus: gigStatus,
      timeline: timeline ??
          [
            {'at': '2026-09-10T09:00:00+00:00', 'from': 'pending', 'to': 'accepted', 'reason': 'Pro accepted'},
          ],
    );

Widget _wrap(ClientBookingStatusResponse booking) => ProviderScope(
      overrides: [bookingDetailProvider(_bookingId).overrideWith((ref) async => booking)],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: const BookingDetailScreen(bookingId: _bookingId),
      ),
    );

void main() {
  testWidgets('offers payment when the gig is waiting for it', (tester) async {
    await tester.pumpWidget(_wrap(_booking()));
    await tester.pump();

    expect(find.text('Pay to confirm'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
  });

  testWidgets('does not offer payment on a booking already paid for', (tester) async {
    await tester.pumpWidget(_wrap(_booking(gigStatus: 'paid')));
    await tester.pump();

    expect(find.text('Pay now'), findsNothing);
    expect(find.text('Paid'), findsOneWidget);
  });

  testWidgets('renders the history the backend sent', (tester) async {
    await tester.pumpWidget(_wrap(_booking()));
    await tester.pump();

    expect(find.text('Accepted'), findsWidgets);
    expect(find.text('Pro accepted'), findsOneWidget);
  });

  testWidgets('drops timeline rows it cannot parse instead of rendering nulls', (tester) async {
    // `timeline` is `list[dict]` in the schema, so nothing guarantees these
    // keys. A row missing `at` or `to` has nothing to show and must not
    // reach the screen as an empty line or a crash.
    await tester.pumpWidget(
      _wrap(
        _booking(
          timeline: [
            {'to': 'accepted'},
            {'at': 'not-a-date', 'to': 'accepted'},
            {'at': '2026-09-10T09:00:00+00:00', 'to': 'accepted', 'reason': 'The only real one'},
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('The only real one'), findsOneWidget);
    expect(find.text('Nothing has happened yet.'), findsNothing);
  });

  testWidgets('a booking with no history says so', (tester) async {
    await tester.pumpWidget(_wrap(_booking(timeline: const [])));
    await tester.pump();

    expect(find.text('Nothing has happened yet.'), findsOneWidget);
  });
}
