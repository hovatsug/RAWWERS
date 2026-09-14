import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/invoice_summary_view.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/wallet/earnings_summary_card.dart';
import 'package:rawwers/features/pro/wallet/summary_controller.dart';

/// The all-time totals above the Wallet's ledger.
///
/// Every figure is the server's. These cover what the card must refuse to
/// claim when it has nothing to report.

InvoiceSummaryView _summary({
  int bookings = 57,
  String gross = '48298.80',
  String platformFees = '9659.76',
  String proRaww = '2414.94',
  String clientRaww = '0.00',
  String proCash = '38639.04',
  String? averageGross = '847.35',
  int reconstructed = 0,
}) =>
    InvoiceSummaryView(
      bookings: bookings,
      gross: gross,
      platformFees: platformFees,
      proRaww: proRaww,
      clientRaww: clientRaww,
      proCash: proCash,
      averageGross: averageGross,
      reconstructed: reconstructed,
    );

Widget _wrap(InvoiceSummaryView summary) => ProviderScope(
      overrides: [earningsSummaryProvider.overrideWith((ref) async => summary)],
      child: MaterialApp(
        theme: buildProTheme(),
        home: const Scaffold(body: SingleChildScrollView(child: EarningsSummaryCard())),
      ),
    );

void main() {
  testWidgets('shows every total the server sent', (tester) async {
    await tester.pumpWidget(_wrap(_summary()));
    await tester.pumpAndSettle();

    expect(find.textContaining('48298.80'), findsOneWidget);
    expect(find.textContaining('9659.76'), findsOneWidget);
    expect(find.textContaining('2414.94'), findsOneWidget);
    expect(find.textContaining('38639.04'), findsOneWidget);
    expect(find.textContaining('57 completed bookings'), findsOneWidget);
  });

  testWidgets('a photographer with no completed work sees no summary at all', (tester) async {
    // Not a card of zeroes. Every line reading 0.00 states that they have
    // earned nothing and paid nothing, which is a claim rather than an
    // absence - the same distinction the Wallet balance already respects.
    await tester.pumpWidget(_wrap(_summary(
      bookings: 0,
      gross: '0.00',
      platformFees: '0.00',
      proRaww: '0.00',
      proCash: '0.00',
      averageGross: null,
    )));
    await tester.pumpAndSettle();

    expect(find.text('All time'), findsNothing, reason: 'a summary of nothing was rendered as zeroes');
  });

  testWidgets('no given-away line when they have given none', (tester) async {
    // Absence rather than "Given to clients: 0.00", which reads as a remark
    // about the photographer rather than a line that does not apply.
    await tester.pumpWidget(_wrap(_summary(clientRaww: '0.00')));
    await tester.pumpAndSettle();
    expect(find.text('Given to clients'), findsNothing);
  });

  testWidgets('the given-away line appears once they have', (tester) async {
    await tester.pumpWidget(_wrap(_summary(clientRaww: '1204.50')));
    await tester.pumpAndSettle();

    expect(find.text('Given to clients'), findsOneWidget);
    expect(find.textContaining('1204.50'), findsOneWidget);
  });

  testWidgets('totals built from reconstructed rates say how many', (tester) async {
    await tester.pumpWidget(_wrap(_summary(reconstructed: 57)));
    await tester.pumpAndSettle();
    expect(find.textContaining('57 of these predate itemised rates'), findsOneWidget);
  });

  testWidgets('fully recorded totals carry no disclaimer', (tester) async {
    await tester.pumpWidget(_wrap(_summary(reconstructed: 0)));
    await tester.pumpAndSettle();
    expect(find.textContaining('predate itemised rates'), findsNothing);
  });
}
