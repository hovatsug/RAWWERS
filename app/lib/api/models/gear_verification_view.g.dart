// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_verification_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GearVerificationView _$GearVerificationViewFromJson(
  Map<String, dynamic> json,
) => _GearVerificationView(
  id: json['id'] as String,
  category: GearCategory.fromJson(json['category'] as String),
  status: VerificationStatus.fromJson(json['status'] as String),
  make: json['make'] as String?,
  model: json['model'] as String?,
  serialHint: json['serial_hint'] as String?,
  sensorSize: json['sensor_size'] == null
      ? null
      : SensorSize.fromJson(json['sensor_size'] as String),
  apertureType: json['aperture_type'] == null
      ? null
      : ApertureType.fromJson(json['aperture_type'] as String),
  minFocalMm: json['min_focal_mm'] as String?,
  maxFocalMm: json['max_focal_mm'] as String?,
  maxAperture: json['max_aperture'] as String?,
  reviewReason: json['review_reason'] as String?,
  verifiedAt: json['verified_at'] == null
      ? null
      : DateTime.parse(json['verified_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GearVerificationViewToJson(
  _GearVerificationView instance,
) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'status': instance.status,
  'make': instance.make,
  'model': instance.model,
  'serial_hint': instance.serialHint,
  'sensor_size': instance.sensorSize,
  'aperture_type': instance.apertureType,
  'min_focal_mm': instance.minFocalMm,
  'max_focal_mm': instance.maxFocalMm,
  'max_aperture': instance.maxAperture,
  'review_reason': instance.reviewReason,
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
