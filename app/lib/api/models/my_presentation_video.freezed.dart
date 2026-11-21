// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_presentation_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyPresentationVideo {

/// mediaAssetId
@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_) String get mediaAssetId;/// status
@JsonKey(name: MyPresentationVideo.statusKey_) String get status;/// posterUrl
@JsonKey(name: MyPresentationVideo.posterUrlKey_) String? get posterUrl;/// playbackUrl
@JsonKey(name: MyPresentationVideo.playbackUrlKey_) String? get playbackUrl;/// durationSeconds
@JsonKey(name: MyPresentationVideo.durationSecondsKey_) int? get durationSeconds;/// message
@JsonKey(name: MyPresentationVideo.messageKey_) String? get message;
/// Create a copy of MyPresentationVideo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyPresentationVideoCopyWith<MyPresentationVideo> get copyWith => _$MyPresentationVideoCopyWithImpl<MyPresentationVideo>(this as MyPresentationVideo, _$identity);

  /// Serializes this MyPresentationVideo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyPresentationVideo&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.status, status) || other.status == status)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,status,posterUrl,playbackUrl,durationSeconds,message);

@override
String toString() {
  return 'MyPresentationVideo(mediaAssetId: $mediaAssetId, status: $status, posterUrl: $posterUrl, playbackUrl: $playbackUrl, durationSeconds: $durationSeconds, message: $message)';
}


}

