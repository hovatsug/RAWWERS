import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/paging/cursor_page.dart';

part 'gigs_controller.g.dart';

/// The Gigs tab's coarse filter.
///
/// Not one chip per GigStatus - 15 chips is not a filter, it's a list of its
/// own. These group by what a photographer is actually looking for.
enum GigsFilter {
  active('Active'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const GigsFilter(this.label);

  final String label;

  /// The API filters by a single status, so a grouped filter can't be pushed
  /// down to the query. This is applied client-side over the fetched page,
  /// and the grouping is deliberately explicit rather than a negation: a new
  /// GigStatus added server-side should fall into `active` only if someone
  /// decides it belongs there, not by default.
  bool matches(GigStatus status) => switch (this) {
        GigsFilter.delivered => status == GigStatus.finalDelivered || status == GigStatus.completed,
        GigsFilter.cancelled => status == GigStatus.cancelledByClient ||
            status == GigStatus.cancelledByPro ||
            status == GigStatus.refunded ||
            status == GigStatus.disputed,
        GigsFilter.active => !GigsFilter.delivered.matches(status) && !GigsFilter.cancelled.matches(status),
      };
}

@riverpod
class GigsFilterController extends _$GigsFilterController {
  @override
  GigsFilter build() => GigsFilter.active;

  void select(GigsFilter filter) => state = filter;
}

/// Fetches one page of gigs. Shared by the Gigs tab and Today, which differ
/// only in the date bounds they pass.
Future<Result<CursorFetchResult<GigResponse>>> fetchGigsPage(
  Ref ref, {
  required String? cursor,
  DateTime? scheduledFrom,
  DateTime? scheduledTo,
}) async {
  final client = ref.read(gigsClientProvider);
  final result = await apiCall(
    () => client.listGigsV1GigsGet(
      status: null,
      scheduledFrom: scheduledFrom,
      scheduledTo: scheduledTo,
      cursor: cursor,
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => Ok(CursorFetchResult(items: value.items ?? const [], nextCursor: value.nextCursor)),
    Err(:final failure) => Err(failure),
  };
}

@riverpod
class GigsController extends _$GigsController {
  @override
  Future<CursorPage<GigResponse>> build() async {
    final result = await fetchGigsPage(ref, cursor: null);
    return switch (result) {
      Ok(:final value) => CursorPage(items: value.items, nextCursor: value.nextCursor),
      Err(:final failure) => throw failure,
    };
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));
    state = AsyncData(await appendNextPage(current, (cursor) => fetchGigsPage(ref, cursor: cursor)));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Gigs scheduled inside today, local time.
///
/// Bounds are computed from the device's local midnight and sent as UTC
/// instants, so "today" means the photographer's today rather than the
/// server's - a shoot at 09:00 in Lisbon should not appear on the wrong day
/// because the backend reasons in UTC.
@riverpod
class TodayController extends _$TodayController {
  @override
  Future<CursorPage<GigResponse>> build() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await fetchGigsPage(
      ref,
      cursor: null,
      scheduledFrom: startOfDay.toUtc(),
      scheduledTo: endOfDay.toUtc(),
    );
    return switch (result) {
      Ok(:final value) => CursorPage(items: value.items, nextCursor: value.nextCursor),
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
