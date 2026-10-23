// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_balance_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EarningsBalanceView _$EarningsBalanceViewFromJson(Map<String, dynamic> json) =>
    _EarningsBalanceView(
      pendingEur: json['pending_eur'] as String,
      availableEur: json['available_eur'] as String,
      heldEur: json['held_eur'] as String,
      reservedEur: json['reserved_eur'] as String,
      paidOutEur: json['paid_out_eur'] as String? ?? '0.00',
      lifetimeEur: json['lifetime_eur'] as String? ?? '0.00',
      withdrawableEur: json['withdrawable_eur'] as String,
      adjustmentOwedEur: json['adjustment_owed_eur'] as String? ?? '0.00',
    );

Map<String, dynamic> _$EarningsBalanceViewToJson(
  _EarningsBalanceView instance,
) => <String, dynamic>{
  'pending_eur': instance.pendingEur,
  'available_eur': instance.availableEur,
  'held_eur': instance.heldEur,
  'reserved_eur': instance.reservedEur,
  'paid_out_eur': instance.paidOutEur,
  'lifetime_eur': instance.lifetimeEur,
  'withdrawable_eur': instance.withdrawableEur,
  'adjustment_owed_eur': instance.adjustmentOwedEur,
};
