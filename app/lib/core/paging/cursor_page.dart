import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/result.dart';

/// State for a cursor-paginated list.
///
/// Every list endpoint in this API returns the same envelope - `items` plus a
/// nullable `next_cursor` - so the four pro tabs share this rather than each
/// reimplementing append/end-of-list/retry.
///
/// `nextCursor == null` means the end, definitively: the backend returns null
/// on the last page rather than a cursor that would fetch nothing, so a UI
/// can stop on the null instead of paging into an empty response to discover
/// it (see api/app/services/pagination.py, build_page).
class CursorPage<T> {
  const CursorPage({
    this.items = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final List<T> items;
  final String? nextCursor;

  /// Appending a further page. Distinct from the whole list loading: the
  /// first load shows skeletons, a later page shows a footer spinner with
  /// the existing rows still on screen.
  final bool isLoadingMore;

  /// A failed *append*, kept separate from a failed first load. Losing the
  /// rows already on screen because page three timed out would be a worse
  /// outcome than showing them with a retry under them.
  final ApiFailure? loadMoreFailure;

  bool get hasMore => nextCursor != null;
  bool get isEmpty => items.isEmpty;

  CursorPage<T> copyWith({
    List<T>? items,
    String? nextCursor,
    bool? isLoadingMore,
    ApiFailure? loadMoreFailure,
    bool clearNextCursor = false,
    bool clearLoadMoreFailure = false,
  }) {
    return CursorPage<T>(
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailure: clearLoadMoreFailure ? null : (loadMoreFailure ?? this.loadMoreFailure),
    );
  }
}

/// One page as returned by a fetch function: the rows plus where to continue.
class CursorFetchResult<T> {
  const CursorFetchResult({required this.items, this.nextCursor});

  final List<T> items;
  final String? nextCursor;
}

/// Fetches one page. `cursor` is null for the first page.
typedef CursorFetcher<T> = Future<Result<CursorFetchResult<T>>> Function(String? cursor);

/// Appends the next page onto [current], via [fetch].
///
/// Returns the same page unchanged when there is nothing more to fetch or a
/// fetch is already in flight - so a scroll listener firing repeatedly near
/// the bottom cannot stack duplicate requests, which would both waste calls
/// and append the same rows twice.
///
/// A `Validation` failure here is special-cased. The backend rejects an
/// unparseable cursor with a 422 rather than silently restarting (see
/// api/app/services/pagination.py, decode_cursor), so a cursor this client
/// can no longer use - stale across a deploy, or truncated - must drop the
/// cursor and stop, not retry the same bad value forever.
Future<CursorPage<T>> appendNextPage<T>(
  CursorPage<T> current,
  CursorFetcher<T> fetch,
) async {
  if (!current.hasMore || current.isLoadingMore) return current;

  final loading = current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true);
  final result = await fetch(current.nextCursor);

  switch (result) {
    case Ok(:final value):
      return CursorPage<T>(
        items: [...loading.items, ...value.items],
        nextCursor: value.nextCursor,
        isLoadingMore: false,
      );
    case Err(:final failure):
      if (failure is Validation) {
        // The cursor itself is bad. Keep the rows already loaded, but stop
        // offering to load more with a value the server will keep rejecting.
        return loading.copyWith(isLoadingMore: false, clearNextCursor: true);
      }
      return loading.copyWith(isLoadingMore: false, loadMoreFailure: failure);
  }
}
