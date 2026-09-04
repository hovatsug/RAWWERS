import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/availability_location_mode.dart';
import 'package:rawwers/api/models/availability_rules_response.dart';
import 'package:rawwers/api/models/public_availability_response.dart';

/// onboarding.py and scheduling.py both defined `AvailabilityRuleView`.
/// FastAPI qualified the schema keys but left both `title`s identical, and
/// swagger_to_dart names the Dart class from the title - so two different
/// shapes collapsed into one class, the scheduling one lost, and reading
/// GET /v1/pro/scheduling/availability-rules threw
/// "Null is not a subtype of num" at runtime.
///
/// Nothing static caught it: the class existed, the field names were
/// plausible, `flutter analyze` was clean, and the OpenAPI contract check
/// passed because the client genuinely matched the schema it was handed.
///
/// The backend class is now `PublicAvailabilityRuleView`, so the collision
/// is gone at source. These stay because they assert the thing that
/// actually matters - that each endpoint's real payload decodes - which no
/// amount of renaming guarantees on its own.
void main() {
  test('scheduling availability rules decode with their own field names', () {
    const raw = '''
{"items":[{"weekday":1,"start_local":"09:00:00","end_local":"17:00:00",
"timezone":"Europe/Lisbon","location_mode":"both",
"id":"bcd83bcf-4d46-40e6-8311-638b4fbfc370",
"pro_user_id":"927dc016-735f-40f7-a54b-97451f26d5af",
"created_at":"2026-09-04T20:06:16.444695Z",
"updated_at":"2026-09-04T20:06:16.444702Z"}]}
''';

    final response = AvailabilityRulesResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final rule = response.items!.single;

    expect(rule.weekday, 1);
    expect(rule.startLocal, '09:00:00');
    expect(rule.timezone, 'Europe/Lisbon');
    // The timezone and location mode are the whole reason this endpoint
    // supersedes the deprecated one; losing them to a name clash would
    // reintroduce the bug the deprecation was meant to end.
    expect(rule.locationMode, AvailabilityLocationMode.both);
  });

  test('the public availability view keeps its own, different shape', () {
    const raw = '''
{"pro_user_id":"927dc016-735f-40f7-a54b-97451f26d5af",
"rules":[{"id":"bcd83bcf-4d46-40e6-8311-638b4fbfc370","day_of_week":1,
"start_time":"09:00:00","end_time":"17:00:00"}],
"blackouts":[]}
''';

    final response = PublicAvailabilityResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final rule = response.rules.single;

    expect(rule.dayOfWeek, 1);
    expect(rule.startTime, '09:00:00');
  });
}
