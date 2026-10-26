import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/core/router/app_router_pro.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/gigs/widgets/gig_card.dart';

part 'next_shoot.g.dart';

/// At most this many pages are read looking for the next shoot. The list is
/// paged by when a booking was made, not when it is shot, so the soonest
/// shoot can be on any page; a photographer with more upcoming shoots than
/// this is not one this screen has met.
const _maxPages = 5;

/// The photographer's next shoot: the soonest one still to happen, from the
/// same gigs list the Gigs tab reads (only those from now on). Null when
/// none is booked.
@riverpod
Future<GigResponse?> nextShoot(Ref ref) async {
  final now = DateTime.now().toUtc();
  final upcoming = <GigResponse>[];
  String? cursor;
  for (var page = 0; page < _maxPages; page++) {
    final result = await fetchGigsPage(ref, cursor: cursor, scheduledFrom: now);
    switch (result) {
      case Ok(:final value):
        upcoming.addAll(value.items);
        cursor = value.nextCursor;
      case Err(:final failure):
        throw failure;
    }
    if (cursor == null) break;
  }
  final active = upcoming.where((g) => g.scheduledStart != null && GigsFilter.active.matches(g.status)).toList()
    ..sort((a, b) => a.scheduledStart!.compareTo(b.scheduledStart!));
  return active.firstOrNull;
}

class NextShootCard extends ConsumerWidget {
  const NextShootCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return switch (ref.watch(nextShootProvider)) {
      AsyncData(value: final gig?) => GigCard(gig: gig, onTap: () => context.push(ProRoute.gigDelivery, extra: gig)),
      AsyncData() => RCard(child: Text('No shoots booked yet.', style: theme.textTheme.bodyMedium)),
      AsyncError(:final error) => PagedListError(error: error, onRetry: () => ref.invalidate(nextShootProvider)),
      _ => const RSkeleton(height: RSpace.s64 + RSpace.s48),
    };
  }
}
