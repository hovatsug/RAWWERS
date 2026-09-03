// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_request_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingRequestCreateResponse {

/// bookingId
@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_) String get bookingId;/// status
@JsonKey(name: ClientBookingRequestCreateResponse.statusKey_) String get status;
/// Create a copy of ClientBookingRequestCreateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingRequestCreateResponseCopyWith<ClientBookingRequestCreateResponse> get copyWith => _$ClientBookingRequestCreateResponseCopyWithImpl<ClientBookingRequestCreateResponse>(this as ClientBookingRequestCreateResponse, _$identity);

  /// Serializes this ClientBookingRequestCreateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingRequestCreateResponse&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,status);

@override
String toString() {
  return 'ClientBookingRequestCreateResponse(bookingId: $bookingId, status: $status)';
}


}

/// @nodoc
abstract mixin class $ClientBookingRequestCreateResponseCopyWith<$Res>  {
  factory $ClientBookingRequestCreateResponseCopyWith(ClientBookingRequestCreateResponse value, $Res Function(ClientBookingRequestCreateResponse) _then) = _$ClientBookingRequestCreateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingRequestCreateResponse.statusKey_) String status
});




}
/// @nodoc
class _$ClientBookingRequestCreateResponseCopyWithImpl<$Res>
    implements $ClientBookingRequestCreateResponseCopyWith<$Res> {
  _$ClientBookingRequestCreateResponseCopyWithImpl(this._self, this._then);

  final ClientBookingRequestCreateResponse _self;
  final $Res Function(ClientBookingRequestCreateResponse) _then;

/// Create a copy of ClientBookingRequestCreateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? status = null,}) {
  return _then(_self.copyWith(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientBookingRequestCreateResponse].
extension ClientBookingRequestCreateResponsePatterns on ClientBookingRequestCreateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingRequestCreateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingRequestCreateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingRequestCreateResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingRequestCreateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingRequestCreateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingRequestCreateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingRequestCreateResponse.statusKey_)  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingRequestCreateResponse() when $default != null:
return $default(_that.bookingId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingRequestCreateResponse.statusKey_)  String status)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingRequestCreateResponse():
return $default(_that.bookingId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingRequestCreateResponse.statusKey_)  String status)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingRequestCreateResponse() when $default != null:
return $default(_that.bookingId,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingRequestCreateResponse extends ClientBookingRequestCreateResponse {
  const _ClientBookingRequestCreateResponse({@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_) required this.bookingId, @JsonKey(name: ClientBookingRequestCreateResponse.statusKey_) required this.status}): super._();
  factory _ClientBookingRequestCreateResponse.fromJson(Map<String, dynamic> json) => _$ClientBookingRequestCreateResponseFromJson(json);

/// bookingId
@override@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_) final  String bookingId;
/// status
@override@JsonKey(name: ClientBookingRequestCreateResponse.statusKey_) final  String status;

/// Create a copy of ClientBookingRequestCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingRequestCreateResponseCopyWith<_ClientBookingRequestCreateResponse> get copyWith => __$ClientBookingRequestCreateResponseCopyWithImpl<_ClientBookingRequestCreateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingRequestCreateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingRequestCreateResponse&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,status);

@override
String toString() {
  return 'ClientBookingRequestCreateResponse(bookingId: $bookingId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingRequestCreateResponseCopyWith<$Res> implements $ClientBookingRequestCreateResponseCopyWith<$Res> {
  factory _$ClientBookingRequestCreateResponseCopyWith(_ClientBookingRequestCreateResponse value, $Res Function(_ClientBookingRequestCreateResponse) _then) = __$ClientBookingRequestCreateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingRequestCreateResponse.statusKey_) String status
});




}
/// @nodoc
class __$ClientBookingRequestCreateResponseCopyWithImpl<$Res>
    implements _$ClientBookingRequestCreateResponseCopyWith<$Res> {
  __$ClientBookingRequestCreateResponseCopyWithImpl(this._self, this._then);

  final _ClientBookingRequestCreateResponse _self;
  final $Res Function(_ClientBookingRequestCreateResponse) _then;

/// Create a copy of ClientBookingRequestCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? status = null,}) {
  return _then(_ClientBookingRequestCreateResponse(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
