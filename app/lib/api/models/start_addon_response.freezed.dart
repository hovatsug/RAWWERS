// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'start_addon_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StartAddonResponse {

/// addonId
@JsonKey(name: StartAddonResponse.addonIdKey_) String get addonId;/// amount
@JsonKey(name: StartAddonResponse.amountKey_) String get amount;/// currency
@JsonKey(name: StartAddonResponse.currencyKey_) String get currency;/// paymentIntentClientSecret
@JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_) String? get paymentIntentClientSecret;/// status
@JsonKey(name: StartAddonResponse.statusKey_) String get status;
/// Create a copy of StartAddonResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartAddonResponseCopyWith<StartAddonResponse> get copyWith => _$StartAddonResponseCopyWithImpl<StartAddonResponse>(this as StartAddonResponse, _$identity);

  /// Serializes this StartAddonResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartAddonResponse&&(identical(other.addonId, addonId) || other.addonId == addonId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,addonId,amount,currency,paymentIntentClientSecret,status);

@override
String toString() {
  return 'StartAddonResponse(addonId: $addonId, amount: $amount, currency: $currency, paymentIntentClientSecret: $paymentIntentClientSecret, status: $status)';
}


}

/// @nodoc
abstract mixin class $StartAddonResponseCopyWith<$Res>  {
  factory $StartAddonResponseCopyWith(StartAddonResponse value, $Res Function(StartAddonResponse) _then) = _$StartAddonResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: StartAddonResponse.addonIdKey_) String addonId,@JsonKey(name: StartAddonResponse.amountKey_) String amount,@JsonKey(name: StartAddonResponse.currencyKey_) String currency,@JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_) String? paymentIntentClientSecret,@JsonKey(name: StartAddonResponse.statusKey_) String status
});




}
/// @nodoc
class _$StartAddonResponseCopyWithImpl<$Res>
    implements $StartAddonResponseCopyWith<$Res> {
  _$StartAddonResponseCopyWithImpl(this._self, this._then);

  final StartAddonResponse _self;
  final $Res Function(StartAddonResponse) _then;

/// Create a copy of StartAddonResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addonId = null,Object? amount = null,Object? currency = null,Object? paymentIntentClientSecret = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
addonId: null == addonId ? _self.addonId : addonId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: freezed == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StartAddonResponse].
extension StartAddonResponsePatterns on StartAddonResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartAddonResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartAddonResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartAddonResponse value)  $default,){
final _that = this;
switch (_that) {
case _StartAddonResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartAddonResponse value)?  $default,){
final _that = this;
switch (_that) {
case _StartAddonResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: StartAddonResponse.addonIdKey_)  String addonId, @JsonKey(name: StartAddonResponse.amountKey_)  String amount, @JsonKey(name: StartAddonResponse.currencyKey_)  String currency, @JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_)  String? paymentIntentClientSecret, @JsonKey(name: StartAddonResponse.statusKey_)  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartAddonResponse() when $default != null:
return $default(_that.addonId,_that.amount,_that.currency,_that.paymentIntentClientSecret,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: StartAddonResponse.addonIdKey_)  String addonId, @JsonKey(name: StartAddonResponse.amountKey_)  String amount, @JsonKey(name: StartAddonResponse.currencyKey_)  String currency, @JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_)  String? paymentIntentClientSecret, @JsonKey(name: StartAddonResponse.statusKey_)  String status)  $default,) {final _that = this;
switch (_that) {
case _StartAddonResponse():
return $default(_that.addonId,_that.amount,_that.currency,_that.paymentIntentClientSecret,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: StartAddonResponse.addonIdKey_)  String addonId, @JsonKey(name: StartAddonResponse.amountKey_)  String amount, @JsonKey(name: StartAddonResponse.currencyKey_)  String currency, @JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_)  String? paymentIntentClientSecret, @JsonKey(name: StartAddonResponse.statusKey_)  String status)?  $default,) {final _that = this;
switch (_that) {
case _StartAddonResponse() when $default != null:
return $default(_that.addonId,_that.amount,_that.currency,_that.paymentIntentClientSecret,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _StartAddonResponse extends StartAddonResponse {
  const _StartAddonResponse({@JsonKey(name: StartAddonResponse.addonIdKey_) required this.addonId, @JsonKey(name: StartAddonResponse.amountKey_) required this.amount, @JsonKey(name: StartAddonResponse.currencyKey_) required this.currency, @JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_) this.paymentIntentClientSecret, @JsonKey(name: StartAddonResponse.statusKey_) required this.status}): super._();
  factory _StartAddonResponse.fromJson(Map<String, dynamic> json) => _$StartAddonResponseFromJson(json);

/// addonId
@override@JsonKey(name: StartAddonResponse.addonIdKey_) final  String addonId;
/// amount
@override@JsonKey(name: StartAddonResponse.amountKey_) final  String amount;
/// currency
@override@JsonKey(name: StartAddonResponse.currencyKey_) final  String currency;
/// paymentIntentClientSecret
@override@JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_) final  String? paymentIntentClientSecret;
/// status
@override@JsonKey(name: StartAddonResponse.statusKey_) final  String status;

/// Create a copy of StartAddonResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartAddonResponseCopyWith<_StartAddonResponse> get copyWith => __$StartAddonResponseCopyWithImpl<_StartAddonResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartAddonResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartAddonResponse&&(identical(other.addonId, addonId) || other.addonId == addonId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,addonId,amount,currency,paymentIntentClientSecret,status);

@override
String toString() {
  return 'StartAddonResponse(addonId: $addonId, amount: $amount, currency: $currency, paymentIntentClientSecret: $paymentIntentClientSecret, status: $status)';
}


}

/// @nodoc
abstract mixin class _$StartAddonResponseCopyWith<$Res> implements $StartAddonResponseCopyWith<$Res> {
  factory _$StartAddonResponseCopyWith(_StartAddonResponse value, $Res Function(_StartAddonResponse) _then) = __$StartAddonResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: StartAddonResponse.addonIdKey_) String addonId,@JsonKey(name: StartAddonResponse.amountKey_) String amount,@JsonKey(name: StartAddonResponse.currencyKey_) String currency,@JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_) String? paymentIntentClientSecret,@JsonKey(name: StartAddonResponse.statusKey_) String status
});




}
/// @nodoc
class __$StartAddonResponseCopyWithImpl<$Res>
    implements _$StartAddonResponseCopyWith<$Res> {
  __$StartAddonResponseCopyWithImpl(this._self, this._then);

  final _StartAddonResponse _self;
  final $Res Function(_StartAddonResponse) _then;

/// Create a copy of StartAddonResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addonId = null,Object? amount = null,Object? currency = null,Object? paymentIntentClientSecret = freezed,Object? status = null,}) {
  return _then(_StartAddonResponse(
addonId: null == addonId ? _self.addonId : addonId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: freezed == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
