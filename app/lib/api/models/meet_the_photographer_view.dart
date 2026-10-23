/// MeetThePhotographerView
/// {
///     "properties": {
///         "video": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/PresentationVideoView"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "interview": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MeetInterviewItem"
///             },
///             "title": "Interview"
///         }
///     },
///     "type": "object",
///     "title": "MeetThePhotographerView",
///     "description": "A profile's \"Meet the photographer\" section. Absent (null) when there is\nnothing in it: no video and no published answer."
/// }
library meet_the_photographer_view;

import 'exports.dart';
part 'meet_the_photographer_view.freezed.dart';
part 'meet_the_photographer_view.g.dart'; // MeetThePhotographerView

@freezed
abstract class MeetThePhotographerView with _$MeetThePhotographerView {
  const MeetThePhotographerView._();

  @jsonSerializable
  const factory MeetThePhotographerView({
    /// video
    @JsonKey(name: MeetThePhotographerView.videoKey_)
    PresentationVideoView? video,

    /// interview
    @JsonKey(name: MeetThePhotographerView.interviewKey_)
    List<MeetInterviewItem>? interview,
  }) = _MeetThePhotographerView;

  factory MeetThePhotographerView.fromJson(Map<String, dynamic> json) =>
      _$MeetThePhotographerViewFromJson(json);

  static const String videoKey_ = r'video';

  static const String interviewKey_ = r'interview';
}
