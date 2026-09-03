// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_exceptions_replace_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityExceptionsReplaceRequest
_$AvailabilityExceptionsReplaceRequestFromJson(Map<String, dynamic> json) =>
    _AvailabilityExceptionsReplaceRequest(
      items: (json['items'] as List<dynamic>?)
          ?.map(
            (e) =>
                AvailabilityExceptionItem.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$AvailabilityExceptionsReplaceRequestToJson(
  _AvailabilityExceptionsReplaceRequest instance,
) => <String, dynamic>{'items': instance.items};
