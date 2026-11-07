// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_pay_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingPayResponse {

/// bookingId
@JsonKey(name: ClientBookingPayResponse.bookingIdKey_) String get bookingId;/// gigId
@JsonKey(name: ClientBookingPayResponse.gigIdKey_) String get gigId;/// paymentIntentId
@JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_) String get paymentIntentId;/// paymentIntentClientSecret
@JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_) String get paymentIntentClientSecret;/// mode
@JsonKey(name: ClientBookingPayResponse.modeKey_) String get mode;/// creditEur
@JsonKey(name: ClientBookingPayResponse.creditEurKey_) String get creditEur;/// amountEur
@JsonKey(name: ClientBookingPayResponse.amountEurKey_) String? get amountEur;
/// Create a copy of ClientBookingPayResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingPayResponseCopyWith<ClientBookingPayResponse> get copyWith => _$ClientBookingPayResponseCopyWithImpl<ClientBookingPayResponse>(this as ClientBookingPayResponse, _$identity);

  /// Serializes this ClientBookingPayResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingPayResponse&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.creditEur, creditEur) || other.creditEur == creditEur)&&(identical(other.amountEur, amountEur) || other.amountEur == amountEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,gigId,paymentIntentId,paymentIntentClientSecret,mode,creditEur,amountEur);

@override
String toString() {
  return 'ClientBookingPayResponse(bookingId: $bookingId, gigId: $gigId, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret, mode: $mode, creditEur: $creditEur, amountEur: $amountEur)';
}


}

/// @nodoc
abstract mixin class $ClientBookingPayResponseCopyWith<$Res>  {
  factory $ClientBookingPayResponseCopyWith(ClientBookingPayResponse value, $Res Function(ClientBookingPayResponse) _then) = _$ClientBookingPayResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingPayResponse.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingPayResponse.gigIdKey_) String gigId,@JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret,@JsonKey(name: ClientBookingPayResponse.modeKey_) String mode,@JsonKey(name: ClientBookingPayResponse.creditEurKey_) String creditEur,@JsonKey(name: ClientBookingPayResponse.amountEurKey_) String? amountEur
});




}
/// @nodoc
class _$ClientBookingPayResponseCopyWithImpl<$Res>
    implements $ClientBookingPayResponseCopyWith<$Res> {
  _$ClientBookingPayResponseCopyWithImpl(this._self, this._then);

  final ClientBookingPayResponse _self;
  final $Res Function(ClientBookingPayResponse) _then;

/// Create a copy of ClientBookingPayResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? gigId = null,Object? paymentIntentId = null,Object? paymentIntentClientSecret = null,Object? mode = null,Object? creditEur = null,Object? amountEur = freezed,}) {
  return _then(_self.copyWith(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,creditEur: null == creditEur ? _self.creditEur : creditEur // ignore: cast_nullable_to_non_nullable
as String,amountEur: freezed == amountEur ? _self.amountEur : amountEur // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientBookingPayResponse].
extension ClientBookingPayResponsePatterns on ClientBookingPayResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingPayResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingPayResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingPayResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingPayResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingPayResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingPayResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingPayResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingPayResponse.gigIdKey_)  String gigId, @JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: ClientBookingPayResponse.modeKey_)  String mode, @JsonKey(name: ClientBookingPayResponse.creditEurKey_)  String creditEur, @JsonKey(name: ClientBookingPayResponse.amountEurKey_)  String? amountEur)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingPayResponse() when $default != null:
return $default(_that.bookingId,_that.gigId,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.mode,_that.creditEur,_that.amountEur);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingPayResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingPayResponse.gigIdKey_)  String gigId, @JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: ClientBookingPayResponse.modeKey_)  String mode, @JsonKey(name: ClientBookingPayResponse.creditEurKey_)  String creditEur, @JsonKey(name: ClientBookingPayResponse.amountEurKey_)  String? amountEur)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingPayResponse():
return $default(_that.bookingId,_that.gigId,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.mode,_that.creditEur,_that.amountEur);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingPayResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingPayResponse.gigIdKey_)  String gigId, @JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: ClientBookingPayResponse.modeKey_)  String mode, @JsonKey(name: ClientBookingPayResponse.creditEurKey_)  String creditEur, @JsonKey(name: ClientBookingPayResponse.amountEurKey_)  String? amountEur)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingPayResponse() when $default != null:
return $default(_that.bookingId,_that.gigId,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.mode,_that.creditEur,_that.amountEur);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingPayResponse extends ClientBookingPayResponse {
  const _ClientBookingPayResponse({@JsonKey(name: ClientBookingPayResponse.bookingIdKey_) required this.bookingId, @JsonKey(name: ClientBookingPayResponse.gigIdKey_) required this.gigId, @JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_) required this.paymentIntentId, @JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_) required this.paymentIntentClientSecret, @JsonKey(name: ClientBookingPayResponse.modeKey_) required this.mode, @JsonKey(name: ClientBookingPayResponse.creditEurKey_) this.creditEur = '0.00', @JsonKey(name: ClientBookingPayResponse.amountEurKey_) this.amountEur}): super._();
  factory _ClientBookingPayResponse.fromJson(Map<String, dynamic> json) => _$ClientBookingPayResponseFromJson(json);

