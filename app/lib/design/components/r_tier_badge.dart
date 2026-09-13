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
