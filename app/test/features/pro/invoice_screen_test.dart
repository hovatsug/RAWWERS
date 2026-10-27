import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gig_invoice_view.dart';
import 'package:rawwers/design/components/r_amount_row.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/wallet/invoice_controller.dart';
import 'package:rawwers/features/pro/wallet/invoice_screen.dart';

/// One gig's invoice.
///
/// Every figure here is the server's. These assert the screen renders what it
/// was given and invents nothing - particularly the two places where showing
/// a plausible number would be worse than showing none.

const _gigId = 'gig-1';

GigInvoiceView _invoice({
  int clientCreditPercent = 0,
  String clientRaww = '0.00',
  String proCash = '1192.00',
  int? photosDelivered,
  bool ratesWereStamped = true,
  String vatStatus = 'not_answered',
  int? vatRatePercent,
  String? vatNumber,
  String? vatNetAmount,
  String? vatAmount,
}) =>
    GigInvoiceView(
      gigId: _gigId,
      issuedAt: DateTime.utc(2026, 3, 5, 14),
      currency: 'EUR',
      clientTotal: '1490.00',
      platformRetained: '223.50',
      proRaww: '74.50',
      clientRaww: clientRaww,
      proCash: proCash,
      retainedPercent: 15,
      proRawwPercent: 5,
      clientCreditPercent: clientCreditPercent,
      photosDelivered: photosDelivered,
      ratesWereStamped: ratesWereStamped,
      vatStatus: vatStatus,
      vatRatePercent: vatRatePercent,
      vatNumber: vatNumber,
      vatNetAmount: vatNetAmount,
      vatAmount: vatAmount,
    );

Widget _wrap(GigInvoiceView invoice) => ProviderScope(
      overrides: [
        invoiceProvider(gigId: _gigId).overrideWith((ref) async => invoice),
      ],
      child: MaterialApp(
        theme: buildProTheme(),
        home: const InvoiceScreen(gigId: _gigId),
      ),
    );

