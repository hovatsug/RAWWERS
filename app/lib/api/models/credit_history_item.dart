/// CreditHistoryItem
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "kind": {
///             "type": "string",
///             "title": "Kind"
///         },
///         "amount_eur": {
///             "type": "string",
///             "title": "Amount Eur"
///         },
///         "photographer_first_name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Photographer First Name"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "created_at",
///         "kind",
///         "amount_eur"
///     ],
///     "title": "CreditHistoryItem"
/// }
library credit_history_item;

import 'exports.dart';
part 'credit_history_item.freezed.dart';
part 'credit_history_item.g.dart'; // CreditHistoryItem

@freezed
abstract class CreditHistoryItem with _$CreditHistoryItem {
  const CreditHistoryItem._();

  @jsonSerializable
  const factory CreditHistoryItem({
    /// id
    @JsonKey(name: CreditHistoryItem.idKey_) required String id,

    /// createdAt
    @JsonKey(name: CreditHistoryItem.createdAtKey_) required DateTime createdAt,

    /// kind
    @JsonKey(name: CreditHistoryItem.kindKey_) required String kind,

    /// amountEur
    @JsonKey(name: CreditHistoryItem.amountEurKey_) required String amountEur,

    /// photographerFirstName
    @JsonKey(name: CreditHistoryItem.photographerFirstNameKey_)
    String? photographerFirstName,
  }) = _CreditHistoryItem;

  factory CreditHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$CreditHistoryItemFromJson(json);

  static const String idKey_ = r'id';

  static const String createdAtKey_ = r'created_at';

  static const String kindKey_ = r'kind';

  static const String amountEurKey_ = r'amount_eur';

  static const String photographerFirstNameKey_ = r'photographer_first_name';
}
