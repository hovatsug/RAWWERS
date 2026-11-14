/// FxRatesResponse
/// {
///     "properties": {
///         "base": {
///             "type": "string",
///             "title": "Base"
///         },
///         "rates": {
///             "type": "object",
///             "title": "Rates"
///         },
///         "as_of": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "As Of"
///         }
///     },
///     "type": "object",
///     "required": [
///         "base",
///         "rates"
///     ],
///     "title": "FxRatesResponse"
/// }
library fx_rates_response;

import 'exports.dart';
part 'fx_rates_response.freezed.dart';
part 'fx_rates_response.g.dart'; // FxRatesResponse

@freezed
abstract class FxRatesResponse with _$FxRatesResponse {
  const FxRatesResponse._();

  @jsonSerializable
  const factory FxRatesResponse({
    /// baseAA
    @JsonKey(name: FxRatesResponse.baseAAKey_) required String baseAA,

    /// rates
    @JsonKey(name: FxRatesResponse.ratesKey_)
    required Map<String, dynamic> rates,

    /// asOf
    @JsonKey(name: FxRatesResponse.asOfKey_) DateTime? asOf,
  }) = _FxRatesResponse;

  factory FxRatesResponse.fromJson(Map<String, dynamic> json) =>
      _$FxRatesResponseFromJson(json);

  static const String baseAAKey_ = r'base';

  static const String ratesKey_ = r'rates';

  static const String asOfKey_ = r'as_of';
}
