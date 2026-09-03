import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/core/api_wrappers/pro_package_update.dart';

void main() {
  test('buildProPackageUpdateRequest carries every field from current, so the PUT never wipes untouched fields', () {
    final current = ProPackageView(
      id: 'package-1',
      proUserId: 'user-1',
      nicheId: 'niche-1',
      title: 'Portrait session',
      description: '60 minute studio session.',
      durationMinutes: 60,
      price: '150.00',
      currency: 'EUR',
      includedPhotos: 10,
      extraPhotoPrice: '12.50',
      proofsSlaDays: 3,
      finalsSlaDays: 7,
      addons: const [
        {'name': 'extra_hour', 'price': '80.00'},
      ],
      isActive: true,
    );

    final request = buildProPackageUpdateRequest(current).copyWith(price: '160.00');
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['price'], '160.00');
    for (final key in [
      'title',
      'niche_id',
      'description',
      'duration_minutes',
      'currency',
      'included_photos',
      'extra_photo_price',
      'proofs_sla_days',
      'finals_sla_days',
      'addons',
      'is_active',
    ]) {
      expect(payload.containsKey(key), isTrue, reason: '$key must be present in the payload');
      expect(payload[key], isNotNull, reason: '$key must carry the current value, not null');
    }
  });
}
