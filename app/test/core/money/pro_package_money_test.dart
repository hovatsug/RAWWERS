import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/core/api_wrappers/pro_package_update.dart' show buildProPackageUpdateRequest;
import 'package:rawwers/core/money/pro_package_money.dart';

void main() {
  test('createProPackageRequest serializes price and extraPhotoPrice as strings, not numbers', () {
    final request = createProPackageRequest(
      title: 'Portrait session',
      durationMinutes: 60,
      price: Decimal.parse('150.00'),
      includedPhotos: 10,
      extraPhotoPrice: Decimal.parse('12.50'),
    );
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['price'], isA<String>());
    expect(payload['price'], '150.00');
    expect(payload['extra_photo_price'], isA<String>());
    expect(payload['extra_photo_price'], '12.50');
  });

  test('applyProPackagePriceEdits serializes edited prices as strings, not numbers', () {
    final current = ProPackageView(
      id: 'package-1',
      proUserId: 'user-1',
      nicheId: 'niche-1',
      title: 'Portrait session',
      durationMinutes: 60,
      price: '150.00',
      currency: 'EUR',
      includedPhotos: 10,
      extraPhotoPrice: '12.50',
      proofsSlaDays: 3,
      finalsSlaDays: 7,
      addons: const [],
      isActive: true,
    );

    final request = applyProPackagePriceEdits(
      buildProPackageUpdateRequest(current),
      price: Decimal.parse('160.00'),
    );
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['price'], isA<String>());
    expect(payload['price'], '160.00');
    // Untouched field still carries the current value, still a string.
    expect(payload['extra_photo_price'], isA<String>());
    expect(payload['extra_photo_price'], '12.50');
  });
}
