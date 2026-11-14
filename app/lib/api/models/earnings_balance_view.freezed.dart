// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_balance_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EarningsBalanceView {

/// currency
@JsonKey(name: EarningsBalanceView.currencyKey_) String get currency;/// pending
@JsonKey(name: EarningsBalanceView.pendingKey_) String get pending;/// available
@JsonKey(name: EarningsBalanceView.availableKey_) String get available;/// held
@JsonKey(name: EarningsBalanceView.heldKey_) String get held;/// requested
@JsonKey(name: EarningsBalanceView.requestedKey_) String get requested;/// reserved
@JsonKey(name: EarningsBalanceView.reservedKey_) String get reserved;/// paidOut
@JsonKey(name: EarningsBalanceView.paidOutKey_) String get paidOut;/// lifetime
@JsonKey(name: EarningsBalanceView.lifetimeKey_) String get lifetime;/// withdrawable
@JsonKey(name: EarningsBalanceView.withdrawableKey_) String get withdrawable;/// adjustmentOwed
@JsonKey(name: EarningsBalanceView.adjustmentOwedKey_) String get adjustmentOwed;/// payoutMinimum
@JsonKey(name: EarningsBalanceView.payoutMinimumKey_) String get payoutMinimum;
/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsBalanceViewCopyWith<EarningsBalanceView> get copyWith => _$EarningsBalanceViewCopyWithImpl<EarningsBalanceView>(this as EarningsBalanceView, _$identity);

  /// Serializes this EarningsBalanceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsBalanceView&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.available, available) || other.available == available)&&(identical(other.held, held) || other.held == held)&&(identical(other.requested, requested) || other.requested == requested)&&(identical(other.reserved, reserved) || other.reserved == reserved)&&(identical(other.paidOut, paidOut) || other.paidOut == paidOut)&&(identical(other.lifetime, lifetime) || other.lifetime == lifetime)&&(identical(other.withdrawable, withdrawable) || other.withdrawable == withdrawable)&&(identical(other.adjustmentOwed, adjustmentOwed) || other.adjustmentOwed == adjustmentOwed)&&(identical(other.payoutMinimum, payoutMinimum) || other.payoutMinimum == payoutMinimum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,pending,available,held,requested,reserved,paidOut,lifetime,withdrawable,adjustmentOwed,payoutMinimum);

@override
String toString() {
  return 'EarningsBalanceView(currency: $currency, pending: $pending, available: $available, held: $held, requested: $requested, reserved: $reserved, paidOut: $paidOut, lifetime: $lifetime, withdrawable: $withdrawable, adjustmentOwed: $adjustmentOwed, payoutMinimum: $payoutMinimum)';
}


}

