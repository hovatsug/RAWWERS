// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_activate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProActivateResponse _$ProActivateResponseFromJson(Map<String, dynamic> json) =>
    _ProActivateResponse(
      isAcceptingBookings: json['is_accepting_bookings'] as bool,
      completenessScore: (json['completeness_score'] as num).toInt(),
      kycStatus: json['kyc_status'] as String,
    );

Map<String, dynamic> _$ProActivateResponseToJson(
  _ProActivateResponse instance,
) => <String, dynamic>{
  'is_accepting_bookings': instance.isAcceptingBookings,
  'completeness_score': instance.completenessScore,
  'kyc_status': instance.kycStatus,
};
