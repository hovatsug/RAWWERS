import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_booking_list_item.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/paging/cursor_page.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/bookings/bookings_controller.dart';
import 'package:rawwers/features/client/bookings/bookings_screen.dart';

class _FakeBookings extends BookingsController {
  _FakeBookings(this._page);

  final CursorPage<ClientBookingListItem> _page;

  @override
  Future<CursorPage<ClientBookingListItem>> build() async => _page;
}

class _FailingBookings extends BookingsController {
  @override
  Future<CursorPage<ClientBookingListItem>> build() async => throw const NetworkError();
}

ClientBookingListItem _booking({
  String id = 'booking-1',
  String bookingStatus = 'accepted',
  String? gigStatus = 'payment_pending',
}) {
  // A fixed UTC instant so the rendered window is deterministic wherever the
  // suite runs; the assertions convert the same way the screen does.
  final start = DateTime.utc(2026, 9, 12, 14);
  return ClientBookingListItem(
    bookingId: id,
    bookingStatus: bookingStatus,
    gigStatus: gigStatus,
    requestedStart: start,
    requestedEnd: start.add(const Duration(hours: 2)),
    locationText: 'Lisbon, Alfama',
    expiresAt: start,
    createdAt: start,
  );
}

Widget _wrap(Override override) => ProviderScope(
      overrides: [override],
      child: MaterialApp(theme: buildClientTheme(), home: const BookingsScreen()),
    );

void main() {
  testWidgets('shows what a booking is waiting on, not just its raw status', (tester) async {
    await tester.pumpWidget(
      _wrap(bookingsControllerProvider.overrideWith(() => _FakeBookings(CursorPage(items: [_booking()])))),
    );
    await tester.pump();

    expect(find.text('Payment due'), findsOneWidget);
    expect(find.text('Lisbon, Alfama'), findsOneWidget);
    expect(find.textContaining('Pay to confirm the date'), findsOneWidget);
  });

  testWidgets('renders the shoot window in local time', (tester) async {
    await tester.pumpWidget(
      _wrap(bookingsControllerProvider.overrideWith(() => _FakeBookings(CursorPage(items: [_booking()])))),
    );
    await tester.pump();

    final expected = formatBookingWindow(
      DateTime.utc(2026, 9, 12, 14),
      DateTime.utc(2026, 9, 12, 16),
    );
    expect(find.text(expected), findsOneWidget);
    // The UTC hour must not be what reaches the screen unless the device is
    // on UTC - a client reading 14:00 for a 15:00 Lisbon shoot misses it.
    expect(expected.contains('–'), isTrue);
  });

  testWidgets('a booking still waiting on the pro offers no payment', (tester) async {
    await tester.pumpWidget(
      _wrap(
        bookingsControllerProvider.overrideWith(
          () => _FakeBookings(CursorPage(items: [_booking(bookingStatus: 'pending', gigStatus: null)])),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Waiting on the photographer'), findsOneWidget);
    expect(find.textContaining('Pay to confirm the date'), findsNothing);
  });

  testWidgets('an empty list explains how bookings start', (tester) async {
    await tester.pumpWidget(
      _wrap(bookingsControllerProvider.overrideWith(() => _FakeBookings(const CursorPage(items: [])))),
    );
    await tester.pump();

    expect(find.text('No bookings yet'), findsOneWidget);
    expect(find.textContaining('24 hours'), findsOneWidget);
  });

  testWidgets('a failed load is retryable rather than empty', (tester) async {
    await tester.pumpWidget(_wrap(bookingsControllerProvider.overrideWith(_FailingBookings.new)));
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('No bookings yet'), findsNothing);
  });
}
