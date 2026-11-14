// Multi-currency M2: the Wallet speaks the photographer's own currency, and
// its minimum is the server's, per currency (docs/MULTI_CURRENCY.md 6.2).
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/features/client/credit/credit_labels.dart';

import 'you_tab_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a pound photographer\'s minimum and refusal are in pounds', () {
    final data = wallet(withdrawable: '44.99', currency: 'GBP', payoutMinimum: '45.00');
    expect(data.currency, 'GBP');
    expect(data.minimum, Decimal.parse('45.00'));
    final money = RMoney.forLocale(const Locale('en', 'GB'));
    expect(money.format(data.minimum.toStringAsFixed(2), currency: data.currency), '£45.00');
    expect(data.payoutBlockedReason, contains('£45.00'));
    expect(data.payoutBlockedReason, isNot(contains('€')));
  });

  test('at the pound minimum a payout can be asked for', () {
    expect(wallet(withdrawable: '45.00', currency: 'GBP', payoutMinimum: '45.00').payoutBlockedReason, isNull);
  });

  test('a euro photographer keeps the euro minimum', () {
    final data = wallet(withdrawable: '49.99');
    expect(data.minimum, Decimal.parse('50.00'));
    expect(data.payoutBlockedReason, contains('€50.00'));
  });

  test('credit says its own currency', () {
    expect(creditAmount('5.00', currency: 'EUR'), '€5.00');
    expect(signedCreditAmount('-5.00', currency: 'GBP'), '−£5.00');
  });
}
