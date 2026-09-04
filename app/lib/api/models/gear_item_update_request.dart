/// GearItemUpdateRequest
/// {
///     "properties": {
///         "category": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/GearCategory"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
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
///         "metadata": {
///             "anyOf": [
///                 {
///                     "type": "object"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "title": "GearItemUpdateRequest"
/// }
library gear_item_update_request;

import 'exports.dart';
part 'gear_item_update_request.freezed.dart';
part 'gear_item_update_request.g.dart'; // GearItemUpdateRequest

@freezed
abstract class GearItemUpdateRequest with _$GearItemUpdateRequest {
  const GearItemUpdateRequest._();

  @jsonSerializable
  const factory GearItemUpdateRequest({
    /// category
    @JsonKey(name: GearItemUpdateRequest.categoryKey_) GearCategory? category,

    /// brand
    @JsonKey(name: GearItemUpdateRequest.brandKey_) String? brand,

    /// model
    @JsonKey(name: GearItemUpdateRequest.modelKey_) String? model,

    /// serialNumber
    @JsonKey(name: GearItemUpdateRequest.serialNumberKey_) String? serialNumber,

    /// purchaseDate
    @JsonKey(name: GearItemUpdateRequest.purchaseDateKey_)
    DateTime? purchaseDate,

    /// notes
    @JsonKey(name: GearItemUpdateRequest.notesKey_) String? notes,

    /// metadata
    @JsonKey(name: GearItemUpdateRequest.metadataKey_)
    Map<String, dynamic>? metadata,
  }) = _GearItemUpdateRequest;

  factory GearItemUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$GearItemUpdateRequestFromJson(json);

  static const String categoryKey_ = r'category';

  static const String brandKey_ = r'brand';

  static const String modelKey_ = r'model';

  static const String serialNumberKey_ = r'serial_number';

  static const String purchaseDateKey_ = r'purchase_date';

  static const String notesKey_ = r'notes';

  static const String metadataKey_ = r'metadata';
}
