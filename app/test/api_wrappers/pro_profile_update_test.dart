import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api_wrappers/pro_profile_update.dart';

void main() {
  test('buildProProfileUpdateRequest carries every field from current, so the PUT never wipes untouched fields', () {
    final current = ProProfileView(
      userId: 'user-1',
      displayName: 'Ada Lovelace',
      headline: 'Portrait photographer',
      coverMediaAssetId: 'asset-1',
      bio: 'Shooting since 2015.',
      city: 'Lisbon',
      country: 'PT',
      languages: const ['en', 'pt'],
      styles: const ['editorial'],
      gear: const {'camera': 'Sony A7IV'},
      isAcceptingBookings: true,
      completenessScore: 80,
      kycStatus: 'approved',
    );

    final request = buildProProfileUpdateRequest(current).copyWith(displayName: 'Ada L.');
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['display_name'], 'Ada L.');
    for (final key in [
      'headline',
      'cover_media_asset_id',
      'bio',
      'city',
      'country',
      'languages',
      'styles',
      'gear',
    ]) {
      expect(payload.containsKey(key), isTrue, reason: '$key must be present in the payload');
      expect(payload[key], isNotNull, reason: '$key must carry the current value, not null');
    }
  });
}
