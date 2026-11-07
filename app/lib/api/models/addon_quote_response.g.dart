// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addon_quote_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddonQuoteResponse _$AddonQuoteResponseFromJson(Map<String, dynamic> json) =>
    _AddonQuoteResponse(
      alreadyChosen: (json['already_chosen'] as num).toInt(),
      adding: (json['adding'] as num).toInt(),
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      windowEndsAt: json['window_ends_at'] == null
          ? null
          : DateTime.parse(json['window_ends_at'] as String),
    );

Map<String, dynamic> _$AddonQuoteResponseToJson(_AddonQuoteResponse instance) =>
    <String, dynamic>{
      'already_chosen': instance.alreadyChosen,
      'adding': instance.adding,
      'amount': instance.amount,
      'currency': instance.currency,
      'window_ends_at': instance.windowEndsAt?.toIso8601String(),
    };
