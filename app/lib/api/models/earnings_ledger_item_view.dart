/// EarningsLedgerItemView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "source_type": {
///             "$ref": "#/components/schemas/EarningsSourceType"
///         },
///         "source_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Source Id"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "gross": {
///             "type": "string",
///             "title": "Gross"
///         },
///         "platform_fee": {
///             "type": "string",
///             "title": "Platform Fee"
///         },
///         "net": {
///             "type": "string",
///             "title": "Net"
///         },
///         "status": {
///             "$ref": "#/components/schemas/EarningsEntryStatus"
///         },
///         "available_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Available At"
///         },
///         "reversed_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reversed At"
///         },
///         "meta": {
///             "type": "object",
///             "title": "Meta"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "source_type",
///         "source_id",
///         "currency",
///         "gross",
///         "platform_fee",
///         "net",
///         "status",
///         "available_at",
///         "created_at"
///     ],
///     "title": "EarningsLedgerItemView"
/// }
library earnings_ledger_item_view;

import 'exports.dart';
part 'earnings_ledger_item_view.freezed.dart';
part 'earnings_ledger_item_view.g.dart'; // EarningsLedgerItemView

@freezed
abstract class EarningsLedgerItemView with _$EarningsLedgerItemView {
  const EarningsLedgerItemView._();

  @jsonSerializable
  const factory EarningsLedgerItemView({
    /// id
    @JsonKey(name: EarningsLedgerItemView.idKey_) required String id,

    /// sourceType
    @JsonKey(name: EarningsLedgerItemView.sourceTypeKey_)
    required EarningsSourceType sourceType,

    /// sourceId
    @JsonKey(name: EarningsLedgerItemView.sourceIdKey_)
    required String sourceId,

    /// currency
    @JsonKey(name: EarningsLedgerItemView.currencyKey_)
    required String currency,

    /// gross
    @JsonKey(name: EarningsLedgerItemView.grossKey_) required String gross,

    /// platformFee
    @JsonKey(name: EarningsLedgerItemView.platformFeeKey_)
    required String platformFee,

    /// net
    @JsonKey(name: EarningsLedgerItemView.netKey_) required String net,

    /// status
    @JsonKey(name: EarningsLedgerItemView.statusKey_)
    required EarningsEntryStatus status,

    /// availableAt
    @JsonKey(name: EarningsLedgerItemView.availableAtKey_)
    required DateTime availableAt,

    /// reversedAt
    @JsonKey(name: EarningsLedgerItemView.reversedAtKey_) DateTime? reversedAt,

    /// meta
    @JsonKey(name: EarningsLedgerItemView.metaKey_) Map<String, dynamic>? meta,

    /// createdAt
    @JsonKey(name: EarningsLedgerItemView.createdAtKey_)
    required DateTime createdAt,
  }) = _EarningsLedgerItemView;

  factory EarningsLedgerItemView.fromJson(Map<String, dynamic> json) =>
      _$EarningsLedgerItemViewFromJson(json);

  static const String idKey_ = r'id';

  static const String sourceTypeKey_ = r'source_type';

  static const String sourceIdKey_ = r'source_id';

  static const String currencyKey_ = r'currency';

  static const String grossKey_ = r'gross';

  static const String platformFeeKey_ = r'platform_fee';

  static const String netKey_ = r'net';

  static const String statusKey_ = r'status';

  static const String availableAtKey_ = r'available_at';

  static const String reversedAtKey_ = r'reversed_at';

  static const String metaKey_ = r'meta';

  static const String createdAtKey_ = r'created_at';
}
