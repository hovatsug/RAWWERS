// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reschedule_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RescheduleRequest _$RescheduleRequestFromJson(Map<String, dynamic> json) =>
    _RescheduleRequest(
      clientTimezone: json['client_timezone'] as String,
      proposedWindows: (json['proposed_windows'] as List<dynamic>?)
          ?.map((e) => TimeWindowItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RescheduleRequestToJson(_RescheduleRequest instance) =>
    <String, dynamic>{
      'client_timezone': instance.clientTimezone,
      'proposed_windows': instance.proposedWindows,
    };
