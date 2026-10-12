import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/chat_message_create_v1_request.dart';
import 'package:rawwers/api/models/chat_thread_detail_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/shared/chat/chat_side.dart' show chatMessageMaxLength;

part 'thread_controller.g.dart';

/// One conversation, with its messages.
@riverpod
class ThreadController extends _$ThreadController {
  @override
  Future<ChatThreadDetailResponse> build(String threadId) async {
    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.getChatThreadV1V1ChatThreadsThreadIdGet(
        threadId: threadId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
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

  /// Picks up new messages without a loading flash; a failed poll keeps
  /// what is on screen.
  Future<void> refreshQuietly() async {
    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.getChatThreadV1V1ChatThreadsThreadIdGet(threadId: threadId, authorization: null, xMinusUserMinusId: null),
    );
    if (result case Ok(:final value)) state = AsyncData(value);
  }

  /// Sends a message and folds the server's own copy of it into the thread.
  ///
  /// The response is the persisted message, so the sent bubble carries the
  /// real id and timestamp rather than an optimistic guess that a refetch
  /// would then replace. Returns an error string on failure so the composer
  /// can keep the text the person typed - losing a message someone wrote
  /// because the network blinked is worse than any spinner.
  Future<String?> send(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.postChatMessageV1V1ChatThreadsThreadIdMessagesPost(
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
          Forbidden() || Unauthorized() => 'You can no longer post in this conversation.',
          BusinessError() => 'This conversation is closed.',
          _ => 'That message could not be sent.',
        };
      case Ok(:final value):
        final current = state.valueOrNull;
        if (current != null) {
          state = AsyncData(
            current.copyWith(messages: [...current.messages ?? const [], value]),
          );
        } else {
          ref.invalidateSelf();
        }
        return null;
    }
  }
}
