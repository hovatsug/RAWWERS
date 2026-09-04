import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/core/paging/cursor_page.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/core/router/app_router_pro.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/gigs/widgets/gig_card.dart';

class GigsScreen extends ConsumerWidget {
  const GigsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(gigsControllerProvider);
    final filter = ref.watch(gigsFilterControllerProvider);
    final notifier = ref.read(gigsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Gigs')),
      body: SafeArea(
        child: Column(
          children: [
            _FilterBar(selected: filter),
            Expanded(
              child: switch (page) {
                AsyncLoading() => const PagedListSkeleton(),
                AsyncError(:final error) => PagedListError(error: error, onRetry: notifier.refresh),
                AsyncData(:final value) => PagedListView<GigResponse>(
                    // Grouped filters can't be pushed into the query (the API
                    // filters by a single status), so this narrows the fetched
                    // page. hasMore/nextCursor stay the server's, so paging
                    // still walks the whole list rather than stopping at the
                    // first page that happens to filter down to nothing.
                    page: _filtered(value, filter),
                    onRefresh: notifier.refresh,
                    onLoadMore: notifier.loadMore,
                    emptyTitle: _emptyTitle(filter),
                    emptyBody: _emptyBody(filter),
                    emptyIcon: Icons.camera_outlined,
                    itemBuilder: (context, gig) => GigCard(
                      gig: gig,
                      onTap: () => context.push(ProRoute.gigDelivery, extra: gig),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

CursorPage<GigResponse> _filtered(CursorPage<GigResponse> page, GigsFilter filter) {
  return page.copyWith(items: page.items.where((gig) => filter.matches(gig.status)).toList());
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.selected});

  final GigsFilter selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: RSpace.s16, vertical: RSpace.s8),
      child: Row(
        children: [
          for (final filter in GigsFilter.values) ...[
            RFilterChip(
              label: filter.label,
              selected: filter == selected,
              onPressed: () => ref.read(gigsFilterControllerProvider.notifier).select(filter),
            ),
            const SizedBox(width: RSpace.s8),
          ],
        ],
      ),
    );
  }
}

String _emptyTitle(GigsFilter filter) => switch (filter) {
      GigsFilter.active => 'No gigs on the go',
      GigsFilter.delivered => 'Nothing delivered yet',
      GigsFilter.cancelled => 'Nothing cancelled',
    };

String? _emptyBody(GigsFilter filter) => switch (filter) {
      GigsFilter.active => 'Accepted requests become gigs here once the client has paid.',
      GigsFilter.delivered => 'Gigs you have delivered and closed out will be listed here.',
      GigsFilter.cancelled => null,
    };
