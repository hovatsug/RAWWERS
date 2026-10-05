import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/create_review_reply_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/shared/reviews/pro_reviews_controller.dart';

part 'reply_controller.g.dart';

sealed class ReplyState {
  const ReplyState();
}

class ReplyIdle extends ReplyState {
  const ReplyIdle();
}

class ReplySending extends ReplyState {
  const ReplySending();
}

class ReplyFailed extends ReplyState {
  const ReplyFailed(this.message);
  final String message;
}

enum ReplyOutcome { sent, alreadyReplied, failed }

/// Shown once the form has closed on [ReplyOutcome.alreadyReplied].
const alreadyRepliedMessage = "You've already replied to this review.";

/// A photographer's one reply to one review.
///
/// Like the client's review, nothing here records that a reply was posted.
/// Success refetches the photographer's reviews, and the reply appears
/// because the list now carries it.
@riverpod
class ReplyController extends _$ReplyController {
  @override
  ReplyState build(String reviewId) => const ReplyIdle();

  Future<ReplyOutcome> send({required String proUserId, required String text}) async {
    if (state is ReplySending) return ReplyOutcome.failed;
    state = const ReplySending();

    final result = await apiCall(
      () => ref.read(reviewsClientProvider).createReviewReplyV1ReviewsReviewIdReplyPost(
            reviewId: reviewId,
            requestBody: CreateReviewReplyRequest(text: text.trim()),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );

    switch (result) {
      case Ok():
        ref.invalidate(proReviewsProvider(proUserId));
        state = const ReplyIdle();
        return ReplyOutcome.sent;
      case Err(failure: BusinessError(code: 'already_exists')):
        ref.invalidate(proReviewsProvider(proUserId));
        state = const ReplyIdle();
        return ReplyOutcome.alreadyReplied;
      case Err(:final failure):
        state = ReplyFailed(switch (failure) {
          // The server's own words for its refusals - "hidden or removed",
          // "cannot be empty" - say exactly what went wrong.
          BusinessError(:final message) => message,
          NetworkError() || Timeout() => "Couldn't send your reply. Check your connection and try again.",
          _ => "Couldn't send your reply. Try again.",
        });
        return ReplyOutcome.failed;
    }
  }
}
