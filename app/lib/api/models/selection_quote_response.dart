/// SelectionQuoteResponse
/// {
///     "properties": {
///         "selected_count": {
///             "type": "integer",
///             "title": "Selected Count"
///         },
///         "included_photos": {
///             "type": "integer",
///             "title": "Included Photos"
///         },
///         "minimum_photos": {
///             "type": "integer",
///             "title": "Minimum Photos"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "amount_total": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount Total"
///         },
///         "amount_paid": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount Paid"
///         },
///         "amount_due": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount Due"
///         },
///         "refund_amount": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "default": "0.00",
///             "title": "Refund Amount"
///         },
///         "next_photo_price": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Next Photo Price"
///         },
///         "extras_count": {
///             "type": "integer",
///             "title": "Extras Count"
///         },
///         "can_submit": {
///             "type": "boolean",
///             "title": "Can Submit"
///         },
///         "photos_still_needed": {
///             "type": "integer",
///             "title": "Photos Still Needed"
///         }
///     },
///     "type": "object",
///     "required": [
///         "selected_count",
///         "included_photos",
///         "minimum_photos",
///         "currency",
///         "amount_total",
///         "amount_paid",
///         "amount_due",
///         "extras_count",
///         "can_submit",
///         "photos_still_needed"
///     ],
///     "title": "SelectionQuoteResponse",
///     "description": "What a selection of this size costs, computed by the same code that\ncharges for it. Every money field is a Decimal and serialises as a string\n- a float here would round someone's bill."
/// }
library selection_quote_response;

import 'exports.dart';
part 'selection_quote_response.freezed.dart';
part 'selection_quote_response.g.dart'; // SelectionQuoteResponse

@freezed
abstract class SelectionQuoteResponse with _$SelectionQuoteResponse {
  const SelectionQuoteResponse._();

  @jsonSerializable
  const factory SelectionQuoteResponse({
    /// selectedCount
    @JsonKey(name: SelectionQuoteResponse.selectedCountKey_)
    required int selectedCount,

    /// includedPhotos
    @JsonKey(name: SelectionQuoteResponse.includedPhotosKey_)
    required int includedPhotos,

    /// minimumPhotos
    @JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_)
    required int minimumPhotos,

    /// currency
    @JsonKey(name: SelectionQuoteResponse.currencyKey_)
    required String currency,

    /// amountTotal
    @JsonKey(name: SelectionQuoteResponse.amountTotalKey_)
    required String amountTotal,

    /// amountPaid
    @JsonKey(name: SelectionQuoteResponse.amountPaidKey_)
    required String amountPaid,

    /// amountDue
    @JsonKey(name: SelectionQuoteResponse.amountDueKey_)
    required String amountDue,

    /// refundAmount
    @Default('0.00')
    @JsonKey(name: SelectionQuoteResponse.refundAmountKey_)
    String refundAmount,

    /// nextPhotoPrice
    @JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_)
    String? nextPhotoPrice,

    /// extrasCount
    @JsonKey(name: SelectionQuoteResponse.extrasCountKey_)
    required int extrasCount,

    /// canSubmit
    @JsonKey(name: SelectionQuoteResponse.canSubmitKey_)
    required bool canSubmit,

    /// photosStillNeeded
    @JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_)
    required int photosStillNeeded,
  }) = _SelectionQuoteResponse;

  factory SelectionQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$SelectionQuoteResponseFromJson(json);

  static const String selectedCountKey_ = r'selected_count';

  static const String includedPhotosKey_ = r'included_photos';

  static const String minimumPhotosKey_ = r'minimum_photos';

  static const String currencyKey_ = r'currency';

  static const String amountTotalKey_ = r'amount_total';

  static const String amountPaidKey_ = r'amount_paid';

  static const String amountDueKey_ = r'amount_due';

  static const String refundAmountKey_ = r'refund_amount';

  static const String nextPhotoPriceKey_ = r'next_photo_price';

  static const String extrasCountKey_ = r'extras_count';

  static const String canSubmitKey_ = r'can_submit';

  static const String photosStillNeededKey_ = r'photos_still_needed';
}
