/// GigInvoiceListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/GigInvoiceView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "GigInvoiceListResponse"
/// }
library gig_invoice_list_response;

import 'exports.dart';
part 'gig_invoice_list_response.freezed.dart';
part 'gig_invoice_list_response.g.dart'; // GigInvoiceListResponse

@freezed
abstract class GigInvoiceListResponse with _$GigInvoiceListResponse {
  const GigInvoiceListResponse._();

  @jsonSerializable
  const factory GigInvoiceListResponse({
    /// items
    @JsonKey(name: GigInvoiceListResponse.itemsKey_)
    List<GigInvoiceView>? items,
  }) = _GigInvoiceListResponse;

  factory GigInvoiceListResponse.fromJson(Map<String, dynamic> json) =>
      _$GigInvoiceListResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
