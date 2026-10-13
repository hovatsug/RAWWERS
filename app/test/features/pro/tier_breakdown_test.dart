// The parser that reads `ProNicheSkillView.breakdown` by hand.
//
// Two of these tests exist because of specific ways this could go wrong
// silently, and both were requested before a line of it was written:
//
//   - The keys are hand-written, so a backend rename would blank the whole
//     card while every screen kept rendering. `readPaths` is checked against a
//     real captured response, so a rename fails here instead.
//   - Absent data must never surface as 0. A photographer nobody has reviewed
//     has an unrated average, not a rating of zero, and the difference is the
//     sixth instance of the false-zero pattern in this project.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_niche_skill_list_response.dart';
import 'package:rawwers/api/models/pro_niche_skill_view.dart';
import 'package:rawwers/api/models/skill_tier.dart';
import 'package:rawwers/features/pro/tier/tier_breakdown.dart';

/// A real `GET /v1/pro/me/skills` response, captured from the running backend
/// rather than written by hand. Two items: one niche the photographer selected
/// and one they did not.
Map<String, dynamic> _fixture() =>
    jsonDecode(File('test/fixtures/pro_skills_response.json').readAsStringSync()) as Map<String, dynamic>;

Object? _resolve(Map<String, dynamic> root, String dottedPath) {
  Object? node = root;
  for (final segment in dottedPath.split('.')) {
    if (node is! Map<String, dynamic> || !node.containsKey(segment)) return _missing;
    node = node[segment];
  }
  return node;
}

const _missing = Object();

