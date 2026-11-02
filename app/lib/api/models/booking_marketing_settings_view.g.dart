// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_marketing_settings_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingMarketingSettingsView _$BookingMarketingSettingsViewFromJson(
  Map<String, dynamic> json,
) => _BookingMarketingSettingsView(
  allowMarketing: json['allow_marketing'] as bool,
  includesChildren: json['includes_children'] as bool,
  locked: json['locked'] as bool,
  optedIn: json['opted_in'] as bool,
);

Map<String, dynamic> _$BookingMarketingSettingsViewToJson(
  _BookingMarketingSettingsView instance,
) => <String, dynamic>{
  'allow_marketing': instance.allowMarketing,
  'includes_children': instance.includesChildren,
  'locked': instance.locked,
  'opted_in': instance.optedIn,
};
