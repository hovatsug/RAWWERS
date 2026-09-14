// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accept_booking_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AcceptBookingRequest {

/// clientCreditPercent
@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_) int? get clientCreditPercent;
/// Create a copy of AcceptBookingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptBookingRequestCopyWith<AcceptBookingRequest> get copyWith => _$AcceptBookingRequestCopyWithImpl<AcceptBookingRequest>(this as AcceptBookingRequest, _$identity);

  /// Serializes this AcceptBookingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptBookingRequest&&(identical(other.clientCreditPercent, clientCreditPercent) || other.clientCreditPercent == clientCreditPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientCreditPercent);

@override
String toString() {
  return 'AcceptBookingRequest(clientCreditPercent: $clientCreditPercent)';
}


}

/// @nodoc
abstract mixin class $AcceptBookingRequestCopyWith<$Res>  {
  factory $AcceptBookingRequestCopyWith(AcceptBookingRequest value, $Res Function(AcceptBookingRequest) _then) = _$AcceptBookingRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_) int? clientCreditPercent
});




}
/// @nodoc
class _$AcceptBookingRequestCopyWithImpl<$Res>
    implements $AcceptBookingRequestCopyWith<$Res> {
  _$AcceptBookingRequestCopyWithImpl(this._self, this._then);

  final AcceptBookingRequest _self;
  final $Res Function(AcceptBookingRequest) _then;

/// Create a copy of AcceptBookingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientCreditPercent = freezed,}) {
  return _then(_self.copyWith(
clientCreditPercent: freezed == clientCreditPercent ? _self.clientCreditPercent : clientCreditPercent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AcceptBookingRequest].
extension AcceptBookingRequestPatterns on AcceptBookingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptBookingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptBookingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptBookingRequest value)  $default,){
final _that = this;
switch (_that) {
case _AcceptBookingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptBookingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptBookingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_)  int? clientCreditPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptBookingRequest() when $default != null:
return $default(_that.clientCreditPercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_)  int? clientCreditPercent)  $default,) {final _that = this;
switch (_that) {
case _AcceptBookingRequest():
return $default(_that.clientCreditPercent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_)  int? clientCreditPercent)?  $default,) {final _that = this;
switch (_that) {
case _AcceptBookingRequest() when $default != null:
return $default(_that.clientCreditPercent);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AcceptBookingRequest extends AcceptBookingRequest {
  const _AcceptBookingRequest({@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_) this.clientCreditPercent}): super._();
  factory _AcceptBookingRequest.fromJson(Map<String, dynamic> json) => _$AcceptBookingRequestFromJson(json);

/// clientCreditPercent
@override@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_) final  int? clientCreditPercent;

/// Create a copy of AcceptBookingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptBookingRequestCopyWith<_AcceptBookingRequest> get copyWith => __$AcceptBookingRequestCopyWithImpl<_AcceptBookingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcceptBookingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptBookingRequest&&(identical(other.clientCreditPercent, clientCreditPercent) || other.clientCreditPercent == clientCreditPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientCreditPercent);

@override
String toString() {
  return 'AcceptBookingRequest(clientCreditPercent: $clientCreditPercent)';
}


}

/// @nodoc
abstract mixin class _$AcceptBookingRequestCopyWith<$Res> implements $AcceptBookingRequestCopyWith<$Res> {
  factory _$AcceptBookingRequestCopyWith(_AcceptBookingRequest value, $Res Function(_AcceptBookingRequest) _then) = __$AcceptBookingRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_) int? clientCreditPercent
});




}
/// @nodoc
class __$AcceptBookingRequestCopyWithImpl<$Res>
    implements _$AcceptBookingRequestCopyWith<$Res> {
  __$AcceptBookingRequestCopyWithImpl(this._self, this._then);

  final _AcceptBookingRequest _self;
  final $Res Function(_AcceptBookingRequest) _then;

/// Create a copy of AcceptBookingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientCreditPercent = freezed,}) {
  return _then(_AcceptBookingRequest(
clientCreditPercent: freezed == clientCreditPercent ? _self.clientCreditPercent : clientCreditPercent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
