// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_booking_marketing_settings_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateBookingMarketingSettingsRequest
_$UpdateBookingMarketingSettingsRequestFromJson(Map<String, dynamic> json) =>
    _UpdateBookingMarketingSettingsRequest(
      allowMarketing: json['allow_marketing'] as bool?,
      includesChildren: json['includes_children'] as bool?,
    );

Map<String, dynamic> _$UpdateBookingMarketingSettingsRequestToJson(
  _UpdateBookingMarketingSettingsRequest instance,
) => <String, dynamic>{
  'allow_marketing': instance.allowMarketing,
  'includes_children': instance.includesChildren,
};
