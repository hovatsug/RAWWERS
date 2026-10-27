// Every amount in the pro app goes through RMoney: the device locale decides
// how the number is written, the server's currency what it is in.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/format/money.dart';

const _nbsp = ' ';

void main() {
  group('en-GB', () {
    final m = RMoney.forLocale(const Locale('en', 'GB'));
    test('groups thousands', () => expect(m.format('1350.00'), '€1,350.00'));
    test('and millions', () => expect(m.format('1234567.89'), '€1,234,567.89'));
    test('a small amount has no separator', () => expect(m.format('12.00'), '€12.00'));
    test('a negative amount', () => expect(m.format('-23.10'), '-€23.10'));
    test('taking an amount off', () => expect(m.minus('462.00'), '-€462.00'));
    test('taking nothing off is not negative', () => expect(m.minus('0.00'), '€0.00'));
    test('a whole number keeps no cents', () => expect(m.format('1000'), '€1,000'));
    test('another currency with a symbol', () => expect(m.format('1350.00', currency: 'GBP'), '£1,350.00'));
    test('a currency with no symbol is named', () => expect(m.format('12.00', currency: 'CHF'), 'CHF${_nbsp}12.00'));
    test('no currency sent is EUR', () => expect(m.format('12.00', currency: null), '€12.00'));
  });

  group('pt-PT', () {
    final m = RMoney.forLocale(const Locale('pt', 'PT'));
    test('groups with a space and a decimal comma, symbol after', () => expect(m.format('1350.00'), '1${_nbsp}350,00$_nbsp€'));
    test('and millions', () => expect(m.format('1234567.89'), '1${_nbsp}234${_nbsp}567,89$_nbsp€'));
    test('a negative amount', () => expect(m.format('-23.10'), '-23,10$_nbsp€'));
    test('another currency', () => expect(m.format('12.00', currency: 'CHF'), '12,00${_nbsp}CHF'));
    test('pt with no country is the same', () => expect(RMoney.forLocale(const Locale('pt')).format('1350.00'), '1${_nbsp}350,00$_nbsp€'));
  });

  group('en-US', () {
    final m = RMoney.forLocale(const Locale('en', 'US'));
    test('groups like en-GB', () => expect(m.format('1234567.89'), '€1,234,567.89'));
    test('dollars when the server says dollars', () => expect(m.format('1350.00', currency: 'USD'), r'$1,350.00'));
    test('a negative amount', () => expect(m.format('-1350.00', currency: 'USD'), r'-$1,350.00'));
  });

  test('never rounds or reformats the server\'s digits', () {
    final m = RMoney.forLocale(const Locale('en', 'GB'));
    expect(m.format('0.10'), '€0.10');
    expect(m.format('999999999999.99'), '€999,999,999,999.99');
  });

  testWidgets('RMoney.of reads the device locale', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('pt', 'PT');
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    late String shown;
    await tester.pumpWidget(Builder(builder: (context) {
      shown = RMoney.of(context).format('1350.00');
      return const SizedBox();
    }));
    expect(shown, '1${_nbsp}350,00$_nbsp€');
  });
}