void main() {
  group('the fixture is a real response', () {
    test('it parses as the generated model, so it cannot drift into a hand-built shape', () {
      final response = ProNicheSkillListResponse.fromJson(_fixture());
      expect(response.items, isNotNull);
      expect(response.items!.length, 2);
      expect(response.items!.map((i) => i.nicheSlug), containsAll(<String>['weddings', 'maternity']));
    });
  });

  test('every key the parser reads exists in a real response', () {
    // Without this, a backend rename would show up as an entire card quietly
    // reading "not available" - which looks like missing data rather than a
    // broken contract, and would survive a long time.
    final items = (_fixture()['items'] as List).cast<Map<String, dynamic>>();
    expect(items, isNotEmpty, reason: 'no items in the fixture, so this test would prove nothing');

    for (final item in items) {
      final breakdown = item['breakdown'] as Map<String, dynamic>?;
      expect(breakdown, isNotNull, reason: '${item['niche_slug']} carries no breakdown at all');
      for (final path in TierBreakdown.readPaths) {
        expect(
          _resolve(breakdown!, path),
          isNot(same(_missing)),
          reason: 'the parser reads breakdown.$path, which is not in a real response for '
              '${item['niche_slug']}. Either the backend renamed it or readPaths is out of date.',
        );
      }
    }
  });

  test('the thresholds in a real response cover every tier the ladder can reach', () {
    final items = (_fixture()['items'] as List).cast<Map<String, dynamic>>();
    final parsed = TierBreakdown.parse(items.first['breakdown'] as Map<String, dynamic>);
    expect(parsed.thresholds, isNotNull);
    expect(
      parsed.thresholds!.keys,
      containsAll(<SkillTier>[SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master]),
      reason: 'a tier with no threshold cannot be explained to a photographer',
    );
  });

  group('absent data never becomes zero', () {
    test('an empty breakdown yields nulls, not zeros', () {
      final parsed = TierBreakdown.parse(<String, dynamic>{});
      expect(parsed.formula, isNull);
      expect(parsed.signals, isNull);
      expect(parsed.thresholds, isNull);
      expect(parsed.overrideApplied, isNull);
      expect(parsed.hysteresisBlocked, isNull);
    });

    test('a null breakdown yields nulls, not zeros', () {
      final parsed = TierBreakdown.parse(null);
      expect(parsed.formula, isNull);
      expect(parsed.signals, isNull);
      expect(parsed.thresholds, isNull);
    });

    test('individual keys going missing leaves those fields null and the rest intact', () {
      // The realistic shape of a backend change: one field renamed, the others
      // still present. Every removed field must read as unknown, and the
      // survivors must still parse.
      final parsed = TierBreakdown.parse(<String, dynamic>{
        'score_formula': <String, dynamic>{'score': 42},
        'signals': <String, dynamic>{'gigs_completed': 7},
        'thresholds': <String, dynamic>{},
      });

      expect(parsed.formula!.score, 42);
      expect(parsed.formula!.gigsPoints, isNull);
      expect(parsed.formula!.ratingPoints, isNull);
      expect(parsed.formula!.verifiedBonus, isNull);
      expect(parsed.formula!.penalty, isNull);

      expect(parsed.signals!.gigsCompleted, 7);
      expect(parsed.signals!.avgRating, isNull);
      expect(parsed.signals!.reviewCount, isNull);
      expect(parsed.signals!.disputesLost90d, isNull);
      expect(parsed.signals!.verified, isNull);

      expect(parsed.thresholds, isNull, reason: 'an empty policy is no policy, not a policy of zeros');
    });

    test('a value of the wrong type is unknown rather than coerced', () {
      final parsed = TierBreakdown.parse(<String, dynamic>{
        'score_formula': <String, dynamic>{'score': 'not a number'},
        'signals': <String, dynamic>{'verified': 'yes'},
      });
      expect(parsed.formula!.score, isNull);
      expect(parsed.signals!.verified, isNull);
    });
  });

  group('what is actually blocking promotion', () {
    ProNicheSkillView skillFrom(Map<String, dynamic> item) => ProNicheSkillView.fromJson(item);

    test('a day-one photographer is told about reviews, not a rating of zero', () {
      final items = (_fixture()['items'] as List).cast<Map<String, dynamic>>();
      final skill = skillFrom(items.firstWhere((i) => i['niche_slug'] == 'weddings'));
      final progress = TierProgress.of(skill, TierBreakdown.parse(skill.breakdown));

      expect(progress.current, SkillTier.rookie);
      expect(progress.next, SkillTier.skilled);

      final rating = progress.unmet.where((r) => r.label.contains('review') || r.label.contains('average'));
      expect(rating, hasLength(1));
      expect(
        rating.first.label,
        'your first reviews',
        reason: 'nobody has rated this photographer; naming a 0.0 average would be a claim about their work',
      );
      expect(rating.first.detail, isNot(contains('0.00')));
    });

    test('the nearest step comes first, and it is one thing rather than a wall', () {
      final items = (_fixture()['items'] as List).cast<Map<String, dynamic>>();
      final skill = skillFrom(items.first);
      final progress = TierProgress.of(skill, TierBreakdown.parse(skill.breakdown));

      expect(progress.unmet, isNotEmpty);
      expect(progress.nearest, progress.unmet.first);
      for (var i = 1; i < progress.unmet.length; i++) {
        expect(
          progress.unmet[i - 1].remaining <= progress.unmet[i].remaining,
          isTrue,
          reason: 'requirements must be ordered by how close they are, so the lead is the achievable one',
        );
      }
    });

    test('a rated photographer short on shoots is told about shoots', () {
      final skill = ProNicheSkillView(
        nicheSlug: 'weddings',
        nicheName: 'Weddings',
        nicheId: '00000000-0000-0000-0000-000000000001',
        tier: SkillTier.rookie,
        score: 60,
        verified: true,
        gigsCompleted: 3,
        avgRating: 4.6,
        reviewCount: 12,
        capabilityScore: 60,
        certificationScore: 100,
        confidence: 0.5,
        evidenceGigs: 3,
        evidenceReviews: 12,
        evidencePortfolio: 10,
        updatedAt: DateTime.utc(2026),
        breakdown: <String, dynamic>{
          'signals': <String, dynamic>{'gigs_completed': 3, 'avg_rating': 4.6, 'review_count': 12, 'verified': true},
          'thresholds': <String, dynamic>{
            'skilled': <String, dynamic>{'min_gigs': 5, 'min_score': 25, 'min_rating': 4.2, 'requires_verified': false},
          },
        },
      );
      final progress = TierProgress.of(skill, TierBreakdown.parse(skill.breakdown));
      expect(progress.unmet, hasLength(1));
      expect(progress.nearest!.label, '2 more shoots');
      expect(progress.nearest!.detail, '3 of 5 completed');
    });

    test('missing thresholds are admitted rather than read as nothing left to do', () {
      final skill = ProNicheSkillView(
        nicheSlug: 'weddings',
        nicheName: 'Weddings',
        nicheId: '00000000-0000-0000-0000-000000000001',
        tier: SkillTier.rookie,
        score: 0,
        verified: false,
        gigsCompleted: 0,
        avgRating: 0,
        reviewCount: 0,
        capabilityScore: 0,
        certificationScore: 0,
        confidence: 0,
        evidenceGigs: 0,
        evidenceReviews: 0,
        evidencePortfolio: 0,
        updatedAt: DateTime.utc(2026),
        breakdown: const <String, dynamic>{},
      );
      final progress = TierProgress.of(skill, TierBreakdown.parse(skill.breakdown));
      expect(progress.thresholdsKnown, isFalse);
      expect(
        progress.unmet,
        isEmpty,
        reason: 'an empty list here must mean "unknown", which thresholdsKnown is what distinguishes',
      );
    });

    test('the top of the ladder has no next tier', () {
      final skill = ProNicheSkillView(
        nicheSlug: 'weddings',
        nicheName: 'Weddings',
        nicheId: '00000000-0000-0000-0000-000000000001',
        tier: SkillTier.master,
        score: 90,
        verified: true,
        gigsCompleted: 200,
        avgRating: 4.9,
        reviewCount: 80,
        capabilityScore: 90,
        certificationScore: 100,
        confidence: 1,
        evidenceGigs: 200,
        evidenceReviews: 80,
        evidencePortfolio: 40,
        updatedAt: DateTime.utc(2026),
        breakdown: const <String, dynamic>{},
      );
      final progress = TierProgress.of(skill, TierBreakdown.parse(skill.breakdown));
      expect(progress.next, isNull);
      expect(progress.nearest, isNull);
    });
  });
}
