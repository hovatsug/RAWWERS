import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/result.dart';

/// State for an offset-paginated list.
///
/// Separate from [CursorPage] because `GET /v1/client/discover` is the one
/// list endpoint that takes `limit`/`offset` and returns a `total`, rather
/// than the `{items, next_cursor}` envelope everything else uses. That is a
/// defensible difference rather than an oversight: a browse-and-filter
/// surface genuinely wants a result count ("2 photographers in New York"),
/// and a keyset cursor cannot produce one.
///
/// The cost is the standard offset problem — if the underlying set changes
/// between pages, a row can be skipped or repeated. For a ranked discovery
/// feed that is tolerable; for a booking queue it would not be, which is why
/// those endpoints use a cursor instead.
class OffsetPage<T> {
  const OffsetPage({
    this.items = const [],
    this.total = 0,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final List<T> items;

  /// Total matching the current filters, server-side — not `items.length`.
  /// This is what lets the UI say how many results exist before they're all
  /// loaded.
  final int total;

  final bool isLoadingMore;
  final ApiFailure? loadMoreFailure;

  /// More to fetch, judged against the server's total rather than against
  /// whether the last page came back full. A page that happens to land
  /// exactly on the boundary would otherwise look like the end.
  bool get hasMore => items.length < total;

  bool get isEmpty => items.isEmpty;

  /// Where the next request starts. Derived from what is loaded rather than
  /// tracked separately, so it cannot drift out of step with `items`.
  int get nextOffset => items.length;

  OffsetPage<T> copyWith({
    List<T>? items,
    int? total,
    bool? isLoadingMore,
    ApiFailure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) {
    return OffsetPage<T>(
      items: items ?? this.items,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailure: clearLoadMoreFailure ? null : (loadMoreFailure ?? this.loadMoreFailure),
    );
  }
}

class OffsetFetchResult<T> {
  const OffsetFetchResult({required this.items, required this.total});

  final List<T> items;
  final int total;
}

/// Fetches one page starting at [offset].
typedef OffsetFetcher<T> = Future<Result<OffsetFetchResult<T>>> Function(int offset);

/// Appends the next page onto [current].
///
/// Returns [current] unchanged when there is nothing more or a fetch is
/// already running, so a repeated tap or scroll trigger cannot stack requests
/// and append the same rows twice.
Future<OffsetPage<T>> appendNextOffsetPage<T>(
  OffsetPage<T> current,
  OffsetFetcher<T> fetch,
) async {
  if (!current.hasMore || current.isLoadingMore) return current;

  final loading = current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true);
  final result = await fetch(current.nextOffset);

  switch (result) {
    case Ok(:final value):
      return OffsetPage<T>(
        items: [...loading.items, ...value.items],
        // Take the server's fresh total: the result set can change size
        // between pages, and a stale total would leave hasMore wrong in
        // either direction.
        total: value.total,
        isLoadingMore: false,
      );
    case Err(:final failure):
      // Rows already loaded stay; only the append failed.
      return loading.copyWith(isLoadingMore: false, loadMoreFailure: failure);
  }
}
