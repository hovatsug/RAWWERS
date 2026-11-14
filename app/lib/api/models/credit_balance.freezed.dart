// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreditBalance {

/// balance
@JsonKey(name: CreditBalance.balanceKey_) String get balance;/// currency
@JsonKey(name: CreditBalance.currencyKey_) String get currency;
/// Create a copy of CreditBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditBalanceCopyWith<CreditBalance> get copyWith => _$CreditBalanceCopyWithImpl<CreditBalance>(this as CreditBalance, _$identity);

  /// Serializes this CreditBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditBalance&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balance,currency);

@override
String toString() {
  return 'CreditBalance(balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $CreditBalanceCopyWith<$Res>  {
  factory $CreditBalanceCopyWith(CreditBalance value, $Res Function(CreditBalance) _then) = _$CreditBalanceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreditBalance.balanceKey_) String balance,@JsonKey(name: CreditBalance.currencyKey_) String currency
});




}
/// @nodoc
class _$CreditBalanceCopyWithImpl<$Res>
    implements $CreditBalanceCopyWith<$Res> {
  _$CreditBalanceCopyWithImpl(this._self, this._then);

  final CreditBalance _self;
  final $Res Function(CreditBalance) _then;

/// Create a copy of CreditBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balance = null,Object? currency = null,}) {
  return _then(_self.copyWith(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditBalance].
extension CreditBalancePatterns on CreditBalance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditBalance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditBalance value)  $default,){
final _that = this;
switch (_that) {
case _CreditBalance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditBalance value)?  $default,){
final _that = this;
switch (_that) {
case _CreditBalance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreditBalance.balanceKey_)  String balance, @JsonKey(name: CreditBalance.currencyKey_)  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditBalance() when $default != null:
return $default(_that.balance,_that.currency);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreditBalance.balanceKey_)  String balance, @JsonKey(name: CreditBalance.currencyKey_)  String currency)  $default,) {final _that = this;
switch (_that) {
case _CreditBalance():
return $default(_that.balance,_that.currency);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreditBalance.balanceKey_)  String balance, @JsonKey(name: CreditBalance.currencyKey_)  String currency)?  $default,) {final _that = this;
switch (_that) {
case _CreditBalance() when $default != null:
return $default(_that.balance,_that.currency);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreditBalance extends CreditBalance {
  const _CreditBalance({@JsonKey(name: CreditBalance.balanceKey_) required this.balance, @JsonKey(name: CreditBalance.currencyKey_) required this.currency}): super._();
  factory _CreditBalance.fromJson(Map<String, dynamic> json) => _$CreditBalanceFromJson(json);

/// balance
@override@JsonKey(name: CreditBalance.balanceKey_) final  String balance;
/// currency
@override@JsonKey(name: CreditBalance.currencyKey_) final  String currency;

/// Create a copy of CreditBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditBalanceCopyWith<_CreditBalance> get copyWith => __$CreditBalanceCopyWithImpl<_CreditBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditBalance&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balance,currency);

@override
String toString() {
  return 'CreditBalance(balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$CreditBalanceCopyWith<$Res> implements $CreditBalanceCopyWith<$Res> {
  factory _$CreditBalanceCopyWith(_CreditBalance value, $Res Function(_CreditBalance) _then) = __$CreditBalanceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreditBalance.balanceKey_) String balance,@JsonKey(name: CreditBalance.currencyKey_) String currency
});




}
/// @nodoc
class __$CreditBalanceCopyWithImpl<$Res>
    implements _$CreditBalanceCopyWith<$Res> {
  __$CreditBalanceCopyWithImpl(this._self, this._then);

  final _CreditBalance _self;
  final $Res Function(_CreditBalance) _then;

/// Create a copy of CreditBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balance = null,Object? currency = null,}) {
  return _then(_CreditBalance(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
