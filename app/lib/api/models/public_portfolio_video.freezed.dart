// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_portfolio_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicPortfolioVideo {

/// mediaAssetId
@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_) String get mediaAssetId;/// playbackId
@JsonKey(name: PublicPortfolioVideo.playbackIdKey_) String? get playbackId;
/// Create a copy of PublicPortfolioVideo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicPortfolioVideoCopyWith<PublicPortfolioVideo> get copyWith => _$PublicPortfolioVideoCopyWithImpl<PublicPortfolioVideo>(this as PublicPortfolioVideo, _$identity);

  /// Serializes this PublicPortfolioVideo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicPortfolioVideo&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,playbackId);

@override
String toString() {
  return 'PublicPortfolioVideo(mediaAssetId: $mediaAssetId, playbackId: $playbackId)';
}


}

/// @nodoc
abstract mixin class $PublicPortfolioVideoCopyWith<$Res>  {
  factory $PublicPortfolioVideoCopyWith(PublicPortfolioVideo value, $Res Function(PublicPortfolioVideo) _then) = _$PublicPortfolioVideoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PublicPortfolioVideo.playbackIdKey_) String? playbackId
});




}
/// @nodoc
class _$PublicPortfolioVideoCopyWithImpl<$Res>
    implements $PublicPortfolioVideoCopyWith<$Res> {
  _$PublicPortfolioVideoCopyWithImpl(this._self, this._then);

  final PublicPortfolioVideo _self;
  final $Res Function(PublicPortfolioVideo) _then;

/// Create a copy of PublicPortfolioVideo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? playbackId = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicPortfolioVideo].
extension PublicPortfolioVideoPatterns on PublicPortfolioVideo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicPortfolioVideo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicPortfolioVideo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicPortfolioVideo value)  $default,){
final _that = this;
switch (_that) {
case _PublicPortfolioVideo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicPortfolioVideo value)?  $default,){
final _that = this;
switch (_that) {
case _PublicPortfolioVideo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PublicPortfolioVideo.playbackIdKey_)  String? playbackId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicPortfolioVideo() when $default != null:
return $default(_that.mediaAssetId,_that.playbackId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PublicPortfolioVideo.playbackIdKey_)  String? playbackId)  $default,) {final _that = this;
switch (_that) {
case _PublicPortfolioVideo():
return $default(_that.mediaAssetId,_that.playbackId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PublicPortfolioVideo.playbackIdKey_)  String? playbackId)?  $default,) {final _that = this;
switch (_that) {
case _PublicPortfolioVideo() when $default != null:
return $default(_that.mediaAssetId,_that.playbackId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PublicPortfolioVideo extends PublicPortfolioVideo {
  const _PublicPortfolioVideo({@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: PublicPortfolioVideo.playbackIdKey_) this.playbackId}): super._();
  factory _PublicPortfolioVideo.fromJson(Map<String, dynamic> json) => _$PublicPortfolioVideoFromJson(json);

/// mediaAssetId
@override@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_) final  String mediaAssetId;
/// playbackId
@override@JsonKey(name: PublicPortfolioVideo.playbackIdKey_) final  String? playbackId;

/// Create a copy of PublicPortfolioVideo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicPortfolioVideoCopyWith<_PublicPortfolioVideo> get copyWith => __$PublicPortfolioVideoCopyWithImpl<_PublicPortfolioVideo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicPortfolioVideoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicPortfolioVideo&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,playbackId);

@override
String toString() {
  return 'PublicPortfolioVideo(mediaAssetId: $mediaAssetId, playbackId: $playbackId)';
}


}

/// @nodoc
abstract mixin class _$PublicPortfolioVideoCopyWith<$Res> implements $PublicPortfolioVideoCopyWith<$Res> {
  factory _$PublicPortfolioVideoCopyWith(_PublicPortfolioVideo value, $Res Function(_PublicPortfolioVideo) _then) = __$PublicPortfolioVideoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PublicPortfolioVideo.playbackIdKey_) String? playbackId
});




}
/// @nodoc
class __$PublicPortfolioVideoCopyWithImpl<$Res>
    implements _$PublicPortfolioVideoCopyWith<$Res> {
  __$PublicPortfolioVideoCopyWithImpl(this._self, this._then);

  final _PublicPortfolioVideo _self;
  final $Res Function(_PublicPortfolioVideo) _then;

/// Create a copy of PublicPortfolioVideo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? playbackId = freezed,}) {
  return _then(_PublicPortfolioVideo(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
