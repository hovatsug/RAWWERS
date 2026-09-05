import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/notification_digest_mode.dart';
import 'package:rawwers/api/models/notification_preference_view.dart';
import 'package:rawwers/core/api_wrappers/notification_preference_update.dart';

void main() {
  test('buildNotificationPreferenceUpdateRequest carries every field from current, so the PUT never wipes untouched fields', () {
    final current = NotificationPreferenceView(
      timezone: 'Europe/Lisbon',
      quietHoursEnabled: true,
      quietStartLocal: '22:00',
      quietEndLocal: '08:00',
      channelEmailEnabled: true,
      channelInappEnabled: false,
      digestMode: NotificationDigestMode.daily,
    );

    final request = buildNotificationPreferenceUpdateRequest(current).copyWith(digestMode: NotificationDigestMode.weekly);
    // request.toJson() still holds live Dart values (e.g. the enum
    // instance); round-trip through jsonEncode/jsonDecode to get the
    // actual wire payload, the same as what dio sends.
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['digest_mode'], 'weekly');
    for (final key in [
      'timezone',
      'quiet_hours_enabled',
      'quiet_start_local',
      'quiet_end_local',
      'channel_email_enabled',
      'channel_inapp_enabled',
    ]) {
      expect(payload.containsKey(key), isTrue, reason: '$key must be present in the payload');
      expect(payload[key], isNotNull, reason: '$key must carry the current value, not null');
    }
  });
}
