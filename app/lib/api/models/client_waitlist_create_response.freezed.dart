// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_waitlist_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientWaitlistCreateResponse {

/// accepted
@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_) bool get accepted;
/// Create a copy of ClientWaitlistCreateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientWaitlistCreateResponseCopyWith<ClientWaitlistCreateResponse> get copyWith => _$ClientWaitlistCreateResponseCopyWithImpl<ClientWaitlistCreateResponse>(this as ClientWaitlistCreateResponse, _$identity);

  /// Serializes this ClientWaitlistCreateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientWaitlistCreateResponse&&(identical(other.accepted, accepted) || other.accepted == accepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accepted);

@override
String toString() {
  return 'ClientWaitlistCreateResponse(accepted: $accepted)';
}


}

/// @nodoc
abstract mixin class $ClientWaitlistCreateResponseCopyWith<$Res>  {
  factory $ClientWaitlistCreateResponseCopyWith(ClientWaitlistCreateResponse value, $Res Function(ClientWaitlistCreateResponse) _then) = _$ClientWaitlistCreateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_) bool accepted
});




}
/// @nodoc
class _$ClientWaitlistCreateResponseCopyWithImpl<$Res>
    implements $ClientWaitlistCreateResponseCopyWith<$Res> {
  _$ClientWaitlistCreateResponseCopyWithImpl(this._self, this._then);

  final ClientWaitlistCreateResponse _self;
  final $Res Function(ClientWaitlistCreateResponse) _then;

/// Create a copy of ClientWaitlistCreateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accepted = null,}) {
  return _then(_self.copyWith(
accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientWaitlistCreateResponse].
extension ClientWaitlistCreateResponsePatterns on ClientWaitlistCreateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientWaitlistCreateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientWaitlistCreateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientWaitlistCreateResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientWaitlistCreateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientWaitlistCreateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientWaitlistCreateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_)  bool accepted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientWaitlistCreateResponse() when $default != null:
return $default(_that.accepted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_)  bool accepted)  $default,) {final _that = this;
switch (_that) {
case _ClientWaitlistCreateResponse():
return $default(_that.accepted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_)  bool accepted)?  $default,) {final _that = this;
switch (_that) {
case _ClientWaitlistCreateResponse() when $default != null:
return $default(_that.accepted);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientWaitlistCreateResponse extends ClientWaitlistCreateResponse {
  const _ClientWaitlistCreateResponse({@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_) this.accepted = true}): super._();
  factory _ClientWaitlistCreateResponse.fromJson(Map<String, dynamic> json) => _$ClientWaitlistCreateResponseFromJson(json);

/// accepted
@override@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_) final  bool accepted;

/// Create a copy of ClientWaitlistCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientWaitlistCreateResponseCopyWith<_ClientWaitlistCreateResponse> get copyWith => __$ClientWaitlistCreateResponseCopyWithImpl<_ClientWaitlistCreateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientWaitlistCreateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientWaitlistCreateResponse&&(identical(other.accepted, accepted) || other.accepted == accepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accepted);

@override
String toString() {
  return 'ClientWaitlistCreateResponse(accepted: $accepted)';
}


}

/// @nodoc
abstract mixin class _$ClientWaitlistCreateResponseCopyWith<$Res> implements $ClientWaitlistCreateResponseCopyWith<$Res> {
  factory _$ClientWaitlistCreateResponseCopyWith(_ClientWaitlistCreateResponse value, $Res Function(_ClientWaitlistCreateResponse) _then) = __$ClientWaitlistCreateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_) bool accepted
});




}
/// @nodoc
class __$ClientWaitlistCreateResponseCopyWithImpl<$Res>
    implements _$ClientWaitlistCreateResponseCopyWith<$Res> {
  __$ClientWaitlistCreateResponseCopyWithImpl(this._self, this._then);

  final _ClientWaitlistCreateResponse _self;
  final $Res Function(_ClientWaitlistCreateResponse) _then;

/// Create a copy of ClientWaitlistCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accepted = null,}) {
  return _then(_ClientWaitlistCreateResponse(
accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
