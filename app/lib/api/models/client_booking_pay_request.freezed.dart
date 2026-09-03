// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_pay_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingPayRequest {

/// paymentMode
@JsonKey(name: ClientBookingPayRequest.paymentModeKey_) String get paymentMode;/// pointsToSpend
@JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_) int? get pointsToSpend;
/// Create a copy of ClientBookingPayRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingPayRequestCopyWith<ClientBookingPayRequest> get copyWith => _$ClientBookingPayRequestCopyWithImpl<ClientBookingPayRequest>(this as ClientBookingPayRequest, _$identity);

  /// Serializes this ClientBookingPayRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingPayRequest&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.pointsToSpend, pointsToSpend) || other.pointsToSpend == pointsToSpend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentMode,pointsToSpend);

@override
String toString() {
  return 'ClientBookingPayRequest(paymentMode: $paymentMode, pointsToSpend: $pointsToSpend)';
}


}

/// @nodoc
abstract mixin class $ClientBookingPayRequestCopyWith<$Res>  {
  factory $ClientBookingPayRequestCopyWith(ClientBookingPayRequest value, $Res Function(ClientBookingPayRequest) _then) = _$ClientBookingPayRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingPayRequest.paymentModeKey_) String paymentMode,@JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_) int? pointsToSpend
});




}
/// @nodoc
class _$ClientBookingPayRequestCopyWithImpl<$Res>
    implements $ClientBookingPayRequestCopyWith<$Res> {
  _$ClientBookingPayRequestCopyWithImpl(this._self, this._then);

  final ClientBookingPayRequest _self;
  final $Res Function(ClientBookingPayRequest) _then;

/// Create a copy of ClientBookingPayRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentMode = null,Object? pointsToSpend = freezed,}) {
  return _then(_self.copyWith(
paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,pointsToSpend: freezed == pointsToSpend ? _self.pointsToSpend : pointsToSpend // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientBookingPayRequest].
extension ClientBookingPayRequestPatterns on ClientBookingPayRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingPayRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingPayRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingPayRequest value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingPayRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingPayRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingPayRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingPayRequest.paymentModeKey_)  String paymentMode, @JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_)  int? pointsToSpend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingPayRequest() when $default != null:
return $default(_that.paymentMode,_that.pointsToSpend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingPayRequest.paymentModeKey_)  String paymentMode, @JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_)  int? pointsToSpend)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingPayRequest():
return $default(_that.paymentMode,_that.pointsToSpend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingPayRequest.paymentModeKey_)  String paymentMode, @JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_)  int? pointsToSpend)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingPayRequest() when $default != null:
return $default(_that.paymentMode,_that.pointsToSpend);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingPayRequest extends ClientBookingPayRequest {
  const _ClientBookingPayRequest({@JsonKey(name: ClientBookingPayRequest.paymentModeKey_) required this.paymentMode, @JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_) this.pointsToSpend}): super._();
  factory _ClientBookingPayRequest.fromJson(Map<String, dynamic> json) => _$ClientBookingPayRequestFromJson(json);

/// paymentMode
@override@JsonKey(name: ClientBookingPayRequest.paymentModeKey_) final  String paymentMode;
/// pointsToSpend
@override@JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_) final  int? pointsToSpend;

/// Create a copy of ClientBookingPayRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingPayRequestCopyWith<_ClientBookingPayRequest> get copyWith => __$ClientBookingPayRequestCopyWithImpl<_ClientBookingPayRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingPayRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingPayRequest&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.pointsToSpend, pointsToSpend) || other.pointsToSpend == pointsToSpend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentMode,pointsToSpend);

@override
String toString() {
  return 'ClientBookingPayRequest(paymentMode: $paymentMode, pointsToSpend: $pointsToSpend)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingPayRequestCopyWith<$Res> implements $ClientBookingPayRequestCopyWith<$Res> {
  factory _$ClientBookingPayRequestCopyWith(_ClientBookingPayRequest value, $Res Function(_ClientBookingPayRequest) _then) = __$ClientBookingPayRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingPayRequest.paymentModeKey_) String paymentMode,@JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_) int? pointsToSpend
});




}
/// @nodoc
class __$ClientBookingPayRequestCopyWithImpl<$Res>
    implements _$ClientBookingPayRequestCopyWith<$Res> {
  __$ClientBookingPayRequestCopyWithImpl(this._self, this._then);

  final _ClientBookingPayRequest _self;
  final $Res Function(_ClientBookingPayRequest) _then;

/// Create a copy of ClientBookingPayRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentMode = null,Object? pointsToSpend = freezed,}) {
  return _then(_ClientBookingPayRequest(
paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,pointsToSpend: freezed == pointsToSpend ? _self.pointsToSpend : pointsToSpend // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
