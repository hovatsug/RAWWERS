import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/pro_niche_skill_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/tier/tier_breakdown.dart';

part 'tier_controller.g.dart';

/// A niche the photographer chose, with where they stand in it.
class NicheStanding {
  const NicheStanding({required this.skill, required this.breakdown, required this.progress, required this.isPrimary});

  final ProNicheSkillView skill;
  final TierBreakdown breakdown;
  final TierProgress progress;
  final bool isPrimary;
}

/// What the tier section renders.
class TierStandings {
  const TierStandings({required this.standings, required this.hasChosenNiches});

  final List<NicheStanding> standings;

  /// False when the photographer has not picked what they shoot yet. The
  /// section then offers that choice instead of showing nothing, because it
  /// is the one action that makes the rest of the dashboard mean anything.
  final bool hasChosenNiches;
}

/// Where the photographer stands, per niche they actually work in.
///
/// Two calls, deliberately joined here rather than rendered separately:
/// `GET /v1/pro/me/skills` returns a row for **every active niche** - twelve
/// today - regardless of what this photographer selected, because it
/// recomputes across all of them before selecting. Rendered literally, a new
/// photographer's home screen would open with twelve rookie cards for ten
/// niches they never chose. `GET /v1/pro/niches/mine` is what they actually
/// picked, so the intersection is what gets shown.
///
/// keepAlive because every dashboard block reads this one result. The skills
/// endpoint recomputes and commits on every call (see docs/BACKEND_GAPS.md),
/// so refetching it per block would turn one app launch into several rounds of
/// twelve-niche write work.
@Riverpod(keepAlive: true)
class TierStandingsController extends _$TierStandingsController {
  @override
  Future<TierStandings> build() async {
    final client = ref.read(proOnboardingClientProvider);

    final chosenResult = await apiCall(
      () => client.getMySelectedNichesV1ProNichesMineGet(authorization: null, xMinusUserMinusId: null),
    );
    final chosen = switch (chosenResult) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
    final chosenSlugs = {for (final niche in chosen.niches ?? const []) niche.slug};

    if (chosenSlugs.isEmpty) {
      return const TierStandings(standings: [], hasChosenNiches: false);
    }

    final skillsResult = await apiCall(
      () => client.getMyNicheSkillsV1ProMeSkillsGet(authorization: null, xMinusUserMinusId: null),
    );
    final skills = switch (skillsResult) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };

    final standings = <NicheStanding>[];
    for (final skill in skills.items ?? const <ProNicheSkillView>[]) {
      if (!chosenSlugs.contains(skill.nicheSlug)) continue;
      final breakdown = TierBreakdown.parse(skill.breakdown);
      standings.add(NicheStanding(
        skill: skill,
        breakdown: breakdown,
        progress: TierProgress.of(skill, breakdown),
        isPrimary: skill.nicheSlug == chosen.primaryNicheSlug,
      ));
    }

    // Primary first, then the strongest - a photographer's main niche is the
    // one they came to look at.
    standings.sort((a, b) {
      if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
      return b.skill.score.compareTo(a.skill.score);
    });

    return TierStandings(standings: standings, hasChosenNiches: true);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
