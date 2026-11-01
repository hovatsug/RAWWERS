import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/create_problem_report_request.dart';
import 'package:rawwers/api/models/create_review_request.dart';
import 'package:rawwers/api/models/problem_report_reason.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';

part 'unlock_controller.g.dart';

/// The review gate's two ways through, for one delivered gallery: a star
/// rating, or "Report a problem". Either one unlocks the originals on the
/// server; this then reloads the gallery so the photos appear.
///
/// The server decides; nothing here unlocks anything on its own. A refusal
/// is returned as the message to show.
@riverpod
class UnlockController extends _$UnlockController {
  @override
  bool build(String galleryId) => false; // sending

  /// One tap on a star: a rating with nothing else. Returns null when the
  /// photos are unlocked, otherwise what to tell the client.
  Future<String?> rate({required String gigId, required int stars}) => _send(() async {
        final result = await apiCall(
          () => ref.read(reviewsClientProvider).createReviewForGigV1GigsGigIdReviewPost(
                // One tap does not ask "would you book again?", and the API
                // records true unless told otherwise. Read from the stars
                // instead: 4 or 5 is a yes. (Owner to confirm.)
                requestBody: CreateReviewRequest(rating: stars, wouldBookAgain: stars >= 4),
                gigId: gigId,
                authorization: null,
                xMinusUserMinusId: null,
              ),
        );
        return switch (result) {
          Ok() => null,
          // Rated already (another device, an earlier try): the photos are
          // unlocked, which is what was wanted.
          Err(failure: BusinessError(code: 'already_exists')) => null,
          Err(:final failure) => _explain(failure),
        };
      });

  /// "Report a problem": unlocks too, and an admin looks at it.
  Future<String?> report({required String gigId, required ProblemReportReason reason, String? note}) => _send(() async {
        final trimmed = note?.trim();
        final result = await apiCall(
          () => ref.read(reviewsClientProvider).reportAProblemV1GigsGigIdProblemReportPost(
                requestBody: CreateProblemReportRequest(reason: reason, note: (trimmed?.isEmpty ?? true) ? null : trimmed),
                gigId: gigId,
                authorization: null,
                xMinusUserMinusId: null,
              ),
        );
        return switch (result) {
          Ok() => null,
          Err(failure: BusinessError(code: 'already_exists')) => null,
          Err(:final failure) => _explain(failure),
        };
      });

  Future<String?> _send(Future<String?> Function() call) async {
    if (state) return 'Already sending.';
    state = true;
    try {
      final problem = await call();
      if (problem == null) ref.invalidate(deliveredControllerProvider(galleryId));
      return problem;
    } finally {
      state = false;
    }
  }

  String _explain(ApiFailure failure) => switch (failure) {
        NetworkError() || Timeout() => 'Could not reach RAWWERS. Check your connection and try again.',
        BusinessError(:final message) => message,
        RateLimited() => 'Too many tries. Wait a moment and try again.',
        _ => 'That did not go through. Try again.',
      };
}
