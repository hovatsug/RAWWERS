// The door into the photographs.
//
// The backend decides whether there is one: it hands over a gallery id only
// for a gallery the client may actually open, and withholds it for a draft
// the photographer is still filling. So the rule this screen has to keep is
// narrow and absolute - offer the door when there is an id, and never
// otherwise. Offering it without one is how you build a button that leads to
// a 403 on the screen a paying client trusts most.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_detail_screen.dart';

ClientBookingStatusResponse _booking({String? galleryId, String? galleryStatus}) {
  return ClientBookingStatusResponse(
    bookingId: 'b1',
    bookingStatus: 'accepted',
    gigId: 'gig-1',
    gigStatus: 'paid',
    paymentStatus: 'succeeded',
    proofGalleryId: galleryId,
    proofGalleryStatus: galleryStatus,
    timeline: const [],
    nextActions: const [],
  );
}

Future<void> _pump(WidgetTester tester, ClientBookingStatusResponse booking) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [bookingDetailProvider('b1').overrideWith((ref) async => booking)],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: const BookingDetailScreen(bookingId: 'b1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a published gallery offers choosing', (tester) async {
    await _pump(tester, _booking(galleryId: 'g1', galleryStatus: 'published'));
    expect(find.text('Your photos are ready'), findsOneWidget);
    expect(find.text('Choose your photos'), findsOneWidget);
  });

  testWidgets('an already-chosen selection offers viewing, not choosing', (tester) async {
    await _pump(tester, _booking(galleryId: 'g1', galleryStatus: 'selection_submitted'));
    expect(find.text('View your photos'), findsOneWidget);
    expect(find.text('Choose your photos'), findsNothing);
  });

  testWidgets('no gallery means no door', (tester) async {
    await _pump(tester, _booking());
    expect(find.textContaining('your photos', findRichText: true), findsNothing);
    expect(find.text('Choose your photos'), findsNothing);
    expect(find.text('View your photos'), findsNothing);
  });
}
