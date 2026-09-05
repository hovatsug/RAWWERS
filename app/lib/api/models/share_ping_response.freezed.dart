// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_ping_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SharePingResponse {

/// ok
@JsonKey(name: SharePingResponse.okKey_) bool get ok;/// accumulatedSeconds
@JsonKey(name: SharePingResponse.accumulatedSecondsKey_) int get accumulatedSeconds;
/// Create a copy of SharePingResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharePingResponseCopyWith<SharePingResponse> get copyWith => _$SharePingResponseCopyWithImpl<SharePingResponse>(this as SharePingResponse, _$identity);

  /// Serializes this SharePingResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharePingResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.accumulatedSeconds, accumulatedSeconds) || other.accumulatedSeconds == accumulatedSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,accumulatedSeconds);

@override
String toString() {
  return 'SharePingResponse(ok: $ok, accumulatedSeconds: $accumulatedSeconds)';
}


}

/// @nodoc
abstract mixin class $SharePingResponseCopyWith<$Res>  {
  factory $SharePingResponseCopyWith(SharePingResponse value, $Res Function(SharePingResponse) _then) = _$SharePingResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SharePingResponse.okKey_) bool ok,@JsonKey(name: SharePingResponse.accumulatedSecondsKey_) int accumulatedSeconds
});




}
/// @nodoc
class _$SharePingResponseCopyWithImpl<$Res>
    implements $SharePingResponseCopyWith<$Res> {
  _$SharePingResponseCopyWithImpl(this._self, this._then);

  final SharePingResponse _self;
  final $Res Function(SharePingResponse) _then;

/// Create a copy of SharePingResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? accumulatedSeconds = null,}) {
  return _then(_self.copyWith(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,accumulatedSeconds: null == accumulatedSeconds ? _self.accumulatedSeconds : accumulatedSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SharePingResponse].
extension SharePingResponsePatterns on SharePingResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharePingResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharePingResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharePingResponse value)  $default,){
final _that = this;
switch (_that) {
case _SharePingResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharePingResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SharePingResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SharePingResponse.okKey_)  bool ok, @JsonKey(name: SharePingResponse.accumulatedSecondsKey_)  int accumulatedSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharePingResponse() when $default != null:
return $default(_that.ok,_that.accumulatedSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SharePingResponse.okKey_)  bool ok, @JsonKey(name: SharePingResponse.accumulatedSecondsKey_)  int accumulatedSeconds)  $default,) {final _that = this;
switch (_that) {
case _SharePingResponse():
return $default(_that.ok,_that.accumulatedSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SharePingResponse.okKey_)  bool ok, @JsonKey(name: SharePingResponse.accumulatedSecondsKey_)  int accumulatedSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SharePingResponse() when $default != null:
return $default(_that.ok,_that.accumulatedSeconds);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SharePingResponse extends SharePingResponse {
  const _SharePingResponse({@JsonKey(name: SharePingResponse.okKey_) required this.ok, @JsonKey(name: SharePingResponse.accumulatedSecondsKey_) required this.accumulatedSeconds}): super._();
  factory _SharePingResponse.fromJson(Map<String, dynamic> json) => _$SharePingResponseFromJson(json);

/// ok
@override@JsonKey(name: SharePingResponse.okKey_) final  bool ok;
/// accumulatedSeconds
@override@JsonKey(name: SharePingResponse.accumulatedSecondsKey_) final  int accumulatedSeconds;

/// Create a copy of SharePingResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharePingResponseCopyWith<_SharePingResponse> get copyWith => __$SharePingResponseCopyWithImpl<_SharePingResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharePingResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharePingResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.accumulatedSeconds, accumulatedSeconds) || other.accumulatedSeconds == accumulatedSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,accumulatedSeconds);

@override
String toString() {
  return 'SharePingResponse(ok: $ok, accumulatedSeconds: $accumulatedSeconds)';
}


}

/// @nodoc
abstract mixin class _$SharePingResponseCopyWith<$Res> implements $SharePingResponseCopyWith<$Res> {
  factory _$SharePingResponseCopyWith(_SharePingResponse value, $Res Function(_SharePingResponse) _then) = __$SharePingResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SharePingResponse.okKey_) bool ok,@JsonKey(name: SharePingResponse.accumulatedSecondsKey_) int accumulatedSeconds
});




}
/// @nodoc
class __$SharePingResponseCopyWithImpl<$Res>
    implements _$SharePingResponseCopyWith<$Res> {
  __$SharePingResponseCopyWithImpl(this._self, this._then);

  final _SharePingResponse _self;
  final $Res Function(_SharePingResponse) _then;

/// Create a copy of SharePingResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? accumulatedSeconds = null,}) {
  return _then(_SharePingResponse(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,accumulatedSeconds: null == accumulatedSeconds ? _self.accumulatedSeconds : accumulatedSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
