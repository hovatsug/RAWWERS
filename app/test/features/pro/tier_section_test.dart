// The tier section on the dashboard.
//
// Two of these assert the things the section exists to get right, and both
// would pass silently if the section were built the obvious way:
//
//   - Day one is rookie with every threshold unmet. The section must lead with
//     one achievable step, not five red rows.
//   - A component the parser could not read must read "not available", never a
//     number. Rendering 0 there tells a photographer their work scored zero.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_niche_skill_list_response.dart';
import 'package:rawwers/api/models/pro_niche_skill_view.dart';
import 'package:rawwers/api/models/skill_tier.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/tier/tier_breakdown.dart';
import 'package:rawwers/features/pro/tier/tier_controller.dart';
import 'package:rawwers/features/pro/tier/tier_section.dart';

class _FakeStandings extends TierStandingsController {
  _FakeStandings(this._value);
  final TierStandings _value;
  @override
  Future<TierStandings> build() async => _value;
}

class _FailingStandings extends TierStandingsController {
  @override
  Future<TierStandings> build() async => throw const NetworkError();
}

List<ProNicheSkillView> _realItems() {
  final raw = jsonDecode(File('test/fixtures/pro_skills_response.json').readAsStringSync()) as Map<String, dynamic>;
  return ProNicheSkillListResponse.fromJson(raw).items!;
}

NicheStanding _standingFrom(ProNicheSkillView skill, {bool isPrimary = true}) {
  final breakdown = TierBreakdown.parse(skill.breakdown);
  return NicheStanding(
    skill: skill,
    breakdown: breakdown,
    progress: TierProgress.of(skill, breakdown),
    isPrimary: isPrimary,
  );
}

Future<void> _pump(WidgetTester tester, TierStandingsController Function() controller) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tierStandingsControllerProvider.overrideWith(controller)],
      child: MaterialApp(
        theme: buildProTheme(),
        home: const Scaffold(
          body: SingleChildScrollView(child: TierSection(chooseNichesPath: '/niches')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('day one leads with one step, not a wall of everything unmet', (tester) async {
    final skill = _realItems().firstWhere((i) => i.nicheSlug == 'weddings');
    final standing = _standingFrom(skill);
    await _pump(tester, () => _FakeStandings(TierStandings(standings: [standing], hasChosenNiches: true)));

    expect(standing.skill.tier, SkillTier.rookie);
    expect(standing.progress.unmet.length, greaterThan(1), reason: 'day one really does have several unmet');

    // Only the nearest requirement is on screen; the rest are behind the tap.
    expect(find.text(standing.progress.nearest!.label), findsOneWidget);
    for (final requirement in standing.progress.unmet.skip(1)) {
      expect(
        find.text(requirement.label),
        findsNothing,
        reason: 'collapsed, every unmet requirement is a red row and the home screen becomes a wall',
      );
    }
    expect(find.textContaining('more thing'), findsOneWidget);
  });

  testWidgets('the rest are reachable, just not shouted', (tester) async {
    final skill = _realItems().firstWhere((i) => i.nicheSlug == 'weddings');
    final standing = _standingFrom(skill);
    await _pump(tester, () => _FakeStandings(TierStandings(standings: [standing], hasChosenNiches: true)));

    await tester.tap(find.textContaining('more thing'));
    await tester.pumpAndSettle();
    for (final requirement in standing.progress.unmet.skip(1)) {
      expect(find.text(requirement.label), findsOneWidget);
    }
  });

  testWidgets('an unrated photographer is never shown a rating of zero', (tester) async {
    final skill = _realItems().firstWhere((i) => i.nicheSlug == 'weddings');
    await _pump(
      tester,
      () => _FakeStandings(TierStandings(standings: [_standingFrom(skill)], hasChosenNiches: true)),
    );

    // Nothing on the collapsed card claims a rating at all.
    expect(find.textContaining('0.00'), findsNothing);
    expect(find.textContaining('0.0 average'), findsNothing);

    // And with everything shown, the rating requirement is phrased as work
    // nobody has judged yet rather than as an average of zero.
    await tester.tap(find.textContaining('more thing'));
    await tester.pumpAndSettle();
    expect(find.text('your first reviews'), findsOneWidget);
    expect(find.textContaining('0.00'), findsNothing);
  });

  testWidgets('a score component that could not be read says so instead of showing zero', (tester) async {
    // The realistic backend change: score_formula loses a field. Every row that
    // depended on it must read "not available", because "+0" is a claim.
    final skill = ProNicheSkillView(
      nicheSlug: 'weddings',
      nicheName: 'Weddings',
      nicheId: '00000000-0000-0000-0000-000000000001',
      tier: SkillTier.skilled,
      score: 30,
      verified: false,
      gigsCompleted: 6,
      avgRating: 4.3,
      reviewCount: 4,
      capabilityScore: 30,
      certificationScore: 0,
      confidence: 0.3,
      evidenceGigs: 6,
      evidenceReviews: 4,
      evidencePortfolio: 12,
      updatedAt: DateTime.utc(2026),
      breakdown: const <String, dynamic>{
        'score_formula': <String, dynamic>{'score': 30},
        'signals': <String, dynamic>{'gigs_completed': 6, 'avg_rating': 4.3, 'review_count': 4},
        'thresholds': <String, dynamic>{
          'pro': <String, dynamic>{'min_gigs': 20, 'min_score': 50, 'min_rating': 4.4, 'requires_verified': true},
        },
      },
    );
    await _pump(
      tester,
      () => _FakeStandings(TierStandings(standings: [_standingFrom(skill)], hasChosenNiches: true)),
    );

    expect(find.text('not available'), findsWidgets);
    expect(find.text('+0'), findsNothing, reason: 'a component we could not read is unknown, not zero');
  });

  testWidgets('no niches chosen offers the choice rather than an empty panel', (tester) async {
    await _pump(tester, () => _FakeStandings(const TierStandings(standings: [], hasChosenNiches: false)));
    expect(find.text('Pick what you shoot'), findsOneWidget);
    expect(find.text('Choose niches'), findsOneWidget);
  });

  testWidgets('a failure is retryable rather than silently empty', (tester) async {
    await _pump(tester, _FailingStandings.new);
    expect(find.textContaining('Could not load'), findsOneWidget);
  });
}
