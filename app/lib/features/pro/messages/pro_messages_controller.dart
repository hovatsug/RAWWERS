import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/chat_message_create_v1_request.dart';
import 'package:rawwers/api/models/chat_thread_detail_response.dart';
import 'package:rawwers/api/models/chat_thread_summary.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/shared/chat/chat_side.dart' show chatMessageMaxLength;

part 'pro_messages_controller.g.dart';

/// The photographer's conversations, newest activity first, each with what
/// they have not read. Server-ordered; the app does not re-sort.
@riverpod
class ProMessagesController extends _$ProMessagesController {
  @override
  Future<List<ChatThreadSummary>> build() async {
    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.listProThreadsV1ProChatThreadsGet(status: null, authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// The Messages tab's badge: conversations with something unread.
///
/// Polled every 30 seconds while the app is running - with no push yet, this
/// is how a photographer with the app open learns a client wrote. Kept alive
/// so the badge stays current on every tab, not only on Messages.
@Riverpod(keepAlive: true)
class ProUnreadController extends _$ProUnreadController {
  static const pollEvery = Duration(seconds: 30);
  Timer? _timer;

  @override
  Future<int> build() async {
    _timer ??= Timer.periodic(pollEvery, (_) => ref.invalidateSelf());
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.proUnreadMessagesV1ProChatUnreadGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value.threads,
      // A badge that cannot load shows nothing rather than an error on
      // every tab.
      Err() => state.valueOrNull ?? 0,
    };
  }
}

/// One conversation, from the photographer's side.
@riverpod
class ProThreadController extends _$ProThreadController {
  @override
  Future<ChatThreadDetailResponse> build(String threadId) async {
    final result = await _fetch(threadId);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<Result<ChatThreadDetailResponse>> _fetch(String threadId) {
    final client = ref.read(aiConciergeClientProvider);
    return apiCall(
      () => client.getProThreadV1ProChatThreadsThreadIdGet(threadId: threadId, authorization: null, xMinusUserMinusId: null),
    );
  }

  /// Picks up new messages without a loading flash; a failed poll keeps
  /// what is on screen.
  Future<void> refreshQuietly() async {
    if (await _fetch(threadId) case Ok(:final value)) state = AsyncData(value);
  }

  /// Tells the server this side has read the conversation so far. A failed
  /// save leaves a stale unread count that the next open corrects - never
  /// worth an error in front of someone reading their messages.
  Future<void> markRead() async {
    final client = ref.read(aiConciergeClientProvider);
    await apiCall(
      () => client.markChatThreadReadV1ChatThreadsThreadIdReadPost(threadId: threadId, authorization: null, xMinusUserMinusId: null),
    );
  }

  /// Sends a reply. Answering is also what takes the conversation over from
  /// the assistant - the server marks it photographer-active.
  Future<String?> send(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;
    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.postProMessageV1ProChatThreadsThreadIdMessagesPost(
        threadId: threadId,
        requestBody: ChatMessageCreateV1Request(content: trimmed),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Not sent - check your connection.',
          RateLimited() => 'Slow down a moment, then send again.',
          Validation() => 'Too long - messages can be at most $chatMessageMaxLength characters.',
          _ => 'That message could not be sent.',
        };
      case Ok(:final value):
        final current = state.valueOrNull;
        if (current != null) {
          state = AsyncData(current.copyWith(messages: [...current.messages ?? const [], value]));
        } else {
          ref.invalidateSelf();
        }
        return null;
    }
  }
}
