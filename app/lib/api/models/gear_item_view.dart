/// GearItemView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "category": {
///             "$ref": "#/components/schemas/GearCategory"
///         },
///         "brand": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Brand"
///         },
///         "model": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Model"
///         },
///         "serial_number": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Serial Number"
///         },
///         "purchase_date": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Purchase Date"
///         },
///         "notes": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Notes"
///         },
///         "meta": {
///             "type": "object",
///             "title": "Meta"
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
///         "pro_user_id",
///         "category",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "GearItemView"
/// }
library gear_item_view;

import 'exports.dart';
part 'gear_item_view.freezed.dart';
part 'gear_item_view.g.dart'; // GearItemView

@freezed
abstract class GearItemView with _$GearItemView {
  const GearItemView._();

  @jsonSerializable
  const factory GearItemView({
    /// id
    @JsonKey(name: GearItemView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: GearItemView.proUserIdKey_) required String proUserId,

    /// category
    @JsonKey(name: GearItemView.categoryKey_) required GearCategory category,

    /// brand
    @JsonKey(name: GearItemView.brandKey_) String? brand,

    /// model
    @JsonKey(name: GearItemView.modelKey_) String? model,

    /// serialNumber
    @JsonKey(name: GearItemView.serialNumberKey_) String? serialNumber,

    /// purchaseDate
    @JsonKey(name: GearItemView.purchaseDateKey_) DateTime? purchaseDate,

    /// notes
    @JsonKey(name: GearItemView.notesKey_) String? notes,

    /// meta
    @JsonKey(name: GearItemView.metaKey_) Map<String, dynamic>? meta,

    /// createdAt
    @JsonKey(name: GearItemView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: GearItemView.updatedAtKey_) required DateTime updatedAt,
  }) = _GearItemView;

  factory GearItemView.fromJson(Map<String, dynamic> json) =>
      _$GearItemViewFromJson(json);

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String categoryKey_ = r'category';

  static const String brandKey_ = r'brand';

  static const String modelKey_ = r'model';

  static const String serialNumberKey_ = r'serial_number';

  static const String purchaseDateKey_ = r'purchase_date';

  static const String notesKey_ = r'notes';

  static const String metaKey_ = r'meta';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
