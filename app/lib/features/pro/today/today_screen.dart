import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/gigs/widgets/gig_card.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';

/// The pro app's home. Answers two questions in order: what am I shooting
/// today, and is anything waiting on a decision.
///
/// Requests come second deliberately - they're time-boxed but not
/// time-of-day-bound, whereas a shoot at 09:00 is the thing that ruins the
/// morning if it's missed.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({required this.settingsPath, super.key});

  final String settingsPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayControllerProvider);
    final notifier = ref.read(todayControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          // Settings via the header avatar rather than a fifth tab - one
          // navigation system per app, four tabs maximum.
          IconButton(
            icon: const CircleAvatar(radius: 14, child: Icon(Icons.person_outline, size: 18)),
            tooltip: 'Profile and settings',
            onPressed: () => context.push(settingsPath),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.refresh();
            await ref.read(requestsControllerProvider.notifier).refresh();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(RSpace.s16),
            children: [
              Text('Your shoots today', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: RSpace.s12),
              switch (today) {
                AsyncLoading() => const _InlineSkeleton(),
                AsyncError(:final error) => PagedListError(error: error, onRetry: notifier.refresh),
                AsyncData(:final value) => value.isEmpty
                    ? const _NothingToday()
                    : Column(
                        children: [
                          for (final gig in value.items) ...[
                            GigCard(gig: gig),
                            const SizedBox(height: RSpace.s12),
                          ],
                        ],
                      ),
                _ => const SizedBox.shrink(),
              },
              const SizedBox(height: RSpace.s24),
              const _PendingRequestsSummary(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NothingToday extends StatelessWidget {
  const _NothingToday();

  @override
  Widget build(BuildContext context) {
    return RCard(
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined),
          const SizedBox(width: RSpace.s12),
          Expanded(
            child: Text(
              'Nothing scheduled today.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A count, not a second copy of the Requests list.
///
/// Duplicating the list here would mean two places to accept from and two
/// places to keep in sync; this is a pointer to where the work is done.
class _PendingRequestsSummary extends ConsumerWidget {
  const _PendingRequestsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(requestsFilterControllerProvider);
    final requests = ref.watch(requestsControllerProvider);

    // The Requests provider is filter-scoped, so this only reflects pending
    // when that's the selected filter. Showing a count derived from, say, the
    // declined list would be worse than showing none.
    if (filter != RequestsFilter.pending) return const SizedBox.shrink();

    return switch (requests) {
      AsyncData(:final value) when value.items.isNotEmpty => RCard(
          child: Row(
            children: [
              const Icon(Icons.mark_email_unread_outlined),
              const SizedBox(width: RSpace.s12),
              Expanded(
                child: Text(
                  value.items.length == 1
                      ? '1 request is waiting on you.'
                      : '${value.items.length} requests are waiting on you.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _InlineSkeleton extends StatelessWidget {
  const _InlineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 160, child: PagedListSkeleton(itemCount: 1));
  }
}
