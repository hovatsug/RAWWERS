import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_booking_list_item.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/paging/cursor_page.dart';

part 'bookings_controller.g.dart';

/// The client's own bookings, newest first.
///
/// Unfiltered on purpose, unlike the pro's Requests tab. A photographer opens
/// their queue to answer "what needs me" and so defaults to pending; a client
/// opens this to answer "where are my shoots up to", and a booking they are
/// waiting on, one they need to pay for, and one that was delivered last week
/// all belong in that answer. `?status=` exists on the endpoint if a filter is
/// wanted later.
@riverpod
class BookingsController extends _$BookingsController {
  @override
  Future<CursorPage<ClientBookingListItem>> build() async {
    final result = await _fetch(cursor: null);
    return switch (result) {
      Ok(:final value) => CursorPage(items: value.items, nextCursor: value.nextCursor),
      Err(:final failure) => throw failure,
    };
  }

  Future<Result<CursorFetchResult<ClientBookingListItem>>> _fetch({required String? cursor}) async {
    final client = ref.read(clientLaunchClientProvider);
    final result = await apiCall(
      () => client.listClientBookingsV1ClientBookingsGet(
        status: null,
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

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));
    state = AsyncData(await appendNextPage(current, (cursor) => _fetch(cursor: cursor)));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
