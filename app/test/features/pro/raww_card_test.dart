import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_raww_view.dart';
import 'package:rawwers/api/models/raww_pending_booking.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/wallet/raww_card.dart';
import 'package:rawwers/features/pro/wallet/raww_controller.dart';

import '../../support/fake_raww.dart';

Widget _wrap(ProRawwView view) => ProviderScope(
      overrides: [rawwProvider.overrideWith((ref) async => view)],
      child: MaterialApp(theme: buildProTheme(), home: const Scaffold(body: SingleChildScrollView(child: RawwCard()))),
    );

void main() {
  testWidgets('shows nothing while The Shelf is closed', (tester) async {
    await tester.pumpWidget(_wrap(closedRaww));
    await tester.pump();

    expect(find.textContaining('RAWW'), findsNothing);
  });

  testWidgets('shows what can be spent, its worth, and what is on the way with dates', (tester) async {
    await tester.pumpWidget(_wrap(openRaww()));
    await tester.pump();

    expect(find.text('120 RAWW'), findsOneWidget);
    expect(find.textContaining('€12.00'), findsOneWidget);
    expect(find.text('75 RAWW on the way'), findsOneWidget);
    expect(find.text('50 RAWW from 10 Nov 2026'), findsOneWidget);
    expect(find.text('25 RAWW, on hold with its booking'), findsOneWidget);
  });

  testWidgets('a booking on hold never shows a date, whatever was sent', (tester) async {
    await tester.pumpWidget(_wrap(openRaww(pendingBookings: [
      RawwPendingBooking(gigId: 'g3', amount: 30, held: true, expectedAt: DateTime.utc(2026, 11, 12, 9)),
    ])));
    await tester.pump();

    expect(find.text('30 RAWW, on hold with its booking'), findsOneWidget);
  });

  testWidgets('always says when the spendable RAWW expire', (tester) async {
    await tester.pumpWidget(_wrap(openRaww(expiresAt: DateTime.utc(2028, 11, 3, 12))));
    await tester.pump();

    expect(find.textContaining('Expire on 3 Nov 2028'), findsOneWidget);
  });

  testWidgets('in the warning period the expiry is a banner that says what to do', (tester) async {
    await tester.pumpWidget(_wrap(openRaww(expiresAt: DateTime.utc(2026, 11, 20, 12), expiryWarning: true)));
    await tester.pump();

    final banner = find.text('Your RAWW expire on 20 Nov 2026. Earn or spend before then to keep them.');
    expect(banner, findsOneWidget);
    expect(find.ancestor(of: banner, matching: find.byType(Container)), findsWidgets);
  });

  testWidgets('a negative balance says why nothing can be spent, and shows no euro worth', (tester) async {
    await tester.pumpWidget(_wrap(openRaww(spendable: -40, pending: 0, pendingBookings: const [])));
    await tester.pump();

    expect(find.text('-40 RAWW'), findsOneWidget);
    expect(find.textContaining('Below zero after a refund'), findsOneWidget);
    expect(find.textContaining('Worth'), findsNothing);
  });

  test('the invoice amount shows RAWW beside the euros once they are sent', () {
    expect(rawwAmount(75, '€7.50'), '75 RAWW (€7.50)');
    expect(rawwAmount(null, '€7.50'), '€7.50');
  });
}
