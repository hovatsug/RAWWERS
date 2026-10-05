/// GearVerificationView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "category": {
///             "$ref": "#/components/schemas/GearCategory"
///         },
///         "status": {
///             "$ref": "#/components/schemas/VerificationStatus"
///         },
///         "make": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Make"
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
///         "serial_hint": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Serial Hint"
///         },
///         "sensor_size": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/SensorSize"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "aperture_type": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/ApertureType"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "min_focal_mm": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Min Focal Mm"
///         },
///         "max_focal_mm": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Max Focal Mm"
///         },
///         "max_aperture": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Max Aperture"
///         },
///         "review_reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Review Reason"
///         },
///         "verified_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Verified At"
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
///         "category",
///         "status",
///         "created_at"
///     ],
///     "title": "GearVerificationView",
///     "description": "One piece of gear, as its owner sees it."
/// }
library gear_verification_view;

import 'exports.dart';
part 'gear_verification_view.freezed.dart';
part 'gear_verification_view.g.dart'; // GearVerificationView

@freezed
abstract class GearVerificationView with _$GearVerificationView {
  const GearVerificationView._();

  @jsonSerializable
  const factory GearVerificationView({
    /// id
    @JsonKey(name: GearVerificationView.idKey_) required String id,

    /// category
    @JsonKey(name: GearVerificationView.categoryKey_)
    required GearCategory category,

    /// status
    @JsonKey(name: GearVerificationView.statusKey_)
    required VerificationStatus status,

    /// make
    @JsonKey(name: GearVerificationView.makeKey_) String? make,

    /// model
    @JsonKey(name: GearVerificationView.modelKey_) String? model,

    /// serialHint
    @JsonKey(name: GearVerificationView.serialHintKey_) String? serialHint,

    /// sensorSize
    @JsonKey(name: GearVerificationView.sensorSizeKey_) SensorSize? sensorSize,

    /// apertureType
    @JsonKey(name: GearVerificationView.apertureTypeKey_)
    ApertureType? apertureType,

    /// minFocalMm
    @JsonKey(name: GearVerificationView.minFocalMmKey_) String? minFocalMm,

    /// maxFocalMm
    @JsonKey(name: GearVerificationView.maxFocalMmKey_) String? maxFocalMm,

    /// maxAperture
    @JsonKey(name: GearVerificationView.maxApertureKey_) String? maxAperture,

    /// reviewReason
    @JsonKey(name: GearVerificationView.reviewReasonKey_) String? reviewReason,

    /// verifiedAt
    @JsonKey(name: GearVerificationView.verifiedAtKey_) DateTime? verifiedAt,

    /// createdAt
    @JsonKey(name: GearVerificationView.createdAtKey_)
    required DateTime createdAt,
  }) = _GearVerificationView;

  factory GearVerificationView.fromJson(Map<String, dynamic> json) =>
      _$GearVerificationViewFromJson(json);

  static const String idKey_ = r'id';

  static const String categoryKey_ = r'category';

  static const String statusKey_ = r'status';

  static const String makeKey_ = r'make';

  static const String modelKey_ = r'model';

  static const String serialHintKey_ = r'serial_hint';

  static const String sensorSizeKey_ = r'sensor_size';

  static const String apertureTypeKey_ = r'aperture_type';

  static const String minFocalMmKey_ = r'min_focal_mm';

  static const String maxFocalMmKey_ = r'max_focal_mm';

  static const String maxApertureKey_ = r'max_aperture';

  static const String reviewReasonKey_ = r'review_reason';

  static const String verifiedAtKey_ = r'verified_at';

  static const String createdAtKey_ = r'created_at';
}
