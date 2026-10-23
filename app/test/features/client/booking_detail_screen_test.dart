import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_booking_refund.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_detail_screen.dart';

const _bookingId = 'booking-1';

ClientBookingStatusResponse _booking({
  String bookingStatus = 'accepted',
  String? gigStatus = 'payment_pending',
  List<Map<String, dynamic>>? timeline,
  bool shortNotice = false,
  DateTime? payBy,
  DateTime? expiresAt,
  List<ClientBookingRefund> refunds = const [],
}) =>
    ClientBookingStatusResponse(
      bookingId: _bookingId,
      bookingStatus: bookingStatus,
      gigStatus: gigStatus,
      shortNotice: shortNotice,
      payBy: payBy,
      expiresAt: expiresAt,
      refunds: refunds,
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
    // Said before paying: the final price comes with the selection, and any
    // difference is refunded.
    expect(find.text(depositExplainer), findsOneWidget);
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

  group('a short-notice booking is checked again while it waits', () {
    // Each fetch returns the next answer in [answers], the last one repeating.
    Future<(List<int>, Widget)> wrapSequence(List<ClientBookingStatusResponse> answers) async {
      final fetches = [0];
      final widget = ProviderScope(
        overrides: [
          bookingDetailProvider(_bookingId).overrideWith((ref) async {
            final i = fetches[0]++;
            // A refresh takes a moment, as a real one does - long enough for
            // the screen to be drawn while it is under way.
            if (i > 0) await Future<void>.delayed(const Duration(seconds: 1));
            return answers[i < answers.length ? i : answers.length - 1];
          }),
        ],
        child: MaterialApp(theme: buildClientTheme(), home: const BookingDetailScreen(bookingId: _bookingId)),
      );
      return (fetches, widget);
    }

    final soon = DateTime.now().add(const Duration(minutes: 25));
    final waiting = _booking(bookingStatus: 'pending', gigStatus: null, shortNotice: true, expiresAt: soon);

    testWidgets('every 20 seconds while the photographer has not answered, without blanking the screen',
        (tester) async {
      final (fetches, widget) = await wrapSequence([waiting]);
      await tester.pumpWidget(widget);
      await tester.pump();
      expect(fetches[0], 1);

      await tester.pump(shortNoticeRefreshEvery);
      await tester.pump();
      expect(fetches[0], 2);
      expect(find.textContaining('has until'), findsOneWidget, reason: 'still on screen while it is checked again');
      await tester.pump(shortNoticeRefreshEvery);
      expect(fetches[0], 3);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('and stops once nothing is waiting on the short clock', (tester) async {
      final (fetches, widget) = await wrapSequence([waiting, _booking(gigStatus: 'paid', shortNotice: true)]);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(shortNoticeRefreshEvery);
      await tester.pump(const Duration(seconds: 1));
      expect(fetches[0], 2);
      expect(find.text('Paid'), findsOneWidget);

      await tester.pump(shortNoticeRefreshEvery * 5);
      expect(fetches[0], 2);
    });

    testWidgets('a check that fails leaves the booking on screen', (tester) async {
      final fetches = [0];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingDetailProvider(_bookingId).overrideWith((ref) async {
              if (fetches[0]++ > 0) throw Exception('dropped');
              return waiting;
            }),
          ],
          child: MaterialApp(theme: buildClientTheme(), home: const BookingDetailScreen(bookingId: _bookingId)),
        ),
      );
      await tester.pump();
      await tester.pump(shortNoticeRefreshEvery);
      await tester.pump();

      expect(fetches[0], 2);
      expect(find.textContaining('has until'), findsOneWidget);
    });

    testWidgets('an ordinary request is not polled', (tester) async {
      final (fetches, widget) = await wrapSequence([_booking(bookingStatus: 'pending', gigStatus: null, expiresAt: soon)]);
      await tester.pumpWidget(widget);
      await tester.pump();

      await tester.pump(shortNoticeRefreshEvery * 5);
      expect(fetches[0], 1);
    });
  });

  testWidgets('the pay panel names the time it is held until, not a fixed 24 hours', (tester) async {
    final payBy = DateTime.now().add(const Duration(minutes: 30));
    await tester.pumpWidget(_wrap(_booking(shortNotice: true, payBy: payBy)));
    await tester.pump();

    final element = tester.element(find.text('Pay to confirm'));
    final time = TimeOfDay.fromDateTime(payBy).format(element);
    expect(find.textContaining('holding this time for you until $time'), findsOneWidget);
    expect(find.textContaining('24 hours'), findsNothing);
  });

  testWidgets('a refund from a lower price shows as a refund, with why in plain words', (tester) async {
    await tester.pumpWidget(_wrap(_booking(
      gigStatus: 'completed',
      refunds: [
        ClientBookingRefund(
          amount: '27.31',
          currency: 'EUR',
          reasons: const [
            'Fewer photos were delivered than your package included.',
            'You chose fewer photos than your deposit covered.',
          ],
          at: DateTime.utc(2026, 9, 29),
        ),
      ],
    )));
    await tester.pump();

    expect(find.text('Refund of EUR 27.31'), findsOneWidget);
    expect(find.text('Fewer photos were delivered than your package included.'), findsOneWidget);
    expect(find.text('You chose fewer photos than your deposit covered.'), findsOneWidget);
  });
}
