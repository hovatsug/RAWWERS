import 'package:rawwers/api/models/pro_niche_skill_view.dart';
import 'package:rawwers/api/models/skill_tier.dart';

/// Reads `ProNicheSkillView.breakdown`, which the generated client hands over
/// as an untyped `Map<String, dynamic>` because the backend declares it as a
/// free-form JSON column.
///
/// That makes this the one place in the app where field names are written by
/// hand - exactly what the generated client exists to prevent - so two rules
/// hold here and nowhere else:
///
///   1. Every key this file reads is listed in [readPaths], and a test asserts
///      each one resolves in a real captured response. A backend rename breaks
///      that test instead of silently blanking the whole card.
///   2. An absent or unparseable value is `null`, never `0`. A photographer
///      with no reviews has an *unrated* average, not an average of 0.0, and
///      telling them otherwise is the difference between "you have not been
///      reviewed yet" and "your work is rated zero".
class TierBreakdown {
  const TierBreakdown({this.formula, this.signals, this.thresholds, this.overrideApplied, this.hysteresisBlocked});

  final ScoreFormula? formula;
  final TierSignals? signals;

  /// Threshold policy per tier, as the backend computed it. Null when the
  /// payload did not carry one - in which case the card must say it cannot
  /// work out what is next, rather than inventing a ladder from constants
  /// that would drift from the server's the moment an admin edits a policy.
  final Map<SkillTier, TierThreshold>? thresholds;

  final bool? overrideApplied;
  final bool? hysteresisBlocked;

  /// Dotted paths into `breakdown`, in the shape a real response uses. The
  /// fixture test walks these; adding a read without adding it here is the
  /// mistake that test is built to catch.
  static const readPaths = <String>[
    'score_formula.score',
    'score_formula.gigs_points',
    'score_formula.rating_points',
    'score_formula.verified_bonus',
    'score_formula.penalty',
    'signals.gigs_completed',
    'signals.avg_rating',
    'signals.review_count',
    'signals.disputes_lost_90d',
    'signals.verified',
    'signals.evidence_portfolio',
    'thresholds',
    'override_applied',
    'hysteresis_blocked',
  ];

  static TierBreakdown parse(Map<String, dynamic>? breakdown) {
    if (breakdown == null) return const TierBreakdown();
    return TierBreakdown(
      formula: ScoreFormula._parse(_map(breakdown['score_formula'])),
      signals: TierSignals._parse(_map(breakdown['signals'])),
      thresholds: _parseThresholds(_map(breakdown['thresholds'])),
      overrideApplied: _bool(breakdown['override_applied']),
      hysteresisBlocked: _bool(breakdown['hysteresis_blocked']),
    );
  }

  static Map<SkillTier, TierThreshold>? _parseThresholds(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    final parsed = <SkillTier, TierThreshold>{};
    for (final entry in raw.entries) {
      final tier = _tierFromSlug(entry.key);
      final threshold = TierThreshold._parse(_map(entry.value));
      if (tier != null && threshold != null) parsed[tier] = threshold;
    }
    return parsed.isEmpty ? null : parsed;
  }
}

/// How the score was arrived at. Shown as a decomposition rather than a single
/// number because [penalty] subtracts - it is the only component that moves a
/// photographer down, and burying it inside a total hides the one thing they
/// would want to act on.
class ScoreFormula {
  const ScoreFormula({this.score, this.gigsPoints, this.ratingPoints, this.verifiedBonus, this.penalty});

  final int? score;
  final double? gigsPoints;
  final double? ratingPoints;
  final double? verifiedBonus;
  final double? penalty;

  static ScoreFormula? _parse(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    return ScoreFormula(
      score: _int(raw['score']),
      gigsPoints: _double(raw['gigs_points']),
      ratingPoints: _double(raw['rating_points']),
      verifiedBonus: _double(raw['verified_bonus']),
      penalty: _double(raw['penalty']),
    );
  }
}

/// The measurements the tier is computed from.
class TierSignals {
  const TierSignals({
    this.gigsCompleted,
    this.avgRating,
    this.reviewCount,
    this.disputesLost90d,
    this.verified,
    this.evidencePortfolio,
  });

  final int? gigsCompleted;
  final double? avgRating;
  final int? reviewCount;
  final int? disputesLost90d;
  final bool? verified;
  final int? evidencePortfolio;

  /// `avg_rating` is 0.0 for a photographer nobody has reviewed, which is not
  /// a rating of zero. Anything that displays or compares the average has to
  /// go through here first.
  bool get hasRating => (reviewCount ?? 0) > 0;

  /// True when the payload carried no review count at all, so the caller can
  /// tell "nobody has reviewed you" apart from "we could not read it".
  bool get reviewCountKnown => reviewCount != null;

  static TierSignals? _parse(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    return TierSignals(
      gigsCompleted: _int(raw['gigs_completed']),
      avgRating: _double(raw['avg_rating']),
      reviewCount: _int(raw['review_count']),
      disputesLost90d: _int(raw['disputes_lost_90d']),
      verified: _bool(raw['verified']),
      evidencePortfolio: _int(raw['evidence_portfolio']),
    );
  }
}

class TierThreshold {
  const TierThreshold({this.minScore, this.minGigs, this.minRating, this.requiresVerified});

