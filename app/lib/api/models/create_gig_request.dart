/// CreateGigRequest
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "niche_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Niche Id"
///         },
///         "amount_total": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 }
///             ],
///             "title": "Amount Total"
///         },
///         "currency": {
///             "type": "string",
///             "default": "EUR",
///             "title": "Currency"
///         },
///         "location_text": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Location Text"
///         },
///         "scheduled_start": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Scheduled Start"
///         },
///         "scheduled_end": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Scheduled End"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "amount_total"
///     ],
///     "title": "CreateGigRequest"
/// }
library create_gig_request;

import 'exports.dart';
part 'create_gig_request.freezed.dart';
part 'create_gig_request.g.dart'; // CreateGigRequest

@freezed
abstract class CreateGigRequest with _$CreateGigRequest {
  const CreateGigRequest._();

  @jsonSerializable
  const factory CreateGigRequest({
    /// proUserId
    @JsonKey(name: CreateGigRequest.proUserIdKey_) required String proUserId,

    /// nicheId
    @JsonKey(name: CreateGigRequest.nicheIdKey_) String? nicheId,

    /// amountTotal
    @JsonKey(name: CreateGigRequest.amountTotalKey_)
    required dynamic amountTotal,

    /// currency
    @Default('EUR')
    @JsonKey(name: CreateGigRequest.currencyKey_)
    String currency,

    /// locationText
    @JsonKey(name: CreateGigRequest.locationTextKey_) String? locationText,

    /// scheduledStart
    @JsonKey(name: CreateGigRequest.scheduledStartKey_)
    DateTime? scheduledStart,

    /// scheduledEnd
    @JsonKey(name: CreateGigRequest.scheduledEndKey_) DateTime? scheduledEnd,
  }) = _CreateGigRequest;

  factory CreateGigRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGigRequestFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String nicheIdKey_ = r'niche_id';

  static const String amountTotalKey_ = r'amount_total';

  static const String currencyKey_ = r'currency';

  static const String locationTextKey_ = r'location_text';

  static const String scheduledStartKey_ = r'scheduled_start';

  static const String scheduledEndKey_ = r'scheduled_end';
}
