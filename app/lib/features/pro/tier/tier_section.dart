import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/skill_tier.dart';
import 'package:rawwers/design/components/r_tier_badge.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_progress.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/tier/tier_breakdown.dart';
import 'package:rawwers/features/pro/tier/tier_controller.dart';

/// Where a photographer stands, per niche they work in.
///
/// The shape of this section is set by one fact: every real photographer opens
/// it on day one at rookie with every threshold unmet. Rendered as a ladder
/// that is five red rows, and a home screen that greets you with a wall of
/// failure is a reason to close the app. So each card leads with what the tier
/// they already have is doing for them, then names exactly one achievable next
/// step. Everything else is behind a tap.
class TierSection extends ConsumerWidget {
  const TierSection({required this.chooseNichesPath, super.key});

  /// Where "pick what you shoot" goes. Choosing niches is the one action that
  /// makes the rest of this section - and most of the dashboard - mean
  /// anything, so the empty state offers it rather than showing nothing.
  final String chooseNichesPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standings = ref.watch(tierStandingsControllerProvider);

    return switch (standings) {
      AsyncLoading() => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [RSkeleton(height: 132), SizedBox(height: RSpace.s12), RSkeleton(height: 132)],
        ),
      AsyncError() => RErrorState(
          message: 'Could not load where you stand.',
          onRetry: () => ref.read(tierStandingsControllerProvider.notifier).refresh(),
        ),
      AsyncData(:final value) when !value.hasChosenNiches => _ChooseNichesPrompt(path: chooseNichesPath),
      AsyncData(:final value) when value.standings.isEmpty => const REmptyState(
          title: 'No standing yet',
          body: 'We could not work out where you stand in the niches you picked. Pull to refresh.',
          icon: Icons.workspace_premium_outlined,
        ),
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final standing in value.standings) ...[
              _NicheCard(standing: standing),
              const SizedBox(height: RSpace.s12),
            ],
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Choosing niches is the one action that makes the rest of the dashboard work,
/// so the empty state is an invitation rather than a blank panel.
class _ChooseNichesPrompt extends StatelessWidget {
  const _ChooseNichesPrompt({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pick what you shoot', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          Text(
            'Your standing is tracked per niche, and clients search by it. Until you choose at least one, '
            'there is nothing here to measure.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: RSpace.s12),
          Align(
            alignment: Alignment.centerLeft,
            child: RButton(label: 'Choose niches', onPressed: () => context.push(path)),
          ),
        ],
      ),
    );
  }
}

class _NicheCard extends StatefulWidget {
  const _NicheCard({required this.standing});

  final NicheStanding standing;

  @override
  State<_NicheCard> createState() => _NicheCardState();
}

