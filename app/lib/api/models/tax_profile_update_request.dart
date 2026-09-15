/// TaxProfileUpdateRequest
/// {
///     "properties": {
///         "vat_status": {
///             "type": "string",
///             "title": "Vat Status"
///         },
///         "vat_number": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Vat Number"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "vat_status"
///     ],
///     "title": "TaxProfileUpdateRequest"
/// }
library tax_profile_update_request;

import 'exports.dart';
part 'tax_profile_update_request.freezed.dart';
part 'tax_profile_update_request.g.dart'; // TaxProfileUpdateRequest

@freezed
abstract class TaxProfileUpdateRequest with _$TaxProfileUpdateRequest {
  const TaxProfileUpdateRequest._();

  @jsonSerializable
  const factory TaxProfileUpdateRequest({
    /// vatStatus
    @JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_)
    required String vatStatus,

    /// vatNumber
    @JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_) String? vatNumber,

    /// country
    @JsonKey(name: TaxProfileUpdateRequest.countryKey_) String? country,
  }) = _TaxProfileUpdateRequest;

  factory TaxProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TaxProfileUpdateRequestFromJson(json);

  static const String vatStatusKey_ = r'vat_status';

  static const String vatNumberKey_ = r'vat_number';

  static const String countryKey_ = r'country';
}
