import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/core/paging/offset_page.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/discover/discover_controller.dart';
import 'package:rawwers/features/client/discover/location_controller.dart';
import 'package:rawwers/features/shared/discover/discover_card.dart';
import 'package:rawwers/features/client/discover/widgets/location_prompt.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          if (location.valueOrNull != null)
            TextButton(
              onPressed: () => _changeLocation(context, ref),
              child: Text(location.valueOrNull!.city),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (location) {
          AsyncLoading() => const PagedListSkeleton(),
          // A location we can't read isn't a dead end - asking is the same
          // thing we'd do if it were simply unset.
          AsyncError() => const LocationPrompt(),
          AsyncData(value: null) => const LocationPrompt(),
          AsyncData() => const _Results(),
          _ => const PagedListSkeleton(),
        },
      ),
    );
  }

  void _changeLocation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: const LocationPrompt(),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(discoverControllerProvider);
    final notifier = ref.read(discoverControllerProvider.notifier);

    return Column(
      children: [
        const _SearchBar(),
        Expanded(
          child: switch (page) {
            AsyncLoading() => const PagedListSkeleton(),
            // LocationNotSet is a state, not a failure - it means the
            // location was cleared while results were on screen.
            AsyncError(:final error) when error is LocationNotSet => const LocationPrompt(),
            AsyncError(:final error) => PagedListError(error: error, onRetry: notifier.refresh),
            AsyncData(:final value) => _Grid(page: value),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RSpace.s16, vertical: RSpace.s8),
      child: RInput(
        label: 'Search photographers',
        controller: _query,
        textInputAction: TextInputAction.search,
        // Committed on submit rather than on every keystroke: each change
        // refetches, and searching per character would issue a request per
        // letter typed.
        onSubmitted: (value) => ref.read(discoverFiltersControllerProvider.notifier).setQuery(value),
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({required this.page});

  final OffsetPage<ClientDiscoverCard> page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(discoverControllerProvider.notifier);
    final theme = Theme.of(context);

    if (page.isEmpty) {
      return RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 360,
              child: REmptyState(
                title: 'No photographers here yet',
                body: 'Try a different search, or check back - we\'re still adding people in your city.',
                icon: Icons.search_off_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(RSpace.s16),
        // +1 header for the count, +1 footer when more can be loaded.
        itemCount: page.items.length + 1 + (page.hasMore || page.loadMoreFailure != null ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: RSpace.s12),
        itemBuilder: (context, index) {
          if (index == 0) {
            // The server's total, not items.length - saying "12 found" while
            // 20 are loaded would be worse than saying nothing.
            return Text(
              page.total == 1 ? '1 photographer' : '${page.total} photographers',
              style: theme.textTheme.bodySmall,
            );
          }
          final itemIndex = index - 1;
          if (itemIndex >= page.items.length) {
            return _LoadMore(page: page, onLoadMore: notifier.loadMore);
          }
          final card = page.items[itemIndex];
          return DiscoverCard(
            card: card,
            onTap: () => context.push(ClientRoute.proProfile(card.proUserId)),
          );
        },
      ),
    );
  }
}

class _LoadMore extends StatelessWidget {
  const _LoadMore({required this.page, required this.onLoadMore});

  final OffsetPage<ClientDiscoverCard> page;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (page.loadMoreFailure != null) {
      return Column(
        children: [
          Text(
            pagingFailureMessage(page.loadMoreFailure!),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RSpace.s8),
          RButton(label: 'Try again', onPressed: onLoadMore, variant: RButtonVariant.secondary),
        ],
      );
    }
    if (page.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: RSpace.s24),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    return RButton(label: 'Load more', onPressed: onLoadMore, variant: RButtonVariant.secondary);
  }
}
