import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/create_review_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/shared/reviews/pro_reviews_controller.dart';

part 'review_controller.g.dart';

/// Gig statuses the backend accepts a review for - `_is_reviewable_gig` in
/// api/app/api/v1/reviews.py. Mirrored only to decide whether to *offer* the
/// form; the server still decides whether to take it, and a refusal is shown
/// rather than hidden, so drift here costs a message, not a wrong review.
const reviewableGigStatuses = {'completed', 'final_delivered'};

sealed class ReviewSubmitState {
  const ReviewSubmitState();
}

class ReviewIdle extends ReviewSubmitState {
  const ReviewIdle();
}

class ReviewSending extends ReviewSubmitState {
  const ReviewSending();
}

class ReviewFailed extends ReviewSubmitState {
  const ReviewFailed(this.message);
  final String message;
}

/// How a submission ended, for the form to act on.
enum ReviewSubmitOutcome {
  /// The server took it. The form closes; the refetched booking shows it.
  sent,

  /// The server already holds a review for this booking. The form closes too
  /// - there is nothing left to fill in - and the refetched booking shows the
  /// review that exists.
  alreadyReviewed,

  /// Refused or unreachable. The form stays, words intact, with the reason.
  failed,
}

/// Sends a client's review of one booking.
///
/// There is no "submitted" state here on purpose. Success refetches the
/// booking, and the booking's own `review` is what turns the prompt into
/// "your review" - so the screen can only ever show a review the server holds.
@riverpod
class ReviewSubmitController extends _$ReviewSubmitController {
  @override
  ReviewSubmitState build(String bookingId) => const ReviewIdle();

  Future<ReviewSubmitOutcome> submit({
    required String gigId,
    required int rating,
    required bool wouldBookAgain,
    String? text,
  }) async {
    if (state is ReviewSending) return ReviewSubmitOutcome.failed;
    state = const ReviewSending();

    final words = text?.trim();
    final result = await apiCall(
      () => ref.read(reviewsClientProvider).createReviewForGigV1GigsGigIdReviewPost(
            gigId: gigId,
            // Tags and video exist in the model with nothing to fill them: no
            // tag vocabulary, no review-video upload. Sent empty rather than
            // invented.
            requestBody: CreateReviewRequest(
              rating: rating,
              text: words == null || words.isEmpty ? null : words,
              // Always sent. The API defaults this to true, so leaving it to
              // the default would record "would book again" for everyone who
              // was never asked.
              wouldBookAgain: wouldBookAgain,
            ),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );

    switch (result) {
      case Ok(:final value):
        ref.invalidate(bookingDetailProvider(bookingId));
        ref.invalidate(proReviewsProvider(value.proUserId));
        state = const ReviewIdle();
        return ReviewSubmitOutcome.sent;
      case Err(:final failure):
        // Already reviewed - from another device, or a response that never
        // arrived. Refetch so the screen shows that review instead of a form.
        if (failure case BusinessError(code: 'already_exists')) {
          ref.invalidate(bookingDetailProvider(bookingId));
          state = const ReviewIdle();
          return ReviewSubmitOutcome.alreadyReviewed;
        }
        state = ReviewFailed(_messageFor(failure));
        return ReviewSubmitOutcome.failed;
    }
  }
}

/// Shown once the form has closed on [ReviewSubmitOutcome.alreadyReviewed].
const alreadyReviewedMessage = "You've already reviewed this booking.";

String _messageFor(ApiFailure failure) => switch (failure) {
      BusinessError(code: 'invalid_state') => "This booking can't be reviewed yet.",
      BusinessError(:final message, :final status) when status == 422 => message,
      RateLimited() => "You've left a lot of reviews today. Try again tomorrow.",
      NetworkError() || Timeout() => "Couldn't send your review. Check your connection and try again.",
      _ => "Couldn't send your review. Try again.",
    };
