/// SessionBlockInput
/// {
///     "properties": {
///         "label": {
///             "$ref": "#/components/schemas/SessionBlockLabel"
///         },
///         "start_time": {
///             "type": "string",
///             "format": "time",
///             "title": "Start Time"
///         },
///         "end_time": {
///             "type": "string",
///             "format": "time",
///             "title": "End Time"
///         }
///     },
///     "type": "object",
///     "required": [
///         "label",
///         "start_time",
///         "end_time"
///     ],
///     "title": "SessionBlockInput",
///     "description": "One named block of a blocks-preset package, in the photographer's\nlocal time. An end at or before the start runs past midnight."
/// }
library session_block_input;

import 'exports.dart';
part 'session_block_input.freezed.dart';
part 'session_block_input.g.dart'; // SessionBlockInput

@freezed
abstract class SessionBlockInput with _$SessionBlockInput {
  const SessionBlockInput._();

  @jsonSerializable
  const factory SessionBlockInput({
    /// label
    @JsonKey(name: SessionBlockInput.labelKey_)
    required SessionBlockLabel label,

    /// startTime
    @JsonKey(name: SessionBlockInput.startTimeKey_) required String startTime,

    /// endTime
    @JsonKey(name: SessionBlockInput.endTimeKey_) required String endTime,
  }) = _SessionBlockInput;

  factory SessionBlockInput.fromJson(Map<String, dynamic> json) =>
      _$SessionBlockInputFromJson(json);

  static const String labelKey_ = r'label';

  static const String startTimeKey_ = r'start_time';

  static const String endTimeKey_ = r'end_time';
}
