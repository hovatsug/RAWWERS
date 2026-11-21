/// MyPresentationVideoState
/// {
///     "properties": {
///         "available": {
///             "type": "boolean",
///             "title": "Available"
///         },
///         "message": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Message"
///         },
///         "max_seconds": {
///             "type": "integer",
///             "title": "Max Seconds"
///         },
///         "max_bytes": {
///             "type": "integer",
///             "title": "Max Bytes"
///         },
///         "shown": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/MyPresentationVideo"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "pending": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/MyPresentationVideo"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         }
///     },
///     "type": "object",
///     "required": [
///         "available",
///         "max_seconds",
///         "max_bytes"
///     ],
///     "title": "MyPresentationVideoState",
///     "description": "The Pro app's \"Meet the photographer\" video screen."
/// }
library my_presentation_video_state;

import 'exports.dart';
part 'my_presentation_video_state.freezed.dart';
part 'my_presentation_video_state.g.dart'; // MyPresentationVideoState

@freezed
abstract class MyPresentationVideoState with _$MyPresentationVideoState {
  const MyPresentationVideoState._();

  @jsonSerializable
  const factory MyPresentationVideoState({
    /// available
    @JsonKey(name: MyPresentationVideoState.availableKey_)
    required bool available,

    /// message
    @JsonKey(name: MyPresentationVideoState.messageKey_) String? message,

    /// maxSeconds
    @JsonKey(name: MyPresentationVideoState.maxSecondsKey_)
    required int maxSeconds,

    /// maxBytes
    @JsonKey(name: MyPresentationVideoState.maxBytesKey_) required int maxBytes,

    /// shown
    @JsonKey(name: MyPresentationVideoState.shownKey_)
    MyPresentationVideo? shown,

    /// pending
    @JsonKey(name: MyPresentationVideoState.pendingKey_)
    MyPresentationVideo? pending,
  }) = _MyPresentationVideoState;

  factory MyPresentationVideoState.fromJson(Map<String, dynamic> json) =>
      _$MyPresentationVideoStateFromJson(json);

  static const String availableKey_ = r'available';

  static const String messageKey_ = r'message';

  static const String maxSecondsKey_ = r'max_seconds';

  static const String maxBytesKey_ = r'max_bytes';

  static const String shownKey_ = r'shown';

  static const String pendingKey_ = r'pending';
}
