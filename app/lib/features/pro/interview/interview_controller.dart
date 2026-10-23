import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/interview_draft_in.dart';
import 'package:rawwers/api/models/my_interview_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'interview_controller.g.dart';

/// The photographer's "Meet the photographer" interview: their drafts, what
/// clients currently read, and whether the two differ - all the server's.
@riverpod
class InterviewController extends _$InterviewController {
  @override
  Future<MyInterviewView> build() async {
    final client = ref.read(meetClientProvider);
    final result = await apiCall(() => client.myInterviewV1ProMeInterviewGet(authorization: null, xMinusUserMinusId: null));
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Saves drafts (question id -> text). Returns an error to show, or null.
  Future<String?> save(Map<String, String?> answers) => _run(
        () => ref.read(meetClientProvider).saveInterviewV1ProMeInterviewPut(
              requestBody: InterviewDraftIn(answers: answers),
              authorization: null,
              xMinusUserMinusId: null,
            ),
      );

  Future<String?> publish() => _run(
        () => ref.read(meetClientProvider).publishInterviewV1ProMeInterviewPublishPost(authorization: null, xMinusUserMinusId: null),
      );

  Future<String?> unpublish() => _run(
        () => ref.read(meetClientProvider).unpublishInterviewV1ProMeInterviewUnpublishPost(authorization: null, xMinusUserMinusId: null),
      );

  Future<String?> _run(Future<HttpResponse<MyInterviewView>> Function() call) async {
    final result = await apiCall(call);
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Not saved - check your connection.',
          BusinessError(:final message) => message,
          _ => 'Could not save that. Try again.',
        };
    }
  }
}
