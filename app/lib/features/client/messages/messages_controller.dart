import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/chat_thread_summary.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/paging/cursor_page.dart';

part 'messages_controller.g.dart';

/// The client's own chat threads.
///
/// Ordered by `created_at`, not last activity - that is the endpoint's
/// ordering, chosen because a keyset cursor needs a stable sort key and
/// `updated_at` moves every time a message arrives. Thread counts per client
/// are small, so the difference is rarely visible.
@riverpod
class MessagesController extends _$MessagesController {
  @override
  Future<CursorPage<ChatThreadSummary>> build() async {
    final result = await _fetch(cursor: null);
    return switch (result) {
      Ok(:final value) => CursorPage(items: value.items, nextCursor: value.nextCursor),
      Err(:final failure) => throw failure,
    };
  }

  Future<Result<CursorFetchResult<ChatThreadSummary>>> _fetch({required String? cursor}) async {
    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.listMyChatThreadsV1ChatThreadsGet(
        // Closed threads are history a client may still want to reread, so
        // the list is unfiltered.
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
