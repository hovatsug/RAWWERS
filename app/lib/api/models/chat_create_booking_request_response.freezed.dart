// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_create_booking_request_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatCreateBookingRequestResponse {

/// bookingRequest
@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_) BookingRequestView get bookingRequest;
/// Create a copy of ChatCreateBookingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatCreateBookingRequestResponseCopyWith<ChatCreateBookingRequestResponse> get copyWith => _$ChatCreateBookingRequestResponseCopyWithImpl<ChatCreateBookingRequestResponse>(this as ChatCreateBookingRequestResponse, _$identity);

  /// Serializes this ChatCreateBookingRequestResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatCreateBookingRequestResponse&&(identical(other.bookingRequest, bookingRequest) || other.bookingRequest == bookingRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequest);

@override
String toString() {
  return 'ChatCreateBookingRequestResponse(bookingRequest: $bookingRequest)';
}


}

/// @nodoc
abstract mixin class $ChatCreateBookingRequestResponseCopyWith<$Res>  {
  factory $ChatCreateBookingRequestResponseCopyWith(ChatCreateBookingRequestResponse value, $Res Function(ChatCreateBookingRequestResponse) _then) = _$ChatCreateBookingRequestResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_) BookingRequestView bookingRequest
});


$BookingRequestViewCopyWith<$Res> get bookingRequest;

}
/// @nodoc
class _$ChatCreateBookingRequestResponseCopyWithImpl<$Res>
    implements $ChatCreateBookingRequestResponseCopyWith<$Res> {
  _$ChatCreateBookingRequestResponseCopyWithImpl(this._self, this._then);

  final ChatCreateBookingRequestResponse _self;
  final $Res Function(ChatCreateBookingRequestResponse) _then;

/// Create a copy of ChatCreateBookingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingRequest = null,}) {
  return _then(_self.copyWith(
bookingRequest: null == bookingRequest ? _self.bookingRequest : bookingRequest // ignore: cast_nullable_to_non_nullable
as BookingRequestView,
  ));
}
/// Create a copy of ChatCreateBookingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingRequestViewCopyWith<$Res> get bookingRequest {
  
  return $BookingRequestViewCopyWith<$Res>(_self.bookingRequest, (value) {
    return _then(_self.copyWith(bookingRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatCreateBookingRequestResponse].
extension ChatCreateBookingRequestResponsePatterns on ChatCreateBookingRequestResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatCreateBookingRequestResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatCreateBookingRequestResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatCreateBookingRequestResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChatCreateBookingRequestResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatCreateBookingRequestResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChatCreateBookingRequestResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_)  BookingRequestView bookingRequest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatCreateBookingRequestResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_)  BookingRequestView bookingRequest)  $default,) {final _that = this;
switch (_that) {
case _ChatCreateBookingRequestResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_)  BookingRequestView bookingRequest)?  $default,) {final _that = this;
switch (_that) {
case _ChatCreateBookingRequestResponse() when $default != null:
return $default(_that.bookingRequest);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatCreateBookingRequestResponse extends ChatCreateBookingRequestResponse {
  const _ChatCreateBookingRequestResponse({@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_) required this.bookingRequest}): super._();
  factory _ChatCreateBookingRequestResponse.fromJson(Map<String, dynamic> json) => _$ChatCreateBookingRequestResponseFromJson(json);

/// bookingRequest
@override@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_) final  BookingRequestView bookingRequest;

/// Create a copy of ChatCreateBookingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatCreateBookingRequestResponseCopyWith<_ChatCreateBookingRequestResponse> get copyWith => __$ChatCreateBookingRequestResponseCopyWithImpl<_ChatCreateBookingRequestResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatCreateBookingRequestResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatCreateBookingRequestResponse&&(identical(other.bookingRequest, bookingRequest) || other.bookingRequest == bookingRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequest);

@override
String toString() {
  return 'ChatCreateBookingRequestResponse(bookingRequest: $bookingRequest)';
}


}

/// @nodoc
abstract mixin class _$ChatCreateBookingRequestResponseCopyWith<$Res> implements $ChatCreateBookingRequestResponseCopyWith<$Res> {
  factory _$ChatCreateBookingRequestResponseCopyWith(_ChatCreateBookingRequestResponse value, $Res Function(_ChatCreateBookingRequestResponse) _then) = __$ChatCreateBookingRequestResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_) BookingRequestView bookingRequest
});


@override $BookingRequestViewCopyWith<$Res> get bookingRequest;

}
/// @nodoc
class __$ChatCreateBookingRequestResponseCopyWithImpl<$Res>
    implements _$ChatCreateBookingRequestResponseCopyWith<$Res> {
  __$ChatCreateBookingRequestResponseCopyWithImpl(this._self, this._then);

  final _ChatCreateBookingRequestResponse _self;
  final $Res Function(_ChatCreateBookingRequestResponse) _then;

/// Create a copy of ChatCreateBookingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingRequest = null,}) {
  return _then(_ChatCreateBookingRequestResponse(
bookingRequest: null == bookingRequest ? _self.bookingRequest : bookingRequest // ignore: cast_nullable_to_non_nullable
as BookingRequestView,
  ));
}

/// Create a copy of ChatCreateBookingRequestResponse
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
