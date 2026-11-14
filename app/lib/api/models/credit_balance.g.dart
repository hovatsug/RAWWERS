// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditBalance _$CreditBalanceFromJson(Map<String, dynamic> json) =>
    _CreditBalance(
      balance: json['balance'] as String,
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$CreditBalanceToJson(_CreditBalance instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'currency': instance.currency,
    };
