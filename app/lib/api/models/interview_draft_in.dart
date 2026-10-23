/// InterviewDraftIn
/// {
///     "properties": {
///         "answers": {
///             "type": "object",
///             "title": "Answers"
///         }
///     },
///     "type": "object",
///     "required": [
///         "answers"
///     ],
///     "title": "InterviewDraftIn"
/// }
library interview_draft_in;

import 'exports.dart';
part 'interview_draft_in.freezed.dart';
part 'interview_draft_in.g.dart'; // InterviewDraftIn

@freezed
abstract class InterviewDraftIn with _$InterviewDraftIn {
  const InterviewDraftIn._();

  @jsonSerializable
  const factory InterviewDraftIn({
    /// answers
    @JsonKey(name: InterviewDraftIn.answersKey_)
    required Map<String, dynamic> answers,
  }) = _InterviewDraftIn;

  factory InterviewDraftIn.fromJson(Map<String, dynamic> json) =>
      _$InterviewDraftInFromJson(json);

  static const String answersKey_ = r'answers';
}
