/// BlackoutView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "start_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Start At"
///         },
///         "end_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "End At"
///         },
///         "reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reason"
///         },
///         "deprecation_notice": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Deprecation Notice"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "start_at",
///         "end_at"
///     ],
///     "title": "BlackoutView"
/// }
library blackout_view;

import 'exports.dart';
part 'blackout_view.freezed.dart';
part 'blackout_view.g.dart'; // BlackoutView

@freezed
abstract class BlackoutView with _$BlackoutView {
  const BlackoutView._();

  @jsonSerializable
  const factory BlackoutView({
    /// id
    @JsonKey(name: BlackoutView.idKey_) required String id,

    /// startAt
    @JsonKey(name: BlackoutView.startAtKey_) required DateTime startAt,

    /// endAt
    @JsonKey(name: BlackoutView.endAtKey_) required DateTime endAt,

    /// reason
    @JsonKey(name: BlackoutView.reasonKey_) String? reason,

    /// deprecationNotice
    @JsonKey(name: BlackoutView.deprecationNoticeKey_)
    String? deprecationNotice,
  }) = _BlackoutView;

  factory BlackoutView.fromJson(Map<String, dynamic> json) =>
      _$BlackoutViewFromJson(json);

  static const String idKey_ = r'id';

  static const String startAtKey_ = r'start_at';

  static const String endAtKey_ = r'end_at';

  static const String reasonKey_ = r'reason';

  static const String deprecationNoticeKey_ = r'deprecation_notice';
}
