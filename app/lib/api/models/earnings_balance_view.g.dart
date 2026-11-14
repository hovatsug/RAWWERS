// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_balance_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EarningsBalanceView _$EarningsBalanceViewFromJson(Map<String, dynamic> json) =>
    _EarningsBalanceView(
      currency: json['currency'] as String,
      pending: json['pending'] as String,
      available: json['available'] as String,
      held: json['held'] as String,
      requested: json['requested'] as String? ?? '0.00',
      reserved: json['reserved'] as String,
      paidOut: json['paid_out'] as String? ?? '0.00',
      lifetime: json['lifetime'] as String? ?? '0.00',
      withdrawable: json['withdrawable'] as String,
      adjustmentOwed: json['adjustment_owed'] as String? ?? '0.00',
      payoutMinimum: json['payout_minimum'] as String,
    );

Map<String, dynamic> _$EarningsBalanceViewToJson(
  _EarningsBalanceView instance,
) => <String, dynamic>{
  'currency': instance.currency,
  'pending': instance.pending,
  'available': instance.available,
  'held': instance.held,
  'requested': instance.requested,
  'reserved': instance.reserved,
  'paid_out': instance.paidOut,
  'lifetime': instance.lifetime,
  'withdrawable': instance.withdrawable,
  'adjustment_owed': instance.adjustmentOwed,
  'payout_minimum': instance.payoutMinimum,
};
