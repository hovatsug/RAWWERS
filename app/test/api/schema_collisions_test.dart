import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/availability_location_mode.dart';
import 'package:rawwers/api/models/availability_rules_response.dart';
import 'package:rawwers/api/models/client_availability_response.dart';

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
/// The backend class became `PublicAvailabilityRuleView`, and later went
/// with the public endpoint that returned it - it leaked blackout reasons to
/// anyone, signed in or not. The client calendar's payload replaced it. These stay because they assert the thing that
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

  test('the client calendar decodes, keeping the instant and the local time apart', () {
    const raw = '''
{"timezone":"Europe/Lisbon","has_schedule":true,"notice_hours":24,
"days":[{"date":"2026-10-12","open":true,
"start_times":[{"start_at":"2026-10-12T10:00:00+01:00","local_time":"10:00"}]},
{"date":"2026-10-13","open":false,"start_times":[]}]}
''';

    final response = ClientAvailabilityResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final open = response.days!.first;
    final start = open.startTimes!.single;

    expect(open.open, isTrue);
    expect(start.localTime, '10:00', reason: 'what the client reads');
    // The instant survives as the instant: 10:00 in Lisbon is 09:00Z.
    expect(start.startAt.toUtc(), DateTime.utc(2026, 10, 12, 9));
    expect(response.days!.last.open, isFalse);
  });
}
