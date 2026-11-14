/// DisplayCurrencyUpdateRequest
/// {
///     "properties": {
///         "display_currency": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Display Currency"
///         }
///     },
///     "type": "object",
///     "title": "DisplayCurrencyUpdateRequest"
/// }
library display_currency_update_request;

import 'exports.dart';
part 'display_currency_update_request.freezed.dart';
part 'display_currency_update_request.g.dart'; // DisplayCurrencyUpdateRequest

@freezed
abstract class DisplayCurrencyUpdateRequest
    with _$DisplayCurrencyUpdateRequest {
  const DisplayCurrencyUpdateRequest._();

  @jsonSerializable
  const factory DisplayCurrencyUpdateRequest({
    /// displayCurrency
    @JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_)
    String? displayCurrency,
  }) = _DisplayCurrencyUpdateRequest;

  factory DisplayCurrencyUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$DisplayCurrencyUpdateRequestFromJson(json);

  static const String displayCurrencyKey_ = r'display_currency';
}
