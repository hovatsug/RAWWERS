// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentation_video_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresentationVideoView {

/// playbackUrl
@JsonKey(name: PresentationVideoView.playbackUrlKey_) String get playbackUrl;/// posterUrl
@JsonKey(name: PresentationVideoView.posterUrlKey_) String? get posterUrl;/// durationSeconds
@JsonKey(name: PresentationVideoView.durationSecondsKey_) int? get durationSeconds;
/// Create a copy of PresentationVideoView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresentationVideoViewCopyWith<PresentationVideoView> get copyWith => _$PresentationVideoViewCopyWithImpl<PresentationVideoView>(this as PresentationVideoView, _$identity);

  /// Serializes this PresentationVideoView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationVideoView&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackUrl,posterUrl,durationSeconds);

@override
String toString() {
  return 'PresentationVideoView(playbackUrl: $playbackUrl, posterUrl: $posterUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $PresentationVideoViewCopyWith<$Res>  {
  factory $PresentationVideoViewCopyWith(PresentationVideoView value, $Res Function(PresentationVideoView) _then) = _$PresentationVideoViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PresentationVideoView.playbackUrlKey_) String playbackUrl,@JsonKey(name: PresentationVideoView.posterUrlKey_) String? posterUrl,@JsonKey(name: PresentationVideoView.durationSecondsKey_) int? durationSeconds
});




}
/// @nodoc
class _$PresentationVideoViewCopyWithImpl<$Res>
    implements $PresentationVideoViewCopyWith<$Res> {
  _$PresentationVideoViewCopyWithImpl(this._self, this._then);

  final PresentationVideoView _self;
  final $Res Function(PresentationVideoView) _then;

/// Create a copy of PresentationVideoView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playbackUrl = null,Object? posterUrl = freezed,Object? durationSeconds = freezed,}) {
  return _then(_self.copyWith(
playbackUrl: null == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PresentationVideoView].
extension PresentationVideoViewPatterns on PresentationVideoView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresentationVideoView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresentationVideoView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresentationVideoView value)  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresentationVideoView value)?  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoView.playbackUrlKey_)  String playbackUrl, @JsonKey(name: PresentationVideoView.posterUrlKey_)  String? posterUrl, @JsonKey(name: PresentationVideoView.durationSecondsKey_)  int? durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresentationVideoView() when $default != null:
return $default(_that.playbackUrl,_that.posterUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoView.playbackUrlKey_)  String playbackUrl, @JsonKey(name: PresentationVideoView.posterUrlKey_)  String? posterUrl, @JsonKey(name: PresentationVideoView.durationSecondsKey_)  int? durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoView():
return $default(_that.playbackUrl,_that.posterUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PresentationVideoView.playbackUrlKey_)  String playbackUrl, @JsonKey(name: PresentationVideoView.posterUrlKey_)  String? posterUrl, @JsonKey(name: PresentationVideoView.durationSecondsKey_)  int? durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoView() when $default != null:
return $default(_that.playbackUrl,_that.posterUrl,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PresentationVideoView extends PresentationVideoView {
  const _PresentationVideoView({@JsonKey(name: PresentationVideoView.playbackUrlKey_) required this.playbackUrl, @JsonKey(name: PresentationVideoView.posterUrlKey_) this.posterUrl, @JsonKey(name: PresentationVideoView.durationSecondsKey_) this.durationSeconds}): super._();
  factory _PresentationVideoView.fromJson(Map<String, dynamic> json) => _$PresentationVideoViewFromJson(json);

/// playbackUrl
@override@JsonKey(name: PresentationVideoView.playbackUrlKey_) final  String playbackUrl;
/// posterUrl
@override@JsonKey(name: PresentationVideoView.posterUrlKey_) final  String? posterUrl;
/// durationSeconds
@override@JsonKey(name: PresentationVideoView.durationSecondsKey_) final  int? durationSeconds;

/// Create a copy of PresentationVideoView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresentationVideoViewCopyWith<_PresentationVideoView> get copyWith => __$PresentationVideoViewCopyWithImpl<_PresentationVideoView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresentationVideoViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresentationVideoView&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackUrl,posterUrl,durationSeconds);

@override
String toString() {
  return 'PresentationVideoView(playbackUrl: $playbackUrl, posterUrl: $posterUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$PresentationVideoViewCopyWith<$Res> implements $PresentationVideoViewCopyWith<$Res> {
  factory _$PresentationVideoViewCopyWith(_PresentationVideoView value, $Res Function(_PresentationVideoView) _then) = __$PresentationVideoViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PresentationVideoView.playbackUrlKey_) String playbackUrl,@JsonKey(name: PresentationVideoView.posterUrlKey_) String? posterUrl,@JsonKey(name: PresentationVideoView.durationSecondsKey_) int? durationSeconds
});




}
/// @nodoc
class __$PresentationVideoViewCopyWithImpl<$Res>
    implements _$PresentationVideoViewCopyWith<$Res> {
  __$PresentationVideoViewCopyWithImpl(this._self, this._then);

  final _PresentationVideoView _self;
  final $Res Function(_PresentationVideoView) _then;

/// Create a copy of PresentationVideoView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playbackUrl = null,Object? posterUrl = freezed,Object? durationSeconds = freezed,}) {
  return _then(_PresentationVideoView(
playbackUrl: null == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