/// @nodoc
abstract mixin class $MyPresentationVideoCopyWith<$Res>  {
  factory $MyPresentationVideoCopyWith(MyPresentationVideo value, $Res Function(MyPresentationVideo) _then) = _$MyPresentationVideoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MyPresentationVideo.statusKey_) String status,@JsonKey(name: MyPresentationVideo.posterUrlKey_) String? posterUrl,@JsonKey(name: MyPresentationVideo.playbackUrlKey_) String? playbackUrl,@JsonKey(name: MyPresentationVideo.durationSecondsKey_) int? durationSeconds,@JsonKey(name: MyPresentationVideo.messageKey_) String? message
});




}
/// @nodoc
class _$MyPresentationVideoCopyWithImpl<$Res>
    implements $MyPresentationVideoCopyWith<$Res> {
  _$MyPresentationVideoCopyWithImpl(this._self, this._then);

  final MyPresentationVideo _self;
  final $Res Function(MyPresentationVideo) _then;

/// Create a copy of MyPresentationVideo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? status = null,Object? posterUrl = freezed,Object? playbackUrl = freezed,Object? durationSeconds = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,playbackUrl: freezed == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyPresentationVideo].
extension MyPresentationVideoPatterns on MyPresentationVideo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyPresentationVideo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyPresentationVideo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyPresentationVideo value)  $default,){
final _that = this;
switch (_that) {
case _MyPresentationVideo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyPresentationVideo value)?  $default,){
final _that = this;
switch (_that) {
case _MyPresentationVideo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MyPresentationVideo.statusKey_)  String status, @JsonKey(name: MyPresentationVideo.posterUrlKey_)  String? posterUrl, @JsonKey(name: MyPresentationVideo.playbackUrlKey_)  String? playbackUrl, @JsonKey(name: MyPresentationVideo.durationSecondsKey_)  int? durationSeconds, @JsonKey(name: MyPresentationVideo.messageKey_)  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyPresentationVideo() when $default != null:
return $default(_that.mediaAssetId,_that.status,_that.posterUrl,_that.playbackUrl,_that.durationSeconds,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MyPresentationVideo.statusKey_)  String status, @JsonKey(name: MyPresentationVideo.posterUrlKey_)  String? posterUrl, @JsonKey(name: MyPresentationVideo.playbackUrlKey_)  String? playbackUrl, @JsonKey(name: MyPresentationVideo.durationSecondsKey_)  int? durationSeconds, @JsonKey(name: MyPresentationVideo.messageKey_)  String? message)  $default,) {final _that = this;
switch (_that) {
case _MyPresentationVideo():
return $default(_that.mediaAssetId,_that.status,_that.posterUrl,_that.playbackUrl,_that.durationSeconds,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MyPresentationVideo.statusKey_)  String status, @JsonKey(name: MyPresentationVideo.posterUrlKey_)  String? posterUrl, @JsonKey(name: MyPresentationVideo.playbackUrlKey_)  String? playbackUrl, @JsonKey(name: MyPresentationVideo.durationSecondsKey_)  int? durationSeconds, @JsonKey(name: MyPresentationVideo.messageKey_)  String? message)?  $default,) {final _that = this;
switch (_that) {
case _MyPresentationVideo() when $default != null:
return $default(_that.mediaAssetId,_that.status,_that.posterUrl,_that.playbackUrl,_that.durationSeconds,_that.message);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MyPresentationVideo extends MyPresentationVideo {
  const _MyPresentationVideo({@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: MyPresentationVideo.statusKey_) required this.status, @JsonKey(name: MyPresentationVideo.posterUrlKey_) this.posterUrl, @JsonKey(name: MyPresentationVideo.playbackUrlKey_) this.playbackUrl, @JsonKey(name: MyPresentationVideo.durationSecondsKey_) this.durationSeconds, @JsonKey(name: MyPresentationVideo.messageKey_) this.message}): super._();
  factory _MyPresentationVideo.fromJson(Map<String, dynamic> json) => _$MyPresentationVideoFromJson(json);

/// mediaAssetId
@override@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_) final  String mediaAssetId;
/// status
@override@JsonKey(name: MyPresentationVideo.statusKey_) final  String status;
/// posterUrl
@override@JsonKey(name: MyPresentationVideo.posterUrlKey_) final  String? posterUrl;
/// playbackUrl
@override@JsonKey(name: MyPresentationVideo.playbackUrlKey_) final  String? playbackUrl;
/// durationSeconds
@override@JsonKey(name: MyPresentationVideo.durationSecondsKey_) final  int? durationSeconds;
/// message
@override@JsonKey(name: MyPresentationVideo.messageKey_) final  String? message;

/// Create a copy of MyPresentationVideo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyPresentationVideoCopyWith<_MyPresentationVideo> get copyWith => __$MyPresentationVideoCopyWithImpl<_MyPresentationVideo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyPresentationVideoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyPresentationVideo&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.status, status) || other.status == status)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,status,posterUrl,playbackUrl,durationSeconds,message);

@override
String toString() {
  return 'MyPresentationVideo(mediaAssetId: $mediaAssetId, status: $status, posterUrl: $posterUrl, playbackUrl: $playbackUrl, durationSeconds: $durationSeconds, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MyPresentationVideoCopyWith<$Res> implements $MyPresentationVideoCopyWith<$Res> {
  factory _$MyPresentationVideoCopyWith(_MyPresentationVideo value, $Res Function(_MyPresentationVideo) _then) = __$MyPresentationVideoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MyPresentationVideo.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MyPresentationVideo.statusKey_) String status,@JsonKey(name: MyPresentationVideo.posterUrlKey_) String? posterUrl,@JsonKey(name: MyPresentationVideo.playbackUrlKey_) String? playbackUrl,@JsonKey(name: MyPresentationVideo.durationSecondsKey_) int? durationSeconds,@JsonKey(name: MyPresentationVideo.messageKey_) String? message
});




}
/// @nodoc
class __$MyPresentationVideoCopyWithImpl<$Res>
    implements _$MyPresentationVideoCopyWith<$Res> {
  __$MyPresentationVideoCopyWithImpl(this._self, this._then);

  final _MyPresentationVideo _self;
  final $Res Function(_MyPresentationVideo) _then;

/// Create a copy of MyPresentationVideo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? status = null,Object? posterUrl = freezed,Object? playbackUrl = freezed,Object? durationSeconds = freezed,Object? message = freezed,}) {
  return _then(_MyPresentationVideo(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,playbackUrl: freezed == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