  final int? minScore;
  final int? minGigs;
  final double? minRating;
  final bool? requiresVerified;

  static TierThreshold? _parse(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    return TierThreshold(
      minScore: _int(raw['min_score']),
      minGigs: _int(raw['min_gigs']),
      minRating: _double(raw['min_rating']),
      requiresVerified: _bool(raw['requires_verified']),
    );
  }
}

/// One unmet requirement, already phrased as something to do.
class TierRequirement {
  const TierRequirement({required this.label, required this.detail, required this.remaining});

  /// Short form for the row: "5 more shoots".
  final String label;

  /// The sentence under it, saying what it is for.
  final String detail;

  /// How far off this requirement is, normalised 0..1, where 1 means "not
  /// started". Used only to order requirements by how close they are; never
  /// shown as a percentage, because a photographer blocked on four separate
  /// things is not "75% of the way there".
  final double remaining;
}

/// What is actually standing between a photographer and their next tier.
///
/// Deliberately not a single percentage. Promotion needs *every* threshold met
/// at once, so someone on 60 points with 4.6 stars and 8 shoots is held back by
/// shoots alone - and showing them "60/100" tells them to chase the wrong
/// thing.
class TierProgress {
  const TierProgress({required this.current, this.next, this.unmet = const [], this.thresholdsKnown = true});

  final SkillTier current;

  /// Null at the top of the ladder, or when the payload carried no policy.
  final SkillTier? next;

  /// Every requirement still unmet for [next], nearest first.
  final List<TierRequirement> unmet;

  /// False when `breakdown.thresholds` was missing, so the card can say it
  /// does not know rather than implying there is nothing left to do.
  final bool thresholdsKnown;

  /// The single step to lead with. Every real photographer starts at rookie
  /// with every threshold unmet, and a list of four red rows on the home
  /// screen is a reason to close the app.
  TierRequirement? get nearest => unmet.isEmpty ? null : unmet.first;

  static TierProgress of(ProNicheSkillView skill, TierBreakdown breakdown) {
    final next = _nextTier(skill.tier);
    if (next == null) return TierProgress(current: skill.tier);

    final thresholds = breakdown.thresholds;
    if (thresholds == null || !thresholds.containsKey(next)) {
      return TierProgress(current: skill.tier, next: next, thresholdsKnown: false);
    }

    final target = thresholds[next]!;
    final signals = breakdown.signals;
    final unmet = <TierRequirement>[];

    final gigs = signals?.gigsCompleted ?? skill.gigsCompleted;
    final minGigs = target.minGigs;
    if (minGigs != null && gigs < minGigs) {
      final short = minGigs - gigs;
      unmet.add(TierRequirement(
        label: short == 1 ? '1 more shoot' : '$short more shoots',
        detail: '$gigs of $minGigs completed',
        remaining: minGigs == 0 ? 0 : short / minGigs,
      ));
    }

    final minScore = target.minScore;
    final score = breakdown.formula?.score ?? skill.score;
    if (minScore != null && score < minScore) {
      final short = minScore - score;
      unmet.add(TierRequirement(
        label: '$short more points',
        detail: '$score of $minScore, earned from shoots, reviews and training',
        remaining: minScore == 0 ? 0 : short / minScore,
      ));
    }

    final minRating = target.minRating;
    if (minRating != null && minRating > 0) {
      if (signals != null && !signals.hasRating) {
        // No reviews at all. The average reads 0.0, which is not a rating -
        // saying "raise your 0.0 to 4.2" would be a lie about work nobody has
        // rated yet.
        unmet.add(TierRequirement(
          label: 'your first reviews',
          detail: 'needs an average of $minRating once clients start rating you',
          remaining: 1,
        ));
      } else {
        final rating = signals?.avgRating ?? skill.avgRating;
        if (rating < minRating) {
          unmet.add(TierRequirement(
            label: 'a $minRating average',
            detail: 'currently ${rating.toStringAsFixed(2)}',
            remaining: minRating == 0 ? 0 : (minRating - rating) / minRating,
          ));
        }
      }
    }

    final verified = signals?.verified ?? skill.verified;
    if ((target.requiresVerified ?? false) && !verified) {
      unmet.add(const TierRequirement(
        label: 'training completed',
        detail: 'this niche needs the RAWWERS curriculum finished',
        remaining: 1,
      ));
    }

    unmet.sort((a, b) => a.remaining.compareTo(b.remaining));
    return TierProgress(current: skill.tier, next: next, unmet: unmet);
  }
}

const _ladder = <SkillTier>[SkillTier.rookie, SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master];

SkillTier? _nextTier(SkillTier current) {
  final index = _ladder.indexOf(current);
  if (index < 0 || index == _ladder.length - 1) return null;
  return _ladder[index + 1];
}

SkillTier? _tierFromSlug(String slug) {
  for (final tier in _ladder) {
    if (tier.name == slug) return tier;
  }
  return null;
}

Map<String, dynamic>? _map(Object? value) => value is Map<String, dynamic> ? value : null;

int? _int(Object? value) => value is int ? value : (value is num ? value.toInt() : null);

double? _double(Object? value) => value is num ? value.toDouble() : null;

bool? _bool(Object? value) => value is bool ? value : null;
