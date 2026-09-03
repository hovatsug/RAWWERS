// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_token_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackTokenResponse {

/// token
@JsonKey(name: PlaybackTokenResponse.tokenKey_) String get token;/// playbackId
@JsonKey(name: PlaybackTokenResponse.playbackIdKey_) String get playbackId;/// expiresIn
@JsonKey(name: PlaybackTokenResponse.expiresInKey_) int get expiresIn;
/// Create a copy of PlaybackTokenResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackTokenResponseCopyWith<PlaybackTokenResponse> get copyWith => _$PlaybackTokenResponseCopyWithImpl<PlaybackTokenResponse>(this as PlaybackTokenResponse, _$identity);

  /// Serializes this PlaybackTokenResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackTokenResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,playbackId,expiresIn);

@override
String toString() {
  return 'PlaybackTokenResponse(token: $token, playbackId: $playbackId, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $PlaybackTokenResponseCopyWith<$Res>  {
  factory $PlaybackTokenResponseCopyWith(PlaybackTokenResponse value, $Res Function(PlaybackTokenResponse) _then) = _$PlaybackTokenResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PlaybackTokenResponse.tokenKey_) String token,@JsonKey(name: PlaybackTokenResponse.playbackIdKey_) String playbackId,@JsonKey(name: PlaybackTokenResponse.expiresInKey_) int expiresIn
});




}
/// @nodoc
class _$PlaybackTokenResponseCopyWithImpl<$Res>
    implements $PlaybackTokenResponseCopyWith<$Res> {
  _$PlaybackTokenResponseCopyWithImpl(this._self, this._then);

  final PlaybackTokenResponse _self;
  final $Res Function(PlaybackTokenResponse) _then;

/// Create a copy of PlaybackTokenResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? playbackId = null,Object? expiresIn = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,playbackId: null == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackTokenResponse].
extension PlaybackTokenResponsePatterns on PlaybackTokenResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackTokenResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackTokenResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackTokenResponse value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackTokenResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackTokenResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackTokenResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PlaybackTokenResponse.tokenKey_)  String token, @JsonKey(name: PlaybackTokenResponse.playbackIdKey_)  String playbackId, @JsonKey(name: PlaybackTokenResponse.expiresInKey_)  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackTokenResponse() when $default != null:
return $default(_that.token,_that.playbackId,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PlaybackTokenResponse.tokenKey_)  String token, @JsonKey(name: PlaybackTokenResponse.playbackIdKey_)  String playbackId, @JsonKey(name: PlaybackTokenResponse.expiresInKey_)  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _PlaybackTokenResponse():
return $default(_that.token,_that.playbackId,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PlaybackTokenResponse.tokenKey_)  String token, @JsonKey(name: PlaybackTokenResponse.playbackIdKey_)  String playbackId, @JsonKey(name: PlaybackTokenResponse.expiresInKey_)  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackTokenResponse() when $default != null:
return $default(_that.token,_that.playbackId,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PlaybackTokenResponse extends PlaybackTokenResponse {
  const _PlaybackTokenResponse({@JsonKey(name: PlaybackTokenResponse.tokenKey_) required this.token, @JsonKey(name: PlaybackTokenResponse.playbackIdKey_) required this.playbackId, @JsonKey(name: PlaybackTokenResponse.expiresInKey_) required this.expiresIn}): super._();
  factory _PlaybackTokenResponse.fromJson(Map<String, dynamic> json) => _$PlaybackTokenResponseFromJson(json);

/// token
@override@JsonKey(name: PlaybackTokenResponse.tokenKey_) final  String token;
/// playbackId
@override@JsonKey(name: PlaybackTokenResponse.playbackIdKey_) final  String playbackId;
/// expiresIn
@override@JsonKey(name: PlaybackTokenResponse.expiresInKey_) final  int expiresIn;

/// Create a copy of PlaybackTokenResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackTokenResponseCopyWith<_PlaybackTokenResponse> get copyWith => __$PlaybackTokenResponseCopyWithImpl<_PlaybackTokenResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackTokenResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackTokenResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,playbackId,expiresIn);

@override
String toString() {
  return 'PlaybackTokenResponse(token: $token, playbackId: $playbackId, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$PlaybackTokenResponseCopyWith<$Res> implements $PlaybackTokenResponseCopyWith<$Res> {
  factory _$PlaybackTokenResponseCopyWith(_PlaybackTokenResponse value, $Res Function(_PlaybackTokenResponse) _then) = __$PlaybackTokenResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PlaybackTokenResponse.tokenKey_) String token,@JsonKey(name: PlaybackTokenResponse.playbackIdKey_) String playbackId,@JsonKey(name: PlaybackTokenResponse.expiresInKey_) int expiresIn
});




}
/// @nodoc
class __$PlaybackTokenResponseCopyWithImpl<$Res>
    implements _$PlaybackTokenResponseCopyWith<$Res> {
  __$PlaybackTokenResponseCopyWithImpl(this._self, this._then);

  final _PlaybackTokenResponse _self;
  final $Res Function(_PlaybackTokenResponse) _then;

/// Create a copy of PlaybackTokenResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? playbackId = null,Object? expiresIn = null,}) {
  return _then(_PlaybackTokenResponse(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,playbackId: null == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