/// bookingId
@override@JsonKey(name: ClientBookingPayResponse.bookingIdKey_) final  String bookingId;
/// gigId
@override@JsonKey(name: ClientBookingPayResponse.gigIdKey_) final  String gigId;
/// paymentIntentId
@override@JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_) final  String paymentIntentId;
/// paymentIntentClientSecret
@override@JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_) final  String paymentIntentClientSecret;
/// mode
@override@JsonKey(name: ClientBookingPayResponse.modeKey_) final  String mode;
/// creditEur
@override@JsonKey(name: ClientBookingPayResponse.creditEurKey_) final  String creditEur;
/// amountEur
@override@JsonKey(name: ClientBookingPayResponse.amountEurKey_) final  String? amountEur;

/// Create a copy of ClientBookingPayResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingPayResponseCopyWith<_ClientBookingPayResponse> get copyWith => __$ClientBookingPayResponseCopyWithImpl<_ClientBookingPayResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingPayResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingPayResponse&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.creditEur, creditEur) || other.creditEur == creditEur)&&(identical(other.amountEur, amountEur) || other.amountEur == amountEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,gigId,paymentIntentId,paymentIntentClientSecret,mode,creditEur,amountEur);

@override
String toString() {
  return 'ClientBookingPayResponse(bookingId: $bookingId, gigId: $gigId, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret, mode: $mode, creditEur: $creditEur, amountEur: $amountEur)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingPayResponseCopyWith<$Res> implements $ClientBookingPayResponseCopyWith<$Res> {
  factory _$ClientBookingPayResponseCopyWith(_ClientBookingPayResponse value, $Res Function(_ClientBookingPayResponse) _then) = __$ClientBookingPayResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingPayResponse.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingPayResponse.gigIdKey_) String gigId,@JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret,@JsonKey(name: ClientBookingPayResponse.modeKey_) String mode,@JsonKey(name: ClientBookingPayResponse.creditEurKey_) String creditEur,@JsonKey(name: ClientBookingPayResponse.amountEurKey_) String? amountEur
});




}
/// @nodoc
class __$ClientBookingPayResponseCopyWithImpl<$Res>
    implements _$ClientBookingPayResponseCopyWith<$Res> {
  __$ClientBookingPayResponseCopyWithImpl(this._self, this._then);

  final _ClientBookingPayResponse _self;
  final $Res Function(_ClientBookingPayResponse) _then;

/// Create a copy of ClientBookingPayResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? gigId = null,Object? paymentIntentId = null,Object? paymentIntentClientSecret = null,Object? mode = null,Object? creditEur = null,Object? amountEur = freezed,}) {
  return _then(_ClientBookingPayResponse(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,creditEur: null == creditEur ? _self.creditEur : creditEur // ignore: cast_nullable_to_non_nullable
as String,amountEur: freezed == amountEur ? _self.amountEur : amountEur // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
