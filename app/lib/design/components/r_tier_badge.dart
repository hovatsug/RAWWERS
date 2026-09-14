import 'package:flutter/material.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/skill_tier.dart';

/// The tier a photographer holds, as a label.
///
/// Tier is per-niche in this data model: a master in weddings who has never
/// shot product is a rookie in product. So a tier is only meaningful beside
/// the niche it belongs to, and this deliberately takes a single tier rather
/// than a photographer.
///
/// A name rather than a widget, and rendered as text at the call site. The
/// public profile already settled this question for the styles line: the
/// design system's chips are either status or interactive filter, and a tier
/// on someone else's profile is neither - it is a descriptive label, and
/// dressing it as a chip would misread as something you can act on.
///
/// It lives here because it was already written once on the photographer's
/// own tier breakdown and was about to be written again on the public
/// profile. A tier renamed in one place and not the other is the kind of
/// drift this codebase has paid for more than once.
String rTierName(SkillTier tier) => switch (tier) {
      SkillTier.rookie => 'Rookie',
      SkillTier.skilled => 'Skilled',
      SkillTier.pro => 'Pro',
      SkillTier.elite => 'Elite',
      SkillTier.master => 'Master',
    };


/// The tier worth showing on a card, or null when there is none.
///
/// `top_niches` carries a row for every niche the ranking touched, and
/// `recompute_pro_niche_skills` writes one for every active niche - so a
/// brand-new photographer arrives with a rookie entry scoring zero in a niche
/// they have never worked in.
///
/// Reading position zero blindly would stamp "Rookie" on exactly the people
/// the "New photographers" row exists to give a fair chance, before they have
/// had a single booking. A tier is a claim backed by evidence; with no
/// evidence there is no claim, and the badge is absent rather than defaulted.
SkillTier? rTierBadgeFor(ClientDiscoverCard card) {
  final niches = card.topNiches;
  if (niches == null || niches.isEmpty) return null;

  final top = niches.first;
  final score = top['score'];
  if (score is! num || score <= 0) return null;

  final slug = top['tier'];
  if (slug is! String) return null;
  for (final tier in SkillTier.values) {
    if (tier.name == slug) return tier;
  }
  return null;
}


/// A tier on a card: the name, small and quiet, never a coloured pill.
///
/// The public profile settled this - the design system's chips are status or
/// interactive filter, and a tier on someone else's card is neither.
class RTierLabel extends StatelessWidget {
  const RTierLabel({required this.tier, super.key});

  final SkillTier tier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      rTierName(tier),
      maxLines: 1,
      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
