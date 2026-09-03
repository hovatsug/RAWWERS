// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_exceptions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityExceptionsResponse _$AvailabilityExceptionsResponseFromJson(
  Map<String, dynamic> json,
) => _AvailabilityExceptionsResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map(
        (e) => AvailabilityExceptionView.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$AvailabilityExceptionsResponseToJson(
  _AvailabilityExceptionsResponse instance,
) => <String, dynamic>{'items': instance.items};