void main() {
  testWidgets('every line the server sent is shown', (tester) async {
    await tester.pumpWidget(_wrap(_invoice()));
    await tester.pumpAndSettle();

    // The client total twice: the headline, and the first row of the sum.
    expect(find.textContaining('1,490.00'), findsNWidgets(2));
    // The platform's whole fee (retained 223.50 + RAWW credit 74.50), as the
    // Wallet's "Platform fees" counts it, and the credit on its own below.
    expect(find.textContaining('298.00'), findsOneWidget);
    expect(find.textContaining('20% of the booking'), findsOneWidget);
    expect(find.textContaining('74.50'), findsOneWidget);
    expect(find.textContaining('1,192.00'), findsOneWidget);
  });

  testWidgets('the RAWW credit sits below Your cash, outside the sum, and says it is not cash', (tester) async {
    await tester.pumpWidget(_wrap(_invoice()));
    await tester.pumpAndSettle();

    final cash = tester.getTopLeft(find.text('Your cash')).dy;
    final credit = tester.getTopLeft(find.text('Your RAWW credit')).dy;
    final divider = tester.getTopLeft(find.byType(Divider).first).dy;
    expect(credit, greaterThan(cash), reason: 'the credit is not cash: it must not sit inside the sum');
    expect(cash, greaterThan(divider));
    expect(find.textContaining('Gear credit, part of the platform fee. Not withdrawable.'), findsOneWidget);
    expect(tester.widget<RAmountRow>(find.widgetWithText(RAmountRow, 'Your RAWW credit')).amount, isNot(startsWith('-')));
  });

  testWidgets('no RAWW credit row when the booking earned none', (tester) async {
    await tester.pumpWidget(_wrap(GigInvoiceView.fromJson({..._json(_invoice()), 'pro_raww': '0.00', 'pro_raww_percent': 0})));
    await tester.pumpAndSettle();
    expect(find.text('Your RAWW credit'), findsNothing);
  });

  // The rows a photographer can see in the money card must add up: the
  // booking, less the platform's fee and any credit given to the client, is
  // Your cash - read back off the screen, as written for the device's
  // locale. The scenarios are the server's own split
  // (test/fixtures/invoice_scenarios.json, from split_with_rates), so they
  // are the arithmetic the real invoice is given.
  final scenarios = (jsonDecode(File('test/fixtures/invoice_scenarios.json').readAsStringSync())
      as Map<String, dynamic>)['scenarios'] as List<dynamic>;
  for (final locale in const [Locale('en', 'GB'), Locale('pt', 'PT')]) {
    for (final raw in scenarios.cast<Map<String, dynamic>>()) {
      testWidgets('the visible rows sum to Your cash: ${raw['name']}, $locale', (tester) async {
        tester.platformDispatcher.localeTestValue = locale;
        addTearDown(tester.platformDispatcher.clearLocaleTestValue);
        await tester.pumpWidget(_wrap(GigInvoiceView.fromJson({..._json(_invoice()), ...raw})));
        await tester.pumpAndSettle();

        final rows = {
          for (final row in tester.widgetList<RAmountRow>(
            find.descendant(of: find.byType(RCard).first, matching: find.byType(RAmountRow)),
          ))
            row.label: _readBack(row.amount, locale),
        };
        final inTheSum = ['Booked', 'Platform fee', if (rows.containsKey('Credit to your client')) 'Credit to your client'];
        final sum = inTheSum.map((label) => rows[label]!).reduce((a, b) => a + b);
        expect(sum, rows['Your cash'], reason: 'shown: $rows');
        expect(rows['Your cash'], Decimal.parse(raw['pro_cash'] as String));
        expect(rows.containsKey('Credit to your client'), raw['client_credit_percent'] != 0);
        expect(rows.containsKey('Your RAWW credit'), raw['pro_raww_percent'] != 0);
        if (rows.containsKey('Your RAWW credit')) {
          expect(rows['Your RAWW credit'], Decimal.parse(raw['pro_raww'] as String));
        }
      });
    }
  }

  testWidgets('an unrecorded photo count says so instead of showing zero', (tester) async {
    // A completed gig with no submitted selection has an unknown count.
    // Printing 0 would tell a photographer they delivered nothing.
    await tester.pumpWidget(_wrap(_invoice(photosDelivered: null)));
    await tester.pumpAndSettle();

    expect(find.text('Not recorded'), findsOneWidget);
    expect(find.text('0'), findsNothing, reason: 'an unknown photo count rendered as zero');
  });

  testWidgets('a real photo count is shown as itself', (tester) async {
    await tester.pumpWidget(_wrap(_invoice(photosDelivered: 34)));
    await tester.pumpAndSettle();
    expect(find.text('34'), findsOneWidget);
  });

  testWidgets('no client credit line when the photographer gave none', (tester) async {
    // Absence, not a zero line. "Credit to your client: 0.00" reads as a
    // statement about the photographer rather than a line that does not apply.
    await tester.pumpWidget(_wrap(_invoice(clientCreditPercent: 0)));
    await tester.pumpAndSettle();
    expect(find.text('Credit to your client'), findsNothing);
  });

  testWidgets('the client credit line appears when there was one', (tester) async {
    await tester.pumpWidget(
      _wrap(_invoice(clientCreditPercent: 10, clientRaww: '149.00', proCash: '1043.00')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Credit to your client'), findsOneWidget);
    expect(find.textContaining('149.00'), findsOneWidget);
  });

  testWidgets('a reconstructed split is labelled as one', (tester) async {
    _tall(tester);
    // Gigs predating the stamped rates have their split rebuilt from current
    // rates. That is a fair fallback and a bad thing to present as a record.
    await tester.pumpWidget(_wrap(_invoice(ratesWereStamped: false)));
    await tester.pumpAndSettle();

    expect(find.textContaining('predates itemised rates'), findsOneWidget);
  });

  testWidgets('a recorded split carries no such disclaimer', (tester) async {
    _tall(tester);
    await tester.pumpWidget(_wrap(_invoice(ratesWereStamped: true)));
    await tester.pumpAndSettle();
    expect(find.textContaining('predates itemised rates'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // VAT.
  // -------------------------------------------------------------------------

  testWidgets('a registered photographer sees VAT broken out of the total', (tester) async {
    await tester.pumpWidget(_wrap(_invoice(
      vatStatus: 'registered',
      vatRatePercent: 20,
      vatNumber: 'GB123456789',
      vatNetAmount: '1241.67',
      vatAmount: '248.33',
    )));
    await tester.pumpAndSettle();

    expect(find.text('Before VAT'), findsOneWidget);
    expect(find.textContaining('1,241.67'), findsOneWidget);
    expect(find.textContaining('248.33'), findsOneWidget);
    expect(find.textContaining('GB123456789'), findsOneWidget);
  });

  testWidgets('an unregistered photographer is told why there is no VAT', (tester) async {
    // Not a missing line. Silence reads as an oversight; this states a fact.
    await tester.pumpWidget(_wrap(_invoice(vatStatus: 'not_registered')));
    await tester.pumpAndSettle();

    expect(find.textContaining('not VAT registered'), findsOneWidget);
    expect(find.text('Before VAT'), findsNothing);
  });

  testWidgets('someone who has never been asked is not called unregistered', (tester) async {
    await tester.pumpWidget(_wrap(_invoice(vatStatus: 'not_answered')));
    await tester.pumpAndSettle();

    expect(find.textContaining('have not told us'), findsOneWidget);
    expect(
      find.textContaining('not VAT registered'),
      findsNothing,
      reason: 'silence was rendered as a declaration',
    );
  });

  testWidgets("RAWWERS' own VAT on its fee never shows a number", (tester) async {
    // It depends on where the company incorporates, which is undecided. This
    // fails the moment any figure appears in that line.
    await tester.pumpWidget(_wrap(_invoice(
      vatStatus: 'registered',
      vatRatePercent: 20,
      vatNumber: 'GB123456789',
      vatNetAmount: '1241.67',
      vatAmount: '248.33',
    )));
    await tester.pumpAndSettle();

    expect(find.text('Not yet determined'), findsOneWidget);

    final row = find.ancestor(
      of: find.text("RAWWERS' VAT on its fee"),
      matching: find.byType(Row),
    );
    final texts = tester
        .widgetList<Text>(find.descendant(of: row.first, matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .toList();
    expect(
      texts.any((t) => RegExp(r'\d').hasMatch(t)),
      isFalse,
      reason: 'a number appeared in the platform commission VAT line: $texts',
    );
  });
}

Map<String, dynamic> _json(GigInvoiceView invoice) => jsonDecode(jsonEncode(invoice.toJson())) as Map<String, dynamic>;

/// An amount as the screen wrote it, back to a number.
Decimal _readBack(String shown, Locale locale) {
  final pt = locale.languageCode == 'pt';
  final digits = shown.replaceAll(RegExp(pt ? r'[^0-9,\-]' : r'[^0-9.\-]'), '');
  return Decimal.parse(pt ? digits.replaceAll(',', '.') : digits);
}

/// A viewport the whole invoice fits in, so a line at the end is built (and
/// its absence means something).
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}
