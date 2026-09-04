import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

/// Everything about the account that is not the work itself.
///
/// Leads with the two things a photographer actually comes here to check -
/// am I live, and where is my money going - rather than with the log-out
/// button. Each row states the real state and what it means; a status word
/// on its own ("pending") tells someone nothing about whether they should
/// be worried.
class ProSettingsScreen extends ConsumerWidget {
  const ProSettingsScreen({required this.verifyEmailPath, super.key});

  final String verifyEmailPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final me = switch (ref.watch(authControllerProvider).valueOrNull) {
      AuthAuthenticated(:final me) => me,
      _ => null,
    };
    final profile = ref.watch(proProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(proProfileControllerProvider);
            ref.invalidate(payoutAccountProvider);
            ref.invalidate(notificationPreferencesControllerProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(RSpace.s16),
            children: [
              _SectionLabel('Your listing'),
              switch (profile) {
                AsyncData(:final value) => _ListingStatus(profile: value),
                AsyncError() => const _Unavailable('Could not load your listing status.'),
                _ => const _LoadingCard(),
              },
              const SizedBox(height: RSpace.s24),
              _SectionLabel('Account'),
              RCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: 'Name', value: profile.valueOrNull?.displayName ?? '—'),
                    const Divider(height: RSpace.s24),
                    _Row(label: 'Email', value: me?.email ?? '—'),
                    const SizedBox(height: RSpace.s8),
                    if (me?.emailVerifiedAt != null)
                      Text('Verified', style: theme.textTheme.bodySmall)
                    else
                      RTextLink(label: 'Verify your email', onPressed: () => context.go(verifyEmailPath)),
                  ],
                ),
              ),
              const SizedBox(height: RSpace.s24),
              _SectionLabel('Payouts'),
              const _PayoutStatus(),
              const SizedBox(height: RSpace.s24),
              _SectionLabel('Notifications'),
              const _NotificationChannels(),
              const SizedBox(height: RSpace.s32),
              RButton(
                label: 'Log out',
                variant: RButtonVariant.secondary,
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingStatus extends StatelessWidget {
  const _ListingStatus({required this.profile});

  final ProProfileView profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = profile.isAcceptingBookings;
    final kyc = _kycDisplay(profile.kycStatus);

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  live ? 'Live — clients can book you' : 'Not live yet',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              RStatusChip(
                label: live ? 'Live' : 'Draft',
                kind: live ? RStatusChipKind.positive : RStatusChipKind.inProgress,
              ),
            ],
          ),
          const SizedBox(height: RSpace.s12),
          _Row(label: 'Identity check', value: kyc.$1),
          const SizedBox(height: RSpace.s4),
          Text(kyc.$2, style: theme.textTheme.bodySmall),
          const Divider(height: RSpace.s24),
          _Row(label: 'Profile completeness', value: '${profile.completenessScore}%'),
          const SizedBox(height: RSpace.s4),
          Text(
            profile.completenessScore >= 60
                ? 'Complete enough to go live.'
                : 'Needs to reach 60% before you can go live.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// KYC is a real wait, not a spinner. Approval is a person reading the
/// submission, so the copy says so rather than implying an automated check
/// that is about to come back.
(String, String) _kycDisplay(String status) => switch (status) {
      'approved' => ('Approved', 'You are verified and can take bookings.'),
      'pending' => ('In review', 'Someone at RAWWERS reviews this by hand. We will let you know as soon as it is done.'),
      'rejected' => ('Not approved', 'Get in touch and we will go through what is missing.'),
      _ => ('Not submitted', 'You will need this before your listing can go live.'),
    };

class _PayoutStatus extends ConsumerWidget {
  const _PayoutStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(payoutAccountProvider);
    final theme = Theme.of(context);

    return switch (account) {
      AsyncData(:final value) => RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(label: 'Payout account', value: _payoutLabel(value)),
              const SizedBox(height: RSpace.s4),
              Text(_payoutBody(value), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      AsyncError() => const _Unavailable('Could not load your payout account.'),
      _ => const _LoadingCard(),
    };
  }
}

String _payoutLabel(PayoutAccountView account) => switch (account.status) {
      PayoutAccountStatus.active => 'Ready',
      PayoutAccountStatus.pendingVerification => 'Being checked',
      PayoutAccountStatus.disabled => 'Not accepted',
      PayoutAccountStatus.notSet => 'Not set up',
    };

String _payoutBody(PayoutAccountView account) => switch (account.status) {
      PayoutAccountStatus.active => 'Withdrawals will reach this account.',
      PayoutAccountStatus.pendingVerification => 'You can keep earning; withdrawals unlock once this clears.',
      PayoutAccountStatus.disabled => 'Get in touch and we will sort it out.',
      // Bank-detail entry is deliberately not in the app yet (F-6), so this
      // says who to talk to rather than offering a form that does not exist.
      PayoutAccountStatus.notSet => 'Get in touch to set up where your earnings go.',
    };

class _NotificationChannels extends ConsumerWidget {
  const _NotificationChannels();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesControllerProvider);
    final notifier = ref.read(notificationPreferencesControllerProvider.notifier);
    final theme = Theme.of(context);

    return switch (prefs) {
      AsyncData(:final value) => RCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('In-app'),
                subtitle: Text('Booking requests and gig updates.', style: theme.textTheme.bodySmall),
                value: value.channelInappEnabled,
                onChanged: (on) => _save(context, notifier.setChannel(inApp: on)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Email'),
                // Honest: the outbox drains but no provider is configured,
                // so nothing is delivered yet. See docs/BACKEND_GAPS.md.
                subtitle: Text('Not being delivered yet — we are still setting this up.', style: theme.textTheme.bodySmall),
                value: value.channelEmailEnabled,
                onChanged: (on) => _save(context, notifier.setChannel(email: on)),
              ),
            ],
          ),
        ),
      AsyncError() => const _Unavailable('Could not load your notification settings.'),
      _ => const _LoadingCard(),
    };
  }

  void _save(BuildContext context, Future<String?> pending) {
    pending.then((error) {
      if (error == null || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RSpace.s8),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: RSpace.s12),
        Flexible(
          child: Text(value, style: theme.textTheme.bodyMedium, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RSkeleton(width: 160),
          SizedBox(height: RSpace.s12),
          RSkeleton(width: 240),
        ],
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return RCard(child: Text(message, style: Theme.of(context).textTheme.bodyMedium));
  }
}
