/// AddonQuoteResponse
/// {
///     "properties": {
///         "already_chosen": {
///             "type": "integer",
///             "title": "Already Chosen"
///         },
///         "adding": {
///             "type": "integer",
///             "title": "Adding"
///         },
///         "amount": {
///             "type": "string",
///             "title": "Amount"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "window_ends_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Window Ends At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "already_chosen",
///         "adding",
///         "amount",
///         "currency"
///     ],
///     "title": "AddonQuoteResponse",
///     "description": "What adding `adding` photos costs now: total(chosen + adding) -\ntotal(chosen), on the booking's own curve."
/// }
library addon_quote_response;

import 'exports.dart';
part 'addon_quote_response.freezed.dart';
part 'addon_quote_response.g.dart'; // AddonQuoteResponse

@freezed
abstract class AddonQuoteResponse with _$AddonQuoteResponse {
  const AddonQuoteResponse._();

  @jsonSerializable
  const factory AddonQuoteResponse({
    /// alreadyChosen
    @JsonKey(name: AddonQuoteResponse.alreadyChosenKey_)
    required int alreadyChosen,

    /// adding
    @JsonKey(name: AddonQuoteResponse.addingKey_) required int adding,

    /// amount
    @JsonKey(name: AddonQuoteResponse.amountKey_) required String amount,

    /// currency
    @JsonKey(name: AddonQuoteResponse.currencyKey_) required String currency,

    /// windowEndsAt
    @JsonKey(name: AddonQuoteResponse.windowEndsAtKey_) DateTime? windowEndsAt,
  }) = _AddonQuoteResponse;

  factory AddonQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$AddonQuoteResponseFromJson(json);

  static const String alreadyChosenKey_ = r'already_chosen';

  static const String addingKey_ = r'adding';

  static const String amountKey_ = r'amount';

  static const String currencyKey_ = r'currency';

  static const String windowEndsAtKey_ = r'window_ends_at';
}
