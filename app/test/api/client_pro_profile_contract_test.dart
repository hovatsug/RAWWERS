import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/api/models/skill_tier.dart';

/// The generated client against a real response body.
///
/// `flutter analyze` cannot catch a mismatch between the wire format and the
/// generated model: the class exists, the fields are plausible, and the
/// contract check passes because the client genuinely matches the schema it
/// was handed. It surfaces at runtime, on the screen, as a type error - which
/// is exactly how the AvailabilityRuleView collision was found.
///
/// The fixture is a genuine `GET /v1/client/pros/{id}` body for a seeded
/// two-niche photographer, with every presigned URL replaced: those carry an
/// access key and a signature, and a fixture is a file in the repository.
void main() {
  late Map<String, dynamic> body;

  setUpAll(() {
    body = jsonDecode(File('test/fixtures/client_pro_profile_response.json').readAsStringSync())
        as Map<String, dynamic>;
  });

  test('a real profile body decodes into the generated model', () {
    final profile = ClientProProfileResponse.fromJson(body);

    expect(profile.displayName, 'Tomás Belmonte');
    expect(profile.niches, isNotNull);
    expect(profile.niches!.length, 2);
    expect(profile.portfolioPreview!.length, 19);
  });

  test('niche tags survive the round trip, so the grid can be split', () {
    final profile = ClientProProfileResponse.fromJson(body);
    final tagged = profile.portfolioPreview!.where((p) => (p.nicheSlugs ?? const []).isNotEmpty);

    expect(
      tagged.length,
      profile.portfolioPreview!.length,
      reason: 'photos arrived without their niche, so the profile cannot filter them',
    );
  });

  test('the tier decodes as an enum rather than falling back', () {
    final profile = ClientProProfileResponse.fromJson(body);
    final weddings = profile.niches!.firstWhere((n) => n.slug == 'weddings');

    // A string that fails to map would silently become the first enum value,
    // and every photographer would read as a rookie on their own profile.
    expect(weddings.tier, SkillTier.elite);
    expect(weddings.photoCount, 15);
  });
}
