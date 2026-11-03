/// ShelfAddressResponse
/// {
///     "properties": {
///         "address": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/ShelfAddress"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "allowed_countries": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Allowed Countries"
///         }
///     },
///     "type": "object",
///     "required": [
///         "allowed_countries"
///     ],
///     "title": "ShelfAddressResponse"
/// }
library shelf_address_response;

import 'exports.dart';
part 'shelf_address_response.freezed.dart';
part 'shelf_address_response.g.dart'; // ShelfAddressResponse

@freezed
abstract class ShelfAddressResponse with _$ShelfAddressResponse {
  const ShelfAddressResponse._();

  @jsonSerializable
  const factory ShelfAddressResponse({
    /// address
    @JsonKey(name: ShelfAddressResponse.addressKey_) ShelfAddress? address,

    /// allowedCountries
    @JsonKey(name: ShelfAddressResponse.allowedCountriesKey_)
    required List<String> allowedCountries,
  }) = _ShelfAddressResponse;

  factory ShelfAddressResponse.fromJson(Map<String, dynamic> json) =>
      _$ShelfAddressResponseFromJson(json);

  static const String addressKey_ = r'address';

  static const String allowedCountriesKey_ = r'allowed_countries';
}
