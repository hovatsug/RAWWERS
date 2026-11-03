/// RawwEntryView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "kind": {
///             "type": "string",
///             "title": "Kind"
///         },
///         "amount": {
///             "type": "integer",
///             "title": "Amount"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "gig_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Gig Id"
///         },
///         "source_type": {
///             "type": "string",
///             "title": "Source Type"
///         },
///         "note": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Note"
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
///         "kind",
///         "amount",
///         "status",
///         "source_type",
///         "created_at"
///     ],
///     "title": "RawwEntryView"
/// }
library raww_entry_view;

import 'exports.dart';
part 'raww_entry_view.freezed.dart';
part 'raww_entry_view.g.dart'; // RawwEntryView

@freezed
abstract class RawwEntryView with _$RawwEntryView {
  const RawwEntryView._();

  @jsonSerializable
  const factory RawwEntryView({
    /// id
    @JsonKey(name: RawwEntryView.idKey_) required String id,

    /// kind
    @JsonKey(name: RawwEntryView.kindKey_) required String kind,

    /// amount
    @JsonKey(name: RawwEntryView.amountKey_) required int amount,

    /// status
    @JsonKey(name: RawwEntryView.statusKey_) required String status,

    /// gigId
    @JsonKey(name: RawwEntryView.gigIdKey_) String? gigId,

    /// sourceType
    @JsonKey(name: RawwEntryView.sourceTypeKey_) required String sourceType,

    /// note
    @JsonKey(name: RawwEntryView.noteKey_) String? note,

    /// createdAt
    @JsonKey(name: RawwEntryView.createdAtKey_) required DateTime createdAt,
  }) = _RawwEntryView;

  factory RawwEntryView.fromJson(Map<String, dynamic> json) =>
      _$RawwEntryViewFromJson(json);

  static const String idKey_ = r'id';

  static const String kindKey_ = r'kind';

  static const String amountKey_ = r'amount';

  static const String statusKey_ = r'status';

  static const String gigIdKey_ = r'gig_id';

  static const String sourceTypeKey_ = r'source_type';

  static const String noteKey_ = r'note';

  static const String createdAtKey_ = r'created_at';
}
