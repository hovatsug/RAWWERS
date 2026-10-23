/// InterviewAnswerView
/// {
///     "properties": {
///         "question_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Question Id"
///         },
///         "prompt": {
///             "type": "string",
///             "title": "Prompt"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "hint": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Hint"
///         },
///         "min_chars": {
///             "type": "integer",
///             "title": "Min Chars"
///         },
///         "max_chars": {
///             "type": "integer",
///             "title": "Max Chars"
///         },
///         "draft": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Draft"
///         },
///         "published": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Published"
///         },
///         "warning": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Warning"
///         }
///     },
///     "type": "object",
///     "required": [
///         "question_id",
///         "prompt",
///         "title",
///         "min_chars",
///         "max_chars"
///     ],
///     "title": "InterviewAnswerView"
/// }
library interview_answer_view;

import 'exports.dart';
part 'interview_answer_view.freezed.dart';
part 'interview_answer_view.g.dart'; // InterviewAnswerView

@freezed
abstract class InterviewAnswerView with _$InterviewAnswerView {
  const InterviewAnswerView._();

  @jsonSerializable
  const factory InterviewAnswerView({
    /// questionId
    @JsonKey(name: InterviewAnswerView.questionIdKey_)
    required String questionId,

    /// prompt
    @JsonKey(name: InterviewAnswerView.promptKey_) required String prompt,

    /// title
    @JsonKey(name: InterviewAnswerView.titleKey_) required String title,

    /// hint
    @JsonKey(name: InterviewAnswerView.hintKey_) String? hint,

    /// minChars
    @JsonKey(name: InterviewAnswerView.minCharsKey_) required int minChars,

    /// maxChars
    @JsonKey(name: InterviewAnswerView.maxCharsKey_) required int maxChars,

    /// draft
    @JsonKey(name: InterviewAnswerView.draftKey_) String? draft,

    /// published
    @JsonKey(name: InterviewAnswerView.publishedKey_) String? published,

    /// warning
    @JsonKey(name: InterviewAnswerView.warningKey_) String? warning,
  }) = _InterviewAnswerView;

  factory InterviewAnswerView.fromJson(Map<String, dynamic> json) =>
      _$InterviewAnswerViewFromJson(json);

  static const String questionIdKey_ = r'question_id';

  static const String promptKey_ = r'prompt';

  static const String titleKey_ = r'title';

  static const String hintKey_ = r'hint';

  static const String minCharsKey_ = r'min_chars';

  static const String maxCharsKey_ = r'max_chars';

  static const String draftKey_ = r'draft';

  static const String publishedKey_ = r'published';

  static const String warningKey_ = r'warning';
}