/// @nodoc
abstract mixin class $EarningsBalanceViewCopyWith<$Res>  {
  factory $EarningsBalanceViewCopyWith(EarningsBalanceView value, $Res Function(EarningsBalanceView) _then) = _$EarningsBalanceViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: EarningsBalanceView.currencyKey_) String currency,@JsonKey(name: EarningsBalanceView.pendingKey_) String pending,@JsonKey(name: EarningsBalanceView.availableKey_) String available,@JsonKey(name: EarningsBalanceView.heldKey_) String held,@JsonKey(name: EarningsBalanceView.requestedKey_) String requested,@JsonKey(name: EarningsBalanceView.reservedKey_) String reserved,@JsonKey(name: EarningsBalanceView.paidOutKey_) String paidOut,@JsonKey(name: EarningsBalanceView.lifetimeKey_) String lifetime,@JsonKey(name: EarningsBalanceView.withdrawableKey_) String withdrawable,@JsonKey(name: EarningsBalanceView.adjustmentOwedKey_) String adjustmentOwed,@JsonKey(name: EarningsBalanceView.payoutMinimumKey_) String payoutMinimum
});




}
/// @nodoc
class _$EarningsBalanceViewCopyWithImpl<$Res>
    implements $EarningsBalanceViewCopyWith<$Res> {
  _$EarningsBalanceViewCopyWithImpl(this._self, this._then);

  final EarningsBalanceView _self;
  final $Res Function(EarningsBalanceView) _then;

/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? pending = null,Object? available = null,Object? held = null,Object? requested = null,Object? reserved = null,Object? paidOut = null,Object? lifetime = null,Object? withdrawable = null,Object? adjustmentOwed = null,Object? payoutMinimum = null,}) {
  return _then(_self.copyWith(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as String,requested: null == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as String,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as String,paidOut: null == paidOut ? _self.paidOut : paidOut // ignore: cast_nullable_to_non_nullable
as String,lifetime: null == lifetime ? _self.lifetime : lifetime // ignore: cast_nullable_to_non_nullable
as String,withdrawable: null == withdrawable ? _self.withdrawable : withdrawable // ignore: cast_nullable_to_non_nullable
as String,adjustmentOwed: null == adjustmentOwed ? _self.adjustmentOwed : adjustmentOwed // ignore: cast_nullable_to_non_nullable
as String,payoutMinimum: null == payoutMinimum ? _self.payoutMinimum : payoutMinimum // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsBalanceView].
extension EarningsBalanceViewPatterns on EarningsBalanceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsBalanceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsBalanceView value)  $default,){
final _that = this;
switch (_that) {
case _EarningsBalanceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsBalanceView value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsBalanceView.currencyKey_)  String currency, @JsonKey(name: EarningsBalanceView.pendingKey_)  String pending, @JsonKey(name: EarningsBalanceView.availableKey_)  String available, @JsonKey(name: EarningsBalanceView.heldKey_)  String held, @JsonKey(name: EarningsBalanceView.requestedKey_)  String requested, @JsonKey(name: EarningsBalanceView.reservedKey_)  String reserved, @JsonKey(name: EarningsBalanceView.paidOutKey_)  String paidOut, @JsonKey(name: EarningsBalanceView.lifetimeKey_)  String lifetime, @JsonKey(name: EarningsBalanceView.withdrawableKey_)  String withdrawable, @JsonKey(name: EarningsBalanceView.adjustmentOwedKey_)  String adjustmentOwed, @JsonKey(name: EarningsBalanceView.payoutMinimumKey_)  String payoutMinimum)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
return $default(_that.currency,_that.pending,_that.available,_that.held,_that.requested,_that.reserved,_that.paidOut,_that.lifetime,_that.withdrawable,_that.adjustmentOwed,_that.payoutMinimum);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsBalanceView.currencyKey_)  String currency, @JsonKey(name: EarningsBalanceView.pendingKey_)  String pending, @JsonKey(name: EarningsBalanceView.availableKey_)  String available, @JsonKey(name: EarningsBalanceView.heldKey_)  String held, @JsonKey(name: EarningsBalanceView.requestedKey_)  String requested, @JsonKey(name: EarningsBalanceView.reservedKey_)  String reserved, @JsonKey(name: EarningsBalanceView.paidOutKey_)  String paidOut, @JsonKey(name: EarningsBalanceView.lifetimeKey_)  String lifetime, @JsonKey(name: EarningsBalanceView.withdrawableKey_)  String withdrawable, @JsonKey(name: EarningsBalanceView.adjustmentOwedKey_)  String adjustmentOwed, @JsonKey(name: EarningsBalanceView.payoutMinimumKey_)  String payoutMinimum)  $default,) {final _that = this;
switch (_that) {
case _EarningsBalanceView():
return $default(_that.currency,_that.pending,_that.available,_that.held,_that.requested,_that.reserved,_that.paidOut,_that.lifetime,_that.withdrawable,_that.adjustmentOwed,_that.payoutMinimum);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: EarningsBalanceView.currencyKey_)  String currency, @JsonKey(name: EarningsBalanceView.pendingKey_)  String pending, @JsonKey(name: EarningsBalanceView.availableKey_)  String available, @JsonKey(name: EarningsBalanceView.heldKey_)  String held, @JsonKey(name: EarningsBalanceView.requestedKey_)  String requested, @JsonKey(name: EarningsBalanceView.reservedKey_)  String reserved, @JsonKey(name: EarningsBalanceView.paidOutKey_)  String paidOut, @JsonKey(name: EarningsBalanceView.lifetimeKey_)  String lifetime, @JsonKey(name: EarningsBalanceView.withdrawableKey_)  String withdrawable, @JsonKey(name: EarningsBalanceView.adjustmentOwedKey_)  String adjustmentOwed, @JsonKey(name: EarningsBalanceView.payoutMinimumKey_)  String payoutMinimum)?  $default,) {final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
return $default(_that.currency,_that.pending,_that.available,_that.held,_that.requested,_that.reserved,_that.paidOut,_that.lifetime,_that.withdrawable,_that.adjustmentOwed,_that.payoutMinimum);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _EarningsBalanceView extends EarningsBalanceView {
  const _EarningsBalanceView({@JsonKey(name: EarningsBalanceView.currencyKey_) required this.currency, @JsonKey(name: EarningsBalanceView.pendingKey_) required this.pending, @JsonKey(name: EarningsBalanceView.availableKey_) required this.available, @JsonKey(name: EarningsBalanceView.heldKey_) required this.held, @JsonKey(name: EarningsBalanceView.requestedKey_) this.requested = '0.00', @JsonKey(name: EarningsBalanceView.reservedKey_) required this.reserved, @JsonKey(name: EarningsBalanceView.paidOutKey_) this.paidOut = '0.00', @JsonKey(name: EarningsBalanceView.lifetimeKey_) this.lifetime = '0.00', @JsonKey(name: EarningsBalanceView.withdrawableKey_) required this.withdrawable, @JsonKey(name: EarningsBalanceView.adjustmentOwedKey_) this.adjustmentOwed = '0.00', @JsonKey(name: EarningsBalanceView.payoutMinimumKey_) required this.payoutMinimum}): super._();
  factory _EarningsBalanceView.fromJson(Map<String, dynamic> json) => _$EarningsBalanceViewFromJson(json);

/// currency
@override@JsonKey(name: EarningsBalanceView.currencyKey_) final  String currency;
/// pending
@override@JsonKey(name: EarningsBalanceView.pendingKey_) final  String pending;
/// available
@override@JsonKey(name: EarningsBalanceView.availableKey_) final  String available;
/// held
@override@JsonKey(name: EarningsBalanceView.heldKey_) final  String held;
/// requested
@override@JsonKey(name: EarningsBalanceView.requestedKey_) final  String requested;
/// reserved
@override@JsonKey(name: EarningsBalanceView.reservedKey_) final  String reserved;
/// paidOut
@override@JsonKey(name: EarningsBalanceView.paidOutKey_) final  String paidOut;
/// lifetime
@override@JsonKey(name: EarningsBalanceView.lifetimeKey_) final  String lifetime;
/// withdrawable
@override@JsonKey(name: EarningsBalanceView.withdrawableKey_) final  String withdrawable;
/// adjustmentOwed
@override@JsonKey(name: EarningsBalanceView.adjustmentOwedKey_) final  String adjustmentOwed;
/// payoutMinimum
@override@JsonKey(name: EarningsBalanceView.payoutMinimumKey_) final  String payoutMinimum;

/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsBalanceViewCopyWith<_EarningsBalanceView> get copyWith => __$EarningsBalanceViewCopyWithImpl<_EarningsBalanceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsBalanceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsBalanceView&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.available, available) || other.available == available)&&(identical(other.held, held) || other.held == held)&&(identical(other.requested, requested) || other.requested == requested)&&(identical(other.reserved, reserved) || other.reserved == reserved)&&(identical(other.paidOut, paidOut) || other.paidOut == paidOut)&&(identical(other.lifetime, lifetime) || other.lifetime == lifetime)&&(identical(other.withdrawable, withdrawable) || other.withdrawable == withdrawable)&&(identical(other.adjustmentOwed, adjustmentOwed) || other.adjustmentOwed == adjustmentOwed)&&(identical(other.payoutMinimum, payoutMinimum) || other.payoutMinimum == payoutMinimum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,pending,available,held,requested,reserved,paidOut,lifetime,withdrawable,adjustmentOwed,payoutMinimum);

