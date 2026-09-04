import 'package:flutter/material.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/paging/cursor_page.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';

/// The four pro tabs are all "a cursor-paginated list with loading, error,
/// empty and load-more states". This holds that shape once so a fix to, say,
/// how a failed second page behaves lands everywhere rather than in whichever
/// screen someone remembered.
class PagedListView<T> extends StatelessWidget {
  const PagedListView({
    required this.page,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.emptyTitle,
    this.emptyBody,
    this.emptyIcon = Icons.inbox_outlined,
    super.key,
  });

  final CursorPage<T> page;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final String emptyTitle;
  final String? emptyBody;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    if (page.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        // AlwaysScrollableScrollPhysics with a tall child: an empty state that
        // doesn't scroll can't be pulled, which would kill pull-to-refresh
        // exactly where someone most wants to retry.
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 360,
              child: REmptyState(title: emptyTitle, body: emptyBody, icon: emptyIcon),
            ),
          ],
        ),
      );
    }

    final hasFooter = page.hasMore || page.loadMoreFailure != null;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(RSpace.s16),
        itemCount: page.items.length + (hasFooter ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: RSpace.s12),
        itemBuilder: (context, index) {
          if (index >= page.items.length) {
            return _LoadMoreFooter(page: page, onLoadMore: onLoadMore);
          }
          return itemBuilder(context, page.items[index]);
        },
      ),
    );
  }
}

class _LoadMoreFooter<T> extends StatelessWidget {
  const _LoadMoreFooter({required this.page, required this.onLoadMore});

  final CursorPage<T> page;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (page.loadMoreFailure != null) {
      // Rows already fetched stay on screen. Replacing a loaded list with a
      // full-screen error because page three timed out loses more than it
      // explains.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: RSpace.s16),
        child: Column(
          children: [
            Text(
              pagingFailureMessage(page.loadMoreFailure!),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RSpace.s8),
            RButton(label: 'Try again', onPressed: onLoadMore, variant: RButtonVariant.secondary),
          ],
        ),
      );
    }

    if (page.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: RSpace.s24),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    // An explicit button, not a scroll-position trigger: an automatic fetch
    // that fails near the bottom leaves the user nothing to press.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RSpace.s8),
      child: RButton(label: 'Load more', onPressed: onLoadMore, variant: RButtonVariant.secondary),
    );
  }
}

/// Card-shaped placeholders for a first load.
class PagedListSkeleton extends StatelessWidget {
  const PagedListSkeleton({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(RSpace.s16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: RSpace.s12),
      itemBuilder: (context, index) => const RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RSkeleton(width: 180),
            SizedBox(height: RSpace.s8),
            RSkeleton(width: 120),
            SizedBox(height: RSpace.s16),
            RSkeleton(height: RSpace.s32),
          ],
        ),
      ),
    );
  }
}

/// Full-screen error for a failed *first* load, where there is nothing to keep.
class PagedListError extends StatelessWidget {
  const PagedListError({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RErrorState(message: pagingFailureMessage(error), onRetry: onRetry);
  }
}

/// One place that turns a transport failure into something a person reads.
String pagingFailureMessage(Object error) {
  if (error is! ApiFailure) return 'Something went wrong. Please try again.';
  return switch (error) {
    Unauthorized() => 'Your session expired. Log in again to continue.',
    NetworkError() => 'No connection - check your network and try again.',
    Timeout() => 'That took too long - try again.',
    RateLimited() => 'Too many requests just now. Give it a moment.',
    BusinessError(:final message) => message,
    _ => 'Something went wrong. Please try again.',
  };
}
