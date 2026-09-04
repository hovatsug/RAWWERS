import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/chat_message_create_v1_request.dart';
import 'package:rawwers/api/models/chat_thread_detail_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

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
