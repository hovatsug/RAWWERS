/// ShelfAddress
/// {
///     "properties": {
///         "name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Name"
///         },
///         "line1": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Line1"
///         },
///         "line2": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Line2"
///         },
///         "city": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "City"
///         },
///         "region": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Region"
///         },
///         "postal_code": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Postal Code"
///         },
///         "country": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Country"
///         },
///         "phone": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Phone"
///         }
///     },
///     "type": "object",
///     "title": "ShelfAddress"
/// }
library shelf_address;

import 'exports.dart';
part 'shelf_address.freezed.dart';
part 'shelf_address.g.dart'; // ShelfAddress

@freezed
abstract class ShelfAddress with _$ShelfAddress {
  const ShelfAddress._();

  @jsonSerializable
  const factory ShelfAddress({
    /// name
    @JsonKey(name: ShelfAddress.nameKey_) String? name,

    /// line1
    @JsonKey(name: ShelfAddress.line1Key_) String? line1,

    /// line2
    @JsonKey(name: ShelfAddress.line2Key_) String? line2,

    /// city
    @JsonKey(name: ShelfAddress.cityKey_) String? city,

    /// region
    @JsonKey(name: ShelfAddress.regionKey_) String? region,

    /// postalCode
    @JsonKey(name: ShelfAddress.postalCodeKey_) String? postalCode,

    /// country
    @JsonKey(name: ShelfAddress.countryKey_) String? country,

    /// phone
    @JsonKey(name: ShelfAddress.phoneKey_) String? phone,
  }) = _ShelfAddress;

  factory ShelfAddress.fromJson(Map<String, dynamic> json) =>
      _$ShelfAddressFromJson(json);

  static const String nameKey_ = r'name';

  static const String line1Key_ = r'line1';

  static const String line2Key_ = r'line2';

  static const String cityKey_ = r'city';

  static const String regionKey_ = r'region';

  static const String postalCodeKey_ = r'postal_code';

  static const String countryKey_ = r'country';

  static const String phoneKey_ = r'phone';
}
