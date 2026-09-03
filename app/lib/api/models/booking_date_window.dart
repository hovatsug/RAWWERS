/// BookingDateWindow
/// {
///     "properties": {
///         "start_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Start At"
///         },
///         "end_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "End At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "start_at",
///         "end_at"
///     ],
///     "title": "BookingDateWindow"
/// }
library booking_date_window;

import 'exports.dart';
part 'booking_date_window.freezed.dart';
part 'booking_date_window.g.dart'; // BookingDateWindow

@freezed
abstract class BookingDateWindow with _$BookingDateWindow {
  const BookingDateWindow._();

  @jsonSerializable
  const factory BookingDateWindow({
    /// startAt
    @JsonKey(name: BookingDateWindow.startAtKey_) required DateTime startAt,

    /// endAt
    @JsonKey(name: BookingDateWindow.endAtKey_) required DateTime endAt,
  }) = _BookingDateWindow;

  factory BookingDateWindow.fromJson(Map<String, dynamic> json) =>
      _$BookingDateWindowFromJson(json);

  static const String startAtKey_ = r'start_at';

  static const String endAtKey_ = r'end_at';
}
