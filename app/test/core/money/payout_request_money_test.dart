import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/money/payout_request_money.dart';

void main() {
  test('createPayoutRequest serializes amountEur as a string, not a number', () {
    final request = createPayoutRequest(amountEur: Decimal.parse('89.10'));
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['amount_eur'], isA<String>());
    expect(payload['amount_eur'], '89.10');
  });
}
