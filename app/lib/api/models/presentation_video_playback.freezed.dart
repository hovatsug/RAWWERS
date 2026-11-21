// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentation_video_playback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresentationVideoPlayback {

/// playbackUrl
@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_) String get playbackUrl;/// expiresIn
@JsonKey(name: PresentationVideoPlayback.expiresInKey_) int get expiresIn;
/// Create a copy of PresentationVideoPlayback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresentationVideoPlaybackCopyWith<PresentationVideoPlayback> get copyWith => _$PresentationVideoPlaybackCopyWithImpl<PresentationVideoPlayback>(this as PresentationVideoPlayback, _$identity);

  /// Serializes this PresentationVideoPlayback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationVideoPlayback&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackUrl,expiresIn);

@override
String toString() {
  return 'PresentationVideoPlayback(playbackUrl: $playbackUrl, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $PresentationVideoPlaybackCopyWith<$Res>  {
  factory $PresentationVideoPlaybackCopyWith(PresentationVideoPlayback value, $Res Function(PresentationVideoPlayback) _then) = _$PresentationVideoPlaybackCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_) String playbackUrl,@JsonKey(name: PresentationVideoPlayback.expiresInKey_) int expiresIn
});




}
/// @nodoc
class _$PresentationVideoPlaybackCopyWithImpl<$Res>
    implements $PresentationVideoPlaybackCopyWith<$Res> {
  _$PresentationVideoPlaybackCopyWithImpl(this._self, this._then);

  final PresentationVideoPlayback _self;
  final $Res Function(PresentationVideoPlayback) _then;

/// Create a copy of PresentationVideoPlayback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playbackUrl = null,Object? expiresIn = null,}) {
  return _then(_self.copyWith(
playbackUrl: null == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PresentationVideoPlayback].
extension PresentationVideoPlaybackPatterns on PresentationVideoPlayback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresentationVideoPlayback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresentationVideoPlayback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresentationVideoPlayback value)  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoPlayback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresentationVideoPlayback value)?  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoPlayback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_)  String playbackUrl, @JsonKey(name: PresentationVideoPlayback.expiresInKey_)  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresentationVideoPlayback() when $default != null:
return $default(_that.playbackUrl,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_)  String playbackUrl, @JsonKey(name: PresentationVideoPlayback.expiresInKey_)  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoPlayback():
return $default(_that.playbackUrl,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_)  String playbackUrl, @JsonKey(name: PresentationVideoPlayback.expiresInKey_)  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoPlayback() when $default != null:
return $default(_that.playbackUrl,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PresentationVideoPlayback extends PresentationVideoPlayback {
  const _PresentationVideoPlayback({@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_) required this.playbackUrl, @JsonKey(name: PresentationVideoPlayback.expiresInKey_) required this.expiresIn}): super._();
  factory _PresentationVideoPlayback.fromJson(Map<String, dynamic> json) => _$PresentationVideoPlaybackFromJson(json);

/// playbackUrl
@override@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_) final  String playbackUrl;
/// expiresIn
@override@JsonKey(name: PresentationVideoPlayback.expiresInKey_) final  int expiresIn;

/// Create a copy of PresentationVideoPlayback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresentationVideoPlaybackCopyWith<_PresentationVideoPlayback> get copyWith => __$PresentationVideoPlaybackCopyWithImpl<_PresentationVideoPlayback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresentationVideoPlaybackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresentationVideoPlayback&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackUrl,expiresIn);

@override
String toString() {
  return 'PresentationVideoPlayback(playbackUrl: $playbackUrl, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$PresentationVideoPlaybackCopyWith<$Res> implements $PresentationVideoPlaybackCopyWith<$Res> {
  factory _$PresentationVideoPlaybackCopyWith(_PresentationVideoPlayback value, $Res Function(_PresentationVideoPlayback) _then) = __$PresentationVideoPlaybackCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PresentationVideoPlayback.playbackUrlKey_) String playbackUrl,@JsonKey(name: PresentationVideoPlayback.expiresInKey_) int expiresIn
});




}
/// @nodoc
class __$PresentationVideoPlaybackCopyWithImpl<$Res>
    implements _$PresentationVideoPlaybackCopyWith<$Res> {
  __$PresentationVideoPlaybackCopyWithImpl(this._self, this._then);

  final _PresentationVideoPlayback _self;
  final $Res Function(_PresentationVideoPlayback) _then;

/// Create a copy of PresentationVideoPlayback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playbackUrl = null,Object? expiresIn = null,}) {
  return _then(_PresentationVideoPlayback(
playbackUrl: null == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
