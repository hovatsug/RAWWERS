import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/my_findings_response.dart';
import 'package:rawwers/api/models/response_in.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'findings_controller.g.dart';

/// The photographer's own findings, strike count and any booking pause.
/// Only theirs: the server never returns anyone else's, and nothing here is
/// shown to clients.
@riverpod
class FindingsController extends _$FindingsController {
  @override
  Future<MyFindingsResponse> build() async {
    final result = await apiCall(
      () => ref.read(accountabilityClientProvider).myFindingsV1ProFindingsGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Seeing a finding starts the window to respond, so this is sent the
  /// first time the card is on screen - never on the photographer's behalf
  /// before that. The server ignores a second call.
  Future<void> markSeen(String findingId) async {
    await apiCall(
      () => ref.read(accountabilityClientProvider).markFindingSeenV1ProFindingsFindingIdSeenPost(
            findingId: findingId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
  }

  /// Returns an error message, or null.
  Future<String?> respond(String findingId, String text) async {
    final result = await apiCall(
      () => ref.read(accountabilityClientProvider).respondToFindingV1ProFindingsFindingIdResponsePost(
            requestBody: ResponseIn(text: text),
            findingId: findingId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    if (result case Err(:final failure)) {
      return failure is BusinessError ? failure.message : 'Your response could not be sent. Try again.';
    }
    ref.invalidateSelf();
    return null;
  }
}
