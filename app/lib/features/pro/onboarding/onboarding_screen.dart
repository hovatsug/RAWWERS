import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_progress.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

/// Getting a photographer live.
///
/// A checklist read from the server rather than a wizard with a step
/// index: the backend already computes what is outstanding from real
/// state, so this is resumable by construction. Close the app for a week
/// and it is where you left it; delete six portfolio photos and the step
/// reopens, which a stored position would never do.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    required this.profilePath,
    required this.portfolioPath,
    required this.pricingPath,
    super.key,
  });

  final String profilePath;
  final String portfolioPath;
  final String pricingPath;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Tell the backend which stages are now satisfied. The admin panel
    // reads the onboarding status, not the computed checks, so without
    // this every photographer looks untouched to whoever approves them.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(onboardingControllerProvider.future);
      } catch (_) {
        // The screen already renders the load failure with a retry. This
        // is bookkeeping on top of that, and letting it throw here would
        // surface an unhandled async error instead.
        return;
      }
      if (mounted) await ref.read(onboardingControllerProvider.notifier).syncStages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final profile = ref.watch(proProfileControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Getting set up')),
      body: SafeArea(
        child: switch (onboarding) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.read(onboardingControllerProvider.notifier).refresh(),
              child: _Checklist(
                checks: value.checks,
                profile: profile,
                profilePath: widget.profilePath,
                portfolioPath: widget.portfolioPath,
                pricingPath: widget.pricingPath,
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your progress.',
              onRetry: () => ref.invalidate(onboardingControllerProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: 240), SizedBox(height: RSpace.s16), RSkeleton(width: 200)],
              ),
            ),
        },
      ),
    );
  }
}

class _Checklist extends ConsumerWidget {
  const _Checklist({
    required this.checks,
    required this.profile,
    required this.profilePath,
    required this.portfolioPath,
    required this.pricingPath,
  });

  final Map<String, dynamic>? checks;
  final ProProfileView? profile;
  final String profilePath;
  final String portfolioPath;
  final String pricingPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final photos = checkCount(checks, 'portfolio_count');
    final photosNeeded = checkCount(checks, 'portfolio_min_required', fallback: 12);

    final steps = [
      _Step(
        title: 'Your profile',
        detail: 'Name, a line about you, and where you work.',
        done: checkDone(checks, 'profile_completed'),
        onTap: () => context.go(profilePath),
      ),
      _Step(
        title: 'Your portfolio',
        // The number, not a bar: "7 of 12" tells a photographer exactly how
        // much work is left in a way "58%" does not.
        detail: checkDone(checks, 'portfolio_uploaded')
            ? '$photos photos.'
            : '$photos of $photosNeeded photos.',
        done: checkDone(checks, 'portfolio_uploaded'),
        onTap: () => context.go(portfolioPath),
      ),
      _Step(
        title: 'What you charge',
        detail: 'At least one kind of shoot, priced.',
        done: checkDone(checks, 'packages_configured'),
        onTap: () => context.go(pricingPath),
      ),
      _Step(
        title: 'What you shoot',
        detail: 'The niches you want to be found under.',
        done: checkDone(checks, 'niches_selected'),
        onTap: () => context.go(profilePath),
      ),
    ];

    final doneCount = steps.where((s) => s.done).length;
    final readyForReview = checkDone(checks, 'ready_for_review');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                readyForReview ? 'You are ready to go live' : '$doneCount of ${steps.length} done',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: RSpace.s8),
              RProgressBar(value: steps.isEmpty ? 0 : doneCount / steps.length),
            ],
          ),
        ),
        const SizedBox(height: RSpace.s24),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: RSpace.s12),
              child: step,
            )),
        const SizedBox(height: RSpace.s12),
        _IdentityStep(checks: checks, profile: profile),
        const SizedBox(height: RSpace.s24),
        if (readyForReview)
          RButton(
            label: 'Put my listing live',
            onPressed: () async {
              final error = await ref.read(onboardingControllerProvider.notifier).goLive();
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.detail, required this.done, required this.onTap});

  final String title;
  final String detail;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              color: done ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: RSpace.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: RSpace.s4),
                  Text(detail, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// The identity check, presented as the real blocking step it is.
///
/// Not hidden and not dressed as an automatic verification: approval is a
/// person reading a submission, and for the first photographers that
/// person is someone at RAWWERS working through a queue by hand. Copy that
/// implied an instant check would have every one of them refreshing the
/// screen.
class _IdentityStep extends ConsumerWidget {
  const _IdentityStep({required this.checks, required this.profile});

  final Map<String, dynamic>? checks;
  final ProProfileView? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = profile?.kycStatus ?? 'unsubmitted';
    final submitted = checkDone(checks, 'kyc_submitted');
    final approved = checkDone(checks, 'kyc_approved');

    final (title, detail) = switch (status) {
      'approved' => ('Identity confirmed', 'You can take bookings.'),
      'pending' => (
          'Identity check in review',
          'Someone at RAWWERS reviews this by hand, so it is not instant. '
              'We will let you know as soon as it is done - you do not need '
              'to keep checking.',
        ),
      'rejected' => (
          'Identity check not approved',
          'Get in touch and we will go through what is missing.',
        ),
      _ => (
          'Identity check',
          'Required before your listing can go live. A person reviews it, '
              'so it takes a little time.',
        ),
    };

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                approved ? Icons.check_circle_outline : Icons.badge_outlined,
                color: approved ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: RSpace.s12),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: RSpace.s8),
          Text(detail, style: theme.textTheme.bodySmall),
          if (!submitted) ...[
            const SizedBox(height: RSpace.s16),
            RButton(
              label: 'Start identity check',
              variant: RButtonVariant.secondary,
              onPressed: () async {
                final error = await ref.read(onboardingControllerProvider.notifier).submitKyc();
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
