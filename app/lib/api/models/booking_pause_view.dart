/// BookingPauseView
/// {
///     "properties": {
///         "reason": {
///             "type": "string",
///             "title": "Reason"
///         },
///         "since": {
///             "type": "string",
///             "title": "Since"
///         }
///     },
///     "type": "object",
///     "required": [
///         "reason",
///         "since"
///     ],
///     "title": "BookingPauseView"
/// }
library booking_pause_view;

import 'exports.dart';
part 'booking_pause_view.freezed.dart';
part 'booking_pause_view.g.dart'; // BookingPauseView

@freezed
abstract class BookingPauseView with _$BookingPauseView {
  const BookingPauseView._();

  @jsonSerializable
  const factory BookingPauseView({
    /// reason
    @JsonKey(name: BookingPauseView.reasonKey_) required String reason,

    /// since
    @JsonKey(name: BookingPauseView.sinceKey_) required String since,
  }) = _BookingPauseView;

  factory BookingPauseView.fromJson(Map<String, dynamic> json) =>
      _$BookingPauseViewFromJson(json);

  static const String reasonKey_ = r'reason';

  static const String sinceKey_ = r'since';
}
