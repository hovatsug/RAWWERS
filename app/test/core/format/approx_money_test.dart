import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/format/approx_money.dart';
import 'package:rawwers/core/format/money.dart';

/// The design's fixtures (docs/MULTI_CURRENCY.md 7.2), at 1 EUR = 0.85123 GBP.
void main() {
  final rates = FxRates(base: 'EUR', rates: {'GBP': Decimal.parse('0.85123')});
  final money = RMoney.forLocale(const Locale('en', 'GB'));

  test('euros to pounds: the minor units, rounded half up once', () {
    expect(approxMinor('1000.00', 'EUR', 'GBP', rates), 85123);
    expect(approxMinor('12.34', 'EUR', 'GBP', rates), 1050); // 1050.42
    expect(approxMinor('850.00', 'GBP', 'EUR', rates), 99856); // 99855.503 (the design's 99855.27 is a slip)
  });

  test('at the half it rounds up', () {
    final half = FxRates(base: 'EUR', rates: {'GBP': Decimal.parse('0.85')});
    expect(approxMinor('0.10', 'EUR', 'GBP', half), 9); // 8.5
  });

  test('shown to the whole unit from 20 up, to the penny below', () {
    expect(approxOf('1000.00', 'EUR', 'GBP', rates, money), 'about £851');
    expect(approxOf('12.34', 'EUR', 'GBP', rates, money), 'about £10.50');
    expect(approxOf('850.00', 'GBP', 'EUR', rates, money), 'about €999');
  });

  test('the labels, GBP first', () {
    expect(shortLabel('1000.00', 'GBP', 'EUR', rates, money), 'about €1,175 · charged in £1,000.00');
    expect(
      beforePaying('1000.00', 'EUR', 'GBP', rates, money),
      "You'll be charged €1,000.00 (EUR). About £851 at today's rate. Your bank or card sets the final amount.",
    );
  });

  test('no rate (stale or missing): no approximation, only the charged currency', () {
    expect(approxOf('1000.00', 'EUR', 'GBP', FxRates.none, money), isNull);
    expect(shortLabel('1000.00', 'EUR', 'GBP', FxRates.none, money), 'Charged in EUR');
    expect(beforePaying('1000.00', 'EUR', 'GBP', FxRates.none, money), 'Charged in EUR');
  });

  test('the same currency: nothing to add', () {
    expect(shortLabel('1000.00', 'GBP', 'GBP', rates, money), isNull);
    expect(beforePaying('1000.00', 'GBP', 'GBP', rates, money), isNull);
  });

  test('the request sheet names both currencies', () {
    expect(requestCurrencyNote('EUR', 'GBP'), "You'll be charged in euros (EUR). Your bank sets the final amount in pounds.");
    expect(requestCurrencyNote('GBP', 'GBP'), isNull);
  });
}
