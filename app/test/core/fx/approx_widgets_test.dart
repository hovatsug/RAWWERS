import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/display_currency_view.dart';
import 'package:rawwers/core/format/approx_money.dart';
import 'package:rawwers/core/fx/approx_widgets.dart';
import 'package:rawwers/core/fx/fx_controller.dart';

// docs/MULTI_CURRENCY.md 2.4 and 4.3: the approximation is a line beside the
// exact price, never the price; without a rate only "Charged in EUR".

final _rates = FxRates(base: 'EUR', rates: {'GBP': Decimal.parse('0.85123')});

class _Chosen extends DisplayCurrency {
  _Chosen(this.view);
  final DisplayCurrencyView? view;
  @override
  Future<DisplayCurrencyView?> build() async => view;
}

DisplayCurrencyView _view(String code, {List<String> available = const ['GBP', 'EUR']}) =>
    DisplayCurrencyView(displayCurrency: code, chosen: true, available: available);

Future<void> _pump(WidgetTester tester, Widget child, {FxRates? rates, DisplayCurrencyView? view}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fxRatesProvider.overrideWith((ref) async => rates ?? FxRates.none),
        displayCurrencyProvider.overrideWith(() => _Chosen(view)),
      ],
      child: MaterialApp(home: Scaffold(body: Column(children: [child]))),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a euro price shows about the pound amount for a pound reader', (tester) async {
    await _pump(tester, const ApproxLine(amount: '1000.00', currency: 'EUR'), rates: _rates);
    expect(find.text('about £851'), findsOneWidget);
  });

  testWidgets('without a rate the line says only where it is charged', (tester) async {
    await _pump(tester, const ApproxLine(amount: '1000.00', currency: 'EUR'));
    expect(find.text('Charged in EUR'), findsOneWidget);
    expect(find.textContaining('about'), findsNothing);
  });

  testWidgets('a price in the reader\'s own currency gets no line', (tester) async {
    await _pump(tester, const ApproxLine(amount: '1000.00', currency: 'EUR'), rates: _rates, view: _view('EUR'));
    expect(find.textContaining('about'), findsNothing);
    expect(find.textContaining('Charged in'), findsNothing);
  });

  testWidgets('before paying names the exact charge first and the approximation second', (tester) async {
    await _pump(tester, const BeforePayingLine(total: '1000.00', currency: 'EUR'), rates: _rates);
    expect(
      find.text("You'll be charged €1,000.00 (EUR). About £851 at today's rate. Your bank or card sets the final amount."),
      findsOneWidget,
    );
  });

  testWidgets('the display currency choice is hidden while only one currency is on', (tester) async {
    await _pump(tester, const DisplayCurrencyTile(), view: _view('GBP', available: const ['GBP']));
    expect(find.text('Display currency'), findsNothing);
  });

  testWidgets('the display currency choice is offered when two currencies are on', (tester) async {
    await _pump(tester, const DisplayCurrencyTile(), view: _view('GBP'));
    expect(find.text('Display currency'), findsOneWidget);
  });

  testWidgets('the request sheet says the charge currency in words', (tester) async {
    await _pump(tester, const RequestCurrencyNote(currency: 'EUR'));
    expect(
      find.text("You'll be charged in euros (EUR). Your bank sets the final amount in pounds."),
      findsOneWidget,
    );
  });
}
