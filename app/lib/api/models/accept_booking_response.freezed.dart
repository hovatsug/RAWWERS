// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accept_booking_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AcceptBookingResponse {

/// bookingRequest
@JsonKey(name: AcceptBookingResponse.bookingRequestKey_) BookingRequestView get bookingRequest;/// gigId
@JsonKey(name: AcceptBookingResponse.gigIdKey_) String get gigId;/// paymentIntentId
@JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_) String get paymentIntentId;/// paymentIntentClientSecret
@JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_) String get paymentIntentClientSecret;
/// Create a copy of AcceptBookingResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptBookingResponseCopyWith<AcceptBookingResponse> get copyWith => _$AcceptBookingResponseCopyWithImpl<AcceptBookingResponse>(this as AcceptBookingResponse, _$identity);

  /// Serializes this AcceptBookingResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptBookingResponse&&(identical(other.bookingRequest, bookingRequest) || other.bookingRequest == bookingRequest)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequest,gigId,paymentIntentId,paymentIntentClientSecret);

@override
String toString() {
  return 'AcceptBookingResponse(bookingRequest: $bookingRequest, gigId: $gigId, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret)';
}


}

/// @nodoc
abstract mixin class $AcceptBookingResponseCopyWith<$Res>  {
  factory $AcceptBookingResponseCopyWith(AcceptBookingResponse value, $Res Function(AcceptBookingResponse) _then) = _$AcceptBookingResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AcceptBookingResponse.bookingRequestKey_) BookingRequestView bookingRequest,@JsonKey(name: AcceptBookingResponse.gigIdKey_) String gigId,@JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret
});


$BookingRequestViewCopyWith<$Res> get bookingRequest;

}
/// @nodoc
class _$AcceptBookingResponseCopyWithImpl<$Res>
    implements $AcceptBookingResponseCopyWith<$Res> {
  _$AcceptBookingResponseCopyWithImpl(this._self, this._then);

  final AcceptBookingResponse _self;
  final $Res Function(AcceptBookingResponse) _then;

/// Create a copy of AcceptBookingResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingRequest = null,Object? gigId = null,Object? paymentIntentId = null,Object? paymentIntentClientSecret = null,}) {
  return _then(_self.copyWith(
bookingRequest: null == bookingRequest ? _self.bookingRequest : bookingRequest // ignore: cast_nullable_to_non_nullable
as BookingRequestView,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AcceptBookingResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingRequestViewCopyWith<$Res> get bookingRequest {
  
  return $BookingRequestViewCopyWith<$Res>(_self.bookingRequest, (value) {
    return _then(_self.copyWith(bookingRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [AcceptBookingResponse].
extension AcceptBookingResponsePatterns on AcceptBookingResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptBookingResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptBookingResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptBookingResponse value)  $default,){
final _that = this;
switch (_that) {
case _AcceptBookingResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptBookingResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptBookingResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AcceptBookingResponse.bookingRequestKey_)  BookingRequestView bookingRequest, @JsonKey(name: AcceptBookingResponse.gigIdKey_)  String gigId, @JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptBookingResponse() when $default != null:
return $default(_that.bookingRequest,_that.gigId,_that.paymentIntentId,_that.paymentIntentClientSecret);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AcceptBookingResponse.bookingRequestKey_)  BookingRequestView bookingRequest, @JsonKey(name: AcceptBookingResponse.gigIdKey_)  String gigId, @JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret)  $default,) {final _that = this;
switch (_that) {
case _AcceptBookingResponse():
return $default(_that.bookingRequest,_that.gigId,_that.paymentIntentId,_that.paymentIntentClientSecret);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AcceptBookingResponse.bookingRequestKey_)  BookingRequestView bookingRequest, @JsonKey(name: AcceptBookingResponse.gigIdKey_)  String gigId, @JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret)?  $default,) {final _that = this;
switch (_that) {
case _AcceptBookingResponse() when $default != null:
return $default(_that.bookingRequest,_that.gigId,_that.paymentIntentId,_that.paymentIntentClientSecret);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AcceptBookingResponse extends AcceptBookingResponse {
  const _AcceptBookingResponse({@JsonKey(name: AcceptBookingResponse.bookingRequestKey_) required this.bookingRequest, @JsonKey(name: AcceptBookingResponse.gigIdKey_) required this.gigId, @JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_) required this.paymentIntentId, @JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_) required this.paymentIntentClientSecret}): super._();
  factory _AcceptBookingResponse.fromJson(Map<String, dynamic> json) => _$AcceptBookingResponseFromJson(json);

/// bookingRequest
@override@JsonKey(name: AcceptBookingResponse.bookingRequestKey_) final  BookingRequestView bookingRequest;
/// gigId
@override@JsonKey(name: AcceptBookingResponse.gigIdKey_) final  String gigId;
/// paymentIntentId
@override@JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_) final  String paymentIntentId;
/// paymentIntentClientSecret
@override@JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_) final  String paymentIntentClientSecret;

/// Create a copy of AcceptBookingResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptBookingResponseCopyWith<_AcceptBookingResponse> get copyWith => __$AcceptBookingResponseCopyWithImpl<_AcceptBookingResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcceptBookingResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptBookingResponse&&(identical(other.bookingRequest, bookingRequest) || other.bookingRequest == bookingRequest)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequest,gigId,paymentIntentId,paymentIntentClientSecret);

@override
String toString() {
  return 'AcceptBookingResponse(bookingRequest: $bookingRequest, gigId: $gigId, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret)';
}


}

/// @nodoc
abstract mixin class _$AcceptBookingResponseCopyWith<$Res> implements $AcceptBookingResponseCopyWith<$Res> {
  factory _$AcceptBookingResponseCopyWith(_AcceptBookingResponse value, $Res Function(_AcceptBookingResponse) _then) = __$AcceptBookingResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AcceptBookingResponse.bookingRequestKey_) BookingRequestView bookingRequest,@JsonKey(name: AcceptBookingResponse.gigIdKey_) String gigId,@JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret
});


@override $BookingRequestViewCopyWith<$Res> get bookingRequest;

}
/// @nodoc
class __$AcceptBookingResponseCopyWithImpl<$Res>
    implements _$AcceptBookingResponseCopyWith<$Res> {
  __$AcceptBookingResponseCopyWithImpl(this._self, this._then);

  final _AcceptBookingResponse _self;
  final $Res Function(_AcceptBookingResponse) _then;

/// Create a copy of AcceptBookingResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingRequest = null,Object? gigId = null,Object? paymentIntentId = null,Object? paymentIntentClientSecret = null,}) {
  return _then(_AcceptBookingResponse(
bookingRequest: null == bookingRequest ? _self.bookingRequest : bookingRequest // ignore: cast_nullable_to_non_nullable
as BookingRequestView,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AcceptBookingResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingRequestViewCopyWith<$Res> get bookingRequest {
  
  return $BookingRequestViewCopyWith<$Res>(_self.bookingRequest, (value) {
    return _then(_self.copyWith(bookingRequest: value));
  });
}
}

// dart format on
