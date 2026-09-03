// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentSummary {

/// status
@JsonKey(name: PaymentSummary.statusKey_) PaymentStatus get status;/// stripePaymentIntentId
@JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_) String get stripePaymentIntentId;/// amount
@JsonKey(name: PaymentSummary.amountKey_) String get amount;/// currency
@JsonKey(name: PaymentSummary.currencyKey_) String get currency;/// lastError
@JsonKey(name: PaymentSummary.lastErrorKey_) String? get lastError;
/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<PaymentSummary> get copyWith => _$PaymentSummaryCopyWithImpl<PaymentSummary>(this as PaymentSummary, _$identity);

  /// Serializes this PaymentSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSummary&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,stripePaymentIntentId,amount,currency,lastError);

@override
String toString() {
  return 'PaymentSummary(status: $status, stripePaymentIntentId: $stripePaymentIntentId, amount: $amount, currency: $currency, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class $PaymentSummaryCopyWith<$Res>  {
  factory $PaymentSummaryCopyWith(PaymentSummary value, $Res Function(PaymentSummary) _then) = _$PaymentSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PaymentSummary.statusKey_) PaymentStatus status,@JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_) String stripePaymentIntentId,@JsonKey(name: PaymentSummary.amountKey_) String amount,@JsonKey(name: PaymentSummary.currencyKey_) String currency,@JsonKey(name: PaymentSummary.lastErrorKey_) String? lastError
});




}
/// @nodoc
class _$PaymentSummaryCopyWithImpl<$Res>
    implements $PaymentSummaryCopyWith<$Res> {
  _$PaymentSummaryCopyWithImpl(this._self, this._then);

  final PaymentSummary _self;
  final $Res Function(PaymentSummary) _then;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? stripePaymentIntentId = null,Object? amount = null,Object? currency = null,Object? lastError = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,stripePaymentIntentId: null == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentSummary].
extension PaymentSummaryPatterns on PaymentSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSummary value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PaymentSummary.statusKey_)  PaymentStatus status, @JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_)  String stripePaymentIntentId, @JsonKey(name: PaymentSummary.amountKey_)  String amount, @JsonKey(name: PaymentSummary.currencyKey_)  String currency, @JsonKey(name: PaymentSummary.lastErrorKey_)  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that.status,_that.stripePaymentIntentId,_that.amount,_that.currency,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PaymentSummary.statusKey_)  PaymentStatus status, @JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_)  String stripePaymentIntentId, @JsonKey(name: PaymentSummary.amountKey_)  String amount, @JsonKey(name: PaymentSummary.currencyKey_)  String currency, @JsonKey(name: PaymentSummary.lastErrorKey_)  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _PaymentSummary():
return $default(_that.status,_that.stripePaymentIntentId,_that.amount,_that.currency,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PaymentSummary.statusKey_)  PaymentStatus status, @JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_)  String stripePaymentIntentId, @JsonKey(name: PaymentSummary.amountKey_)  String amount, @JsonKey(name: PaymentSummary.currencyKey_)  String currency, @JsonKey(name: PaymentSummary.lastErrorKey_)  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that.status,_that.stripePaymentIntentId,_that.amount,_that.currency,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PaymentSummary extends PaymentSummary {
  const _PaymentSummary({@JsonKey(name: PaymentSummary.statusKey_) required this.status, @JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_) required this.stripePaymentIntentId, @JsonKey(name: PaymentSummary.amountKey_) required this.amount, @JsonKey(name: PaymentSummary.currencyKey_) required this.currency, @JsonKey(name: PaymentSummary.lastErrorKey_) this.lastError}): super._();
  factory _PaymentSummary.fromJson(Map<String, dynamic> json) => _$PaymentSummaryFromJson(json);

/// status
@override@JsonKey(name: PaymentSummary.statusKey_) final  PaymentStatus status;
/// stripePaymentIntentId
@override@JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_) final  String stripePaymentIntentId;
/// amount
@override@JsonKey(name: PaymentSummary.amountKey_) final  String amount;
/// currency
@override@JsonKey(name: PaymentSummary.currencyKey_) final  String currency;
/// lastError
@override@JsonKey(name: PaymentSummary.lastErrorKey_) final  String? lastError;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSummaryCopyWith<_PaymentSummary> get copyWith => __$PaymentSummaryCopyWithImpl<_PaymentSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSummary&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,stripePaymentIntentId,amount,currency,lastError);

@override
String toString() {
  return 'PaymentSummary(status: $status, stripePaymentIntentId: $stripePaymentIntentId, amount: $amount, currency: $currency, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$PaymentSummaryCopyWith<$Res> implements $PaymentSummaryCopyWith<$Res> {
  factory _$PaymentSummaryCopyWith(_PaymentSummary value, $Res Function(_PaymentSummary) _then) = __$PaymentSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PaymentSummary.statusKey_) PaymentStatus status,@JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_) String stripePaymentIntentId,@JsonKey(name: PaymentSummary.amountKey_) String amount,@JsonKey(name: PaymentSummary.currencyKey_) String currency,@JsonKey(name: PaymentSummary.lastErrorKey_) String? lastError
});




}
/// @nodoc
class __$PaymentSummaryCopyWithImpl<$Res>
    implements _$PaymentSummaryCopyWith<$Res> {
  __$PaymentSummaryCopyWithImpl(this._self, this._then);

  final _PaymentSummary _self;
  final $Res Function(_PaymentSummary) _then;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? stripePaymentIntentId = null,Object? amount = null,Object? currency = null,Object? lastError = freezed,}) {
  return _then(_PaymentSummary(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,stripePaymentIntentId: null == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
