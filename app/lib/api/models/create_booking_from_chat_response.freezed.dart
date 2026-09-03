// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_booking_from_chat_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateBookingFromChatResponse {

/// bookingRequest
@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_) BookingRequestView get bookingRequest;
/// Create a copy of CreateBookingFromChatResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateBookingFromChatResponseCopyWith<CreateBookingFromChatResponse> get copyWith => _$CreateBookingFromChatResponseCopyWithImpl<CreateBookingFromChatResponse>(this as CreateBookingFromChatResponse, _$identity);

  /// Serializes this CreateBookingFromChatResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateBookingFromChatResponse&&(identical(other.bookingRequest, bookingRequest) || other.bookingRequest == bookingRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequest);

@override
String toString() {
  return 'CreateBookingFromChatResponse(bookingRequest: $bookingRequest)';
}


}

/// @nodoc
abstract mixin class $CreateBookingFromChatResponseCopyWith<$Res>  {
  factory $CreateBookingFromChatResponseCopyWith(CreateBookingFromChatResponse value, $Res Function(CreateBookingFromChatResponse) _then) = _$CreateBookingFromChatResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_) BookingRequestView bookingRequest
});


$BookingRequestViewCopyWith<$Res> get bookingRequest;

}
/// @nodoc
class _$CreateBookingFromChatResponseCopyWithImpl<$Res>
    implements $CreateBookingFromChatResponseCopyWith<$Res> {
  _$CreateBookingFromChatResponseCopyWithImpl(this._self, this._then);

  final CreateBookingFromChatResponse _self;
  final $Res Function(CreateBookingFromChatResponse) _then;

/// Create a copy of CreateBookingFromChatResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingRequest = null,}) {
  return _then(_self.copyWith(
bookingRequest: null == bookingRequest ? _self.bookingRequest : bookingRequest // ignore: cast_nullable_to_non_nullable
as BookingRequestView,
  ));
}
/// Create a copy of CreateBookingFromChatResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingRequestViewCopyWith<$Res> get bookingRequest {
  
  return $BookingRequestViewCopyWith<$Res>(_self.bookingRequest, (value) {
    return _then(_self.copyWith(bookingRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateBookingFromChatResponse].
extension CreateBookingFromChatResponsePatterns on CreateBookingFromChatResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateBookingFromChatResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateBookingFromChatResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateBookingFromChatResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreateBookingFromChatResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateBookingFromChatResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreateBookingFromChatResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_)  BookingRequestView bookingRequest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateBookingFromChatResponse() when $default != null:
return $default(_that.bookingRequest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_)  BookingRequestView bookingRequest)  $default,) {final _that = this;
switch (_that) {
case _CreateBookingFromChatResponse():
return $default(_that.bookingRequest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_)  BookingRequestView bookingRequest)?  $default,) {final _that = this;
switch (_that) {
case _CreateBookingFromChatResponse() when $default != null:
return $default(_that.bookingRequest);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateBookingFromChatResponse extends CreateBookingFromChatResponse {
  const _CreateBookingFromChatResponse({@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_) required this.bookingRequest}): super._();
  factory _CreateBookingFromChatResponse.fromJson(Map<String, dynamic> json) => _$CreateBookingFromChatResponseFromJson(json);

/// bookingRequest
@override@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_) final  BookingRequestView bookingRequest;

/// Create a copy of CreateBookingFromChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateBookingFromChatResponseCopyWith<_CreateBookingFromChatResponse> get copyWith => __$CreateBookingFromChatResponseCopyWithImpl<_CreateBookingFromChatResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateBookingFromChatResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateBookingFromChatResponse&&(identical(other.bookingRequest, bookingRequest) || other.bookingRequest == bookingRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequest);

@override
String toString() {
  return 'CreateBookingFromChatResponse(bookingRequest: $bookingRequest)';
}


}

/// @nodoc
abstract mixin class _$CreateBookingFromChatResponseCopyWith<$Res> implements $CreateBookingFromChatResponseCopyWith<$Res> {
  factory _$CreateBookingFromChatResponseCopyWith(_CreateBookingFromChatResponse value, $Res Function(_CreateBookingFromChatResponse) _then) = __$CreateBookingFromChatResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_) BookingRequestView bookingRequest
});


@override $BookingRequestViewCopyWith<$Res> get bookingRequest;

}
/// @nodoc
class __$CreateBookingFromChatResponseCopyWithImpl<$Res>
    implements _$CreateBookingFromChatResponseCopyWith<$Res> {
  __$CreateBookingFromChatResponseCopyWithImpl(this._self, this._then);

  final _CreateBookingFromChatResponse _self;
  final $Res Function(_CreateBookingFromChatResponse) _then;

/// Create a copy of CreateBookingFromChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingRequest = null,}) {
  return _then(_CreateBookingFromChatResponse(
bookingRequest: null == bookingRequest ? _self.bookingRequest : bookingRequest // ignore: cast_nullable_to_non_nullable
as BookingRequestView,
  ));
}

/// Create a copy of CreateBookingFromChatResponse
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
