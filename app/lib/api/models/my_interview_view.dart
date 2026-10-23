/// MyInterviewView
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/InterviewAnswerView"
///             },
///             "title": "Items"
///         },
///         "is_published": {
///             "type": "boolean",
///             "title": "Is Published"
///         },
///         "published_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Published At"
///         },
///         "has_unpublished_changes": {
///             "type": "boolean",
///             "title": "Has Unpublished Changes"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items",
///         "is_published",
///         "has_unpublished_changes"
///     ],
///     "title": "MyInterviewView"
/// }
library my_interview_view;

import 'exports.dart';
part 'my_interview_view.freezed.dart';
part 'my_interview_view.g.dart'; // MyInterviewView

@freezed
abstract class MyInterviewView with _$MyInterviewView {
  const MyInterviewView._();

  @jsonSerializable
  const factory MyInterviewView({
    /// items
    @JsonKey(name: MyInterviewView.itemsKey_)
    required List<InterviewAnswerView> items,

    /// isPublished
    @JsonKey(name: MyInterviewView.isPublishedKey_) required bool isPublished,

    /// publishedAt
    @JsonKey(name: MyInterviewView.publishedAtKey_) DateTime? publishedAt,

    /// hasUnpublishedChanges
    @JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_)
    required bool hasUnpublishedChanges,
  }) = _MyInterviewView;

  factory MyInterviewView.fromJson(Map<String, dynamic> json) =>
      _$MyInterviewViewFromJson(json);

  static const String itemsKey_ = r'items';

  static const String isPublishedKey_ = r'is_published';

  static const String publishedAtKey_ = r'published_at';

  static const String hasUnpublishedChangesKey_ = r'has_unpublished_changes';
}
