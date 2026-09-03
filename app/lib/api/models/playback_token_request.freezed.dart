// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_token_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackTokenRequest {

/// playbackId
@JsonKey(name: PlaybackTokenRequest.playbackIdKey_) String? get playbackId;
/// Create a copy of PlaybackTokenRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackTokenRequestCopyWith<PlaybackTokenRequest> get copyWith => _$PlaybackTokenRequestCopyWithImpl<PlaybackTokenRequest>(this as PlaybackTokenRequest, _$identity);

  /// Serializes this PlaybackTokenRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackTokenRequest&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackId);

@override
String toString() {
  return 'PlaybackTokenRequest(playbackId: $playbackId)';
}


}

/// @nodoc
abstract mixin class $PlaybackTokenRequestCopyWith<$Res>  {
  factory $PlaybackTokenRequestCopyWith(PlaybackTokenRequest value, $Res Function(PlaybackTokenRequest) _then) = _$PlaybackTokenRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PlaybackTokenRequest.playbackIdKey_) String? playbackId
});




}
/// @nodoc
class _$PlaybackTokenRequestCopyWithImpl<$Res>
    implements $PlaybackTokenRequestCopyWith<$Res> {
  _$PlaybackTokenRequestCopyWithImpl(this._self, this._then);

  final PlaybackTokenRequest _self;
  final $Res Function(PlaybackTokenRequest) _then;

/// Create a copy of PlaybackTokenRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playbackId = freezed,}) {
  return _then(_self.copyWith(
playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackTokenRequest].
extension PlaybackTokenRequestPatterns on PlaybackTokenRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackTokenRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackTokenRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackTokenRequest value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackTokenRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackTokenRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackTokenRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PlaybackTokenRequest.playbackIdKey_)  String? playbackId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackTokenRequest() when $default != null:
return $default(_that.playbackId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PlaybackTokenRequest.playbackIdKey_)  String? playbackId)  $default,) {final _that = this;
switch (_that) {
case _PlaybackTokenRequest():
return $default(_that.playbackId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PlaybackTokenRequest.playbackIdKey_)  String? playbackId)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackTokenRequest() when $default != null:
return $default(_that.playbackId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PlaybackTokenRequest extends PlaybackTokenRequest {
  const _PlaybackTokenRequest({@JsonKey(name: PlaybackTokenRequest.playbackIdKey_) this.playbackId}): super._();
  factory _PlaybackTokenRequest.fromJson(Map<String, dynamic> json) => _$PlaybackTokenRequestFromJson(json);

/// playbackId
@override@JsonKey(name: PlaybackTokenRequest.playbackIdKey_) final  String? playbackId;

/// Create a copy of PlaybackTokenRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackTokenRequestCopyWith<_PlaybackTokenRequest> get copyWith => __$PlaybackTokenRequestCopyWithImpl<_PlaybackTokenRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackTokenRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackTokenRequest&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackId);

@override
String toString() {
  return 'PlaybackTokenRequest(playbackId: $playbackId)';
}


}

/// @nodoc
abstract mixin class _$PlaybackTokenRequestCopyWith<$Res> implements $PlaybackTokenRequestCopyWith<$Res> {
  factory _$PlaybackTokenRequestCopyWith(_PlaybackTokenRequest value, $Res Function(_PlaybackTokenRequest) _then) = __$PlaybackTokenRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PlaybackTokenRequest.playbackIdKey_) String? playbackId
});




}
/// @nodoc
class __$PlaybackTokenRequestCopyWithImpl<$Res>
    implements _$PlaybackTokenRequestCopyWith<$Res> {
  __$PlaybackTokenRequestCopyWithImpl(this._self, this._then);

  final _PlaybackTokenRequest _self;
  final $Res Function(_PlaybackTokenRequest) _then;

/// Create a copy of PlaybackTokenRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playbackId = freezed,}) {
  return _then(_PlaybackTokenRequest(
playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
