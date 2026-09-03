/// GigResponse
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "client_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Client User Id"
///         },
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
///         "status": {
///             "$ref": "#/components/schemas/GigStatus"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "amount_minimum": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount Minimum"
///         },
///         "amount_final": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Amount Final"
///         },
///         "amount_platform_fee": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount Platform Fee"
///         },
///         "amount_pro_gross": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount Pro Gross"
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
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "client_user_id",
///         "pro_user_id",
///         "status",
///         "currency",
///         "amount_minimum",
///         "amount_platform_fee",
///         "amount_pro_gross",
///         "location_text",
///         "scheduled_start",
///         "scheduled_end",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "GigResponse"
/// }
library gig_response;

import 'exports.dart';
part 'gig_response.freezed.dart';
part 'gig_response.g.dart'; // GigResponse

@freezed
abstract class GigResponse with _$GigResponse {
  const GigResponse._();

  @jsonSerializable
  const factory GigResponse({
    /// id
    @JsonKey(name: GigResponse.idKey_) required String id,

    /// clientUserId
    @JsonKey(name: GigResponse.clientUserIdKey_) required String clientUserId,

    /// proUserId
    @JsonKey(name: GigResponse.proUserIdKey_) required String proUserId,

    /// nicheId
    @JsonKey(name: GigResponse.nicheIdKey_) String? nicheId,

    /// status
    @JsonKey(name: GigResponse.statusKey_) required GigStatus status,

    /// currency
    @JsonKey(name: GigResponse.currencyKey_) required String currency,

    /// amountMinimum
    @JsonKey(name: GigResponse.amountMinimumKey_) required String amountMinimum,

    /// amountFinal
    @JsonKey(name: GigResponse.amountFinalKey_) String? amountFinal,

    /// amountPlatformFee
    @JsonKey(name: GigResponse.amountPlatformFeeKey_)
    required String amountPlatformFee,

    /// amountProGross
    @JsonKey(name: GigResponse.amountProGrossKey_)
    required String amountProGross,

    /// locationText
    @JsonKey(name: GigResponse.locationTextKey_) required String? locationText,

    /// scheduledStart
    @JsonKey(name: GigResponse.scheduledStartKey_)
    required DateTime? scheduledStart,

    /// scheduledEnd
    @JsonKey(name: GigResponse.scheduledEndKey_)
    required DateTime? scheduledEnd,

    /// metadata
    @JsonKey(name: GigResponse.metadataKey_) Map<String, dynamic>? metadata,

    /// createdAt
    @JsonKey(name: GigResponse.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: GigResponse.updatedAtKey_) required DateTime updatedAt,
  }) = _GigResponse;

  factory GigResponse.fromJson(Map<String, dynamic> json) =>
      _$GigResponseFromJson(json);

  static const String idKey_ = r'id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String nicheIdKey_ = r'niche_id';

  static const String statusKey_ = r'status';

  static const String currencyKey_ = r'currency';

  static const String amountMinimumKey_ = r'amount_minimum';

  static const String amountFinalKey_ = r'amount_final';

  static const String amountPlatformFeeKey_ = r'amount_platform_fee';

  static const String amountProGrossKey_ = r'amount_pro_gross';

  static const String locationTextKey_ = r'location_text';

  static const String scheduledStartKey_ = r'scheduled_start';

  static const String scheduledEndKey_ = r'scheduled_end';

  static const String metadataKey_ = r'metadata';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
