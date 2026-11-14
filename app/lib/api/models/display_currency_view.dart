/// DisplayCurrencyView
/// {
///     "properties": {
///         "display_currency": {
///             "type": "string",
///             "title": "Display Currency"
///         },
///         "chosen": {
///             "type": "boolean",
///             "title": "Chosen"
///         },
///         "available": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Available"
///         }
///     },
///     "type": "object",
///     "required": [
///         "display_currency",
///         "chosen",
///         "available"
///     ],
///     "title": "DisplayCurrencyView"
/// }
library display_currency_view;

import 'exports.dart';
part 'display_currency_view.freezed.dart';
part 'display_currency_view.g.dart'; // DisplayCurrencyView

@freezed
abstract class DisplayCurrencyView with _$DisplayCurrencyView {
  const DisplayCurrencyView._();

  @jsonSerializable
  const factory DisplayCurrencyView({
    /// displayCurrency
    @JsonKey(name: DisplayCurrencyView.displayCurrencyKey_)
    required String displayCurrency,

    /// chosen
    @JsonKey(name: DisplayCurrencyView.chosenKey_) required bool chosen,

    /// available
    @JsonKey(name: DisplayCurrencyView.availableKey_)
    required List<String> available,
  }) = _DisplayCurrencyView;

  factory DisplayCurrencyView.fromJson(Map<String, dynamic> json) =>
      _$DisplayCurrencyViewFromJson(json);

  static const String displayCurrencyKey_ = r'display_currency';

  static const String chosenKey_ = r'chosen';

  static const String availableKey_ = r'available';
}
