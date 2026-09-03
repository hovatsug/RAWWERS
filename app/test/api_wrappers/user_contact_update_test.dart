import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/user_contact_view.dart';
import 'package:rawwers/core/api_wrappers/user_contact_update.dart';

void main() {
  test('buildUserContactUpdateRequest carries every field from current, so the PUT never wipes untouched fields', () {
    final current = UserContactView(
      userId: 'user-1',
      phoneE164: '+351911111111',
      timezone: 'Europe/Lisbon',
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
    );

    final request = buildUserContactUpdateRequest(current).copyWith(phoneE164: '+351922222222');
    final payload = jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;

    expect(payload['phone_e164'], '+351922222222');
    for (final key in ['timezone', 'quiet_hours_start', 'quiet_hours_end']) {
      expect(payload.containsKey(key), isTrue, reason: '$key must be present in the payload');
      expect(payload[key], isNotNull, reason: '$key must carry the current value, not null');
    }
  });
}
