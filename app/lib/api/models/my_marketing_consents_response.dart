/// MyMarketingConsentsResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MarketingConsentView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items"
///     ],
///     "title": "MyMarketingConsentsResponse"
/// }
library my_marketing_consents_response;

import 'exports.dart';
part 'my_marketing_consents_response.freezed.dart';
part 'my_marketing_consents_response.g.dart'; // MyMarketingConsentsResponse

@freezed
abstract class MyMarketingConsentsResponse with _$MyMarketingConsentsResponse {
  const MyMarketingConsentsResponse._();

  @jsonSerializable
  const factory MyMarketingConsentsResponse({
    /// items
    @JsonKey(name: MyMarketingConsentsResponse.itemsKey_)
    required List<MarketingConsentView> items,
  }) = _MyMarketingConsentsResponse;

  factory MyMarketingConsentsResponse.fromJson(Map<String, dynamic> json) =>
      _$MyMarketingConsentsResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
