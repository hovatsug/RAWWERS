/// MeetInterviewItem
/// {
///     "properties": {
///         "question_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Question Id"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "answer": {
///             "type": "string",
///             "title": "Answer"
///         }
///     },
///     "type": "object",
///     "required": [
///         "question_id",
///         "title",
///         "answer"
///     ],
///     "title": "MeetInterviewItem"
/// }
library meet_interview_item;

import 'exports.dart';
part 'meet_interview_item.freezed.dart';
part 'meet_interview_item.g.dart'; // MeetInterviewItem

@freezed
abstract class MeetInterviewItem with _$MeetInterviewItem {
  const MeetInterviewItem._();

  @jsonSerializable
  const factory MeetInterviewItem({
    /// questionId
    @JsonKey(name: MeetInterviewItem.questionIdKey_) required String questionId,

    /// title
    @JsonKey(name: MeetInterviewItem.titleKey_) required String title,

    /// answer
    @JsonKey(name: MeetInterviewItem.answerKey_) required String answer,
  }) = _MeetInterviewItem;

  factory MeetInterviewItem.fromJson(Map<String, dynamic> json) =>
      _$MeetInterviewItemFromJson(json);

  static const String questionIdKey_ = r'question_id';

  static const String titleKey_ = r'title';

  static const String answerKey_ = r'answer';
}