@override
String toString() {
  return 'EarningsBalanceView(currency: $currency, pending: $pending, available: $available, held: $held, requested: $requested, reserved: $reserved, paidOut: $paidOut, lifetime: $lifetime, withdrawable: $withdrawable, adjustmentOwed: $adjustmentOwed, payoutMinimum: $payoutMinimum)';
}


}

/// @nodoc
abstract mixin class _$EarningsBalanceViewCopyWith<$Res> implements $EarningsBalanceViewCopyWith<$Res> {
  factory _$EarningsBalanceViewCopyWith(_EarningsBalanceView value, $Res Function(_EarningsBalanceView) _then) = __$EarningsBalanceViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: EarningsBalanceView.currencyKey_) String currency,@JsonKey(name: EarningsBalanceView.pendingKey_) String pending,@JsonKey(name: EarningsBalanceView.availableKey_) String available,@JsonKey(name: EarningsBalanceView.heldKey_) String held,@JsonKey(name: EarningsBalanceView.requestedKey_) String requested,@JsonKey(name: EarningsBalanceView.reservedKey_) String reserved,@JsonKey(name: EarningsBalanceView.paidOutKey_) String paidOut,@JsonKey(name: EarningsBalanceView.lifetimeKey_) String lifetime,@JsonKey(name: EarningsBalanceView.withdrawableKey_) String withdrawable,@JsonKey(name: EarningsBalanceView.adjustmentOwedKey_) String adjustmentOwed,@JsonKey(name: EarningsBalanceView.payoutMinimumKey_) String payoutMinimum
});




}
/// @nodoc
class __$EarningsBalanceViewCopyWithImpl<$Res>
    implements _$EarningsBalanceViewCopyWith<$Res> {
  __$EarningsBalanceViewCopyWithImpl(this._self, this._then);

  final _EarningsBalanceView _self;
  final $Res Function(_EarningsBalanceView) _then;

/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? pending = null,Object? available = null,Object? held = null,Object? requested = null,Object? reserved = null,Object? paidOut = null,Object? lifetime = null,Object? withdrawable = null,Object? adjustmentOwed = null,Object? payoutMinimum = null,}) {
  return _then(_EarningsBalanceView(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as String,requested: null == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as String,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as String,paidOut: null == paidOut ? _self.paidOut : paidOut // ignore: cast_nullable_to_non_nullable
as String,lifetime: null == lifetime ? _self.lifetime : lifetime // ignore: cast_nullable_to_non_nullable
as String,withdrawable: null == withdrawable ? _self.withdrawable : withdrawable // ignore: cast_nullable_to_non_nullable
as String,adjustmentOwed: null == adjustmentOwed ? _self.adjustmentOwed : adjustmentOwed // ignore: cast_nullable_to_non_nullable
as String,payoutMinimum: null == payoutMinimum ? _self.payoutMinimum : payoutMinimum // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
