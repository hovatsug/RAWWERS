/// GearItemCreateRequest
/// {
///     "properties": {
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
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "required": [
///         "category"
///     ],
///     "title": "GearItemCreateRequest"
/// }
library gear_item_create_request;

import 'exports.dart';
part 'gear_item_create_request.freezed.dart';
part 'gear_item_create_request.g.dart'; // GearItemCreateRequest

@freezed
abstract class GearItemCreateRequest with _$GearItemCreateRequest {
  const GearItemCreateRequest._();

  @jsonSerializable
  const factory GearItemCreateRequest({
    /// category
    @JsonKey(name: GearItemCreateRequest.categoryKey_)
    required GearCategory category,

    /// brand
    @JsonKey(name: GearItemCreateRequest.brandKey_) String? brand,

    /// model
    @JsonKey(name: GearItemCreateRequest.modelKey_) String? model,

    /// serialNumber
    @JsonKey(name: GearItemCreateRequest.serialNumberKey_) String? serialNumber,

    /// purchaseDate
    @JsonKey(name: GearItemCreateRequest.purchaseDateKey_)
    DateTime? purchaseDate,

    /// notes
    @JsonKey(name: GearItemCreateRequest.notesKey_) String? notes,

    /// metadata
    @JsonKey(name: GearItemCreateRequest.metadataKey_)
    Map<String, dynamic>? metadata,
  }) = _GearItemCreateRequest;

  factory GearItemCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$GearItemCreateRequestFromJson(json);

  static const String categoryKey_ = r'category';

  static const String brandKey_ = r'brand';

  static const String modelKey_ = r'model';

  static const String serialNumberKey_ = r'serial_number';

  static const String purchaseDateKey_ = r'purchase_date';

  static const String notesKey_ = r'notes';

  static const String metadataKey_ = r'metadata';
}