class _NicheCardState extends State<_NicheCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final standing = widget.standing;
    final progress = standing.progress;
    final remaining = progress.unmet.length;

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(standing.skill.nicheName, style: theme.textTheme.titleMedium),
              ),
              if (standing.isPrimary) ...[
                const RStatusChip(label: 'Main', kind: RStatusChipKind.inProgress),
                const SizedBox(width: RSpace.s8),
              ],
              RStatusChip(label: _tierName(standing.skill.tier), kind: RStatusChipKind.positive),
            ],
          ),
          const SizedBox(height: RSpace.s8),

          // What the tier they already have is doing for them. Grounded in the
          // one effect tier actually has today - discovery placement adds
          // tier_rank * 8 to the ranking score - rather than a promise about
          // pricing or bookings that nothing in the backend enforces.
          Text(_tierMeaning(standing.skill.tier), style: theme.textTheme.bodySmall),

          const SizedBox(height: RSpace.s16),
          const Divider(height: 1),
          const SizedBox(height: RSpace.s16),

          if (!progress.thresholdsKnown)
            Text(
              'We could not read what the next tier needs, so we cannot tell you what is left. '
              'This is our problem, not yours.',
              style: theme.textTheme.bodySmall,
            )
          else if (progress.next == null)
            Text('This is the top tier. Nothing above it.', style: theme.textTheme.bodySmall)
          else if (progress.nearest == null)
            Text(
              'Everything for ${_tierName(progress.next!)} is met. The next recalculation moves you up.',
              style: theme.textTheme.bodySmall,
            )
          else ...[
            Text('Closest to ${_tierName(progress.next!)}', style: theme.textTheme.labelMedium),
            const SizedBox(height: RSpace.s8),
            _RequirementRow(requirement: progress.nearest!, emphasised: true),
            if (remaining > 1) ...[
              const SizedBox(height: RSpace.s8),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: RSpace.s4),
                  child: Row(
                    children: [
                      Text(
                        _expanded
                            ? 'Hide the rest'
                            : '${remaining - 1} more ${remaining - 1 == 1 ? 'thing' : 'things'} after that',
                        style: theme.textTheme.bodySmall?.copyWith(color: RAccent.meter500),
                      ),
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: RAccent.meter500),
                    ],
                  ),
                ),
              ),
              if (_expanded)
                for (final requirement in progress.unmet.skip(1)) ...[
                  const SizedBox(height: RSpace.s8),
                  _RequirementRow(requirement: requirement, emphasised: false),
                ],
            ],
          ],

          const SizedBox(height: RSpace.s16),
          _ScoreBreakdown(breakdown: standing.breakdown, score: standing.skill.score),

          // Gear is not an input to the tier calculation today, and what the
          // ceiling should be is an open product decision. A labelled empty
          // slot beats inventing a rule the backend does not enforce.
          const SizedBox(height: RSpace.s12),
          Text(
            'Kit is not part of this yet.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.requirement, required this.emphasised});

  final TierRequirement requirement;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(
            emphasised ? Icons.radio_button_unchecked : Icons.circle_outlined,
            size: emphasised ? 16 : 12,
            color: emphasised ? RAccent.meter500 : theme.colorScheme.outline,
          ),
        ),
        const SizedBox(width: RSpace.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                requirement.label,
                style: emphasised ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium,
              ),
              Text(requirement.detail, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// The score, taken apart.
///
/// The penalty is shown as its own subtracting row rather than folded into the
/// total: it is the only component that moves a photographer down, and it is
/// the one they would most want to know about.
class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.breakdown, required this.score});

  final TierBreakdown breakdown;
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formula = breakdown.formula;
    final shown = formula?.score ?? score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Score', style: theme.textTheme.labelMedium)),
            Text('$shown / 100', style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: RSpace.s8),
        RProgressBar(value: shown / 100),
        if (formula != null) ...[
          const SizedBox(height: RSpace.s8),
          _FormulaRow(label: 'Shoots', value: formula.gigsPoints),
          _FormulaRow(label: 'Reviews', value: formula.ratingPoints),
          _FormulaRow(label: 'Training', value: formula.verifiedBonus),
          if ((formula.penalty ?? 0) > 0) _FormulaRow(label: 'Disputes lost', value: formula.penalty, subtracts: true),
        ],
      ],
    );
  }
}

class _FormulaRow extends StatelessWidget {
  const _FormulaRow({required this.label, required this.value, this.subtracts = false});

  final String label;
  final double? value;
  final bool subtracts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // No value means we could not read it, which is not the same as zero.
    final text = value == null
        ? 'not available'
        : '${subtracts ? '−' : '+'}${value! == value!.roundToDouble() ? value!.toStringAsFixed(0) : value!.toStringAsFixed(1)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: value == null
                  ? theme.colorScheme.outline
                  : (subtracts ? theme.colorScheme.error : theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kept as a local alias so the call sites below read unchanged. The names
/// themselves moved to the design layer once the public profile needed them
/// too - two copies of a tier's name is one rename away from a photographer
/// being an "Elite" on their dashboard and something else on their profile.
String _tierName(SkillTier tier) => rTierName(tier);

/// Deliberately modest. Tier feeds the Discover ranking score - each step up is
/// worth 8 points there, which is the only thing it currently changes. The
/// per-tier price caps and extra-image policies the backend can enforce have no
/// rows configured, so promising anything about pricing here would be untrue.
String _tierMeaning(SkillTier tier) => switch (tier) {
      SkillTier.rookie => 'You are listed and bookable. Moving up lifts where you appear in Discover.',
      SkillTier.skilled => 'You rank above rookies in Discover. Each step up is worth more placement.',
      SkillTier.pro => 'You rank above skilled photographers in Discover.',
      SkillTier.elite => 'Near the top of Discover for this niche.',
      SkillTier.master => 'The top of Discover for this niche.',
    };
