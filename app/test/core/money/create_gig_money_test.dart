import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/money/create_gig_money.dart';

void main() {
  test('createGigRequest serializes amountTotal as a string, not a number', () {
    final request = createGigRequest(
      proUserId: 'user-1',
      amountTotal: Decimal.parse('420.00'),
    );
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['amount_total'], isA<String>());
    expect(payload['amount_total'], '420.00');
  });
}
