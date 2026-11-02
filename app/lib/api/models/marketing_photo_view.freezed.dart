// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketing_photo_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketingPhotoView {

/// mediaAssetId
@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_) String get mediaAssetId;/// thumbnailUrl
@JsonKey(name: MarketingPhotoView.thumbnailUrlKey_) String? get thumbnailUrl;
/// Create a copy of MarketingPhotoView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketingPhotoViewCopyWith<MarketingPhotoView> get copyWith => _$MarketingPhotoViewCopyWithImpl<MarketingPhotoView>(this as MarketingPhotoView, _$identity);

  /// Serializes this MarketingPhotoView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketingPhotoView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,thumbnailUrl);

@override
String toString() {
  return 'MarketingPhotoView(mediaAssetId: $mediaAssetId, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class $MarketingPhotoViewCopyWith<$Res>  {
  factory $MarketingPhotoViewCopyWith(MarketingPhotoView value, $Res Function(MarketingPhotoView) _then) = _$MarketingPhotoViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MarketingPhotoView.thumbnailUrlKey_) String? thumbnailUrl
});




}
/// @nodoc
class _$MarketingPhotoViewCopyWithImpl<$Res>
    implements $MarketingPhotoViewCopyWith<$Res> {
  _$MarketingPhotoViewCopyWithImpl(this._self, this._then);

  final MarketingPhotoView _self;
  final $Res Function(MarketingPhotoView) _then;

/// Create a copy of MarketingPhotoView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? thumbnailUrl = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketingPhotoView].
extension MarketingPhotoViewPatterns on MarketingPhotoView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketingPhotoView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketingPhotoView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketingPhotoView value)  $default,){
final _that = this;
switch (_that) {
case _MarketingPhotoView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketingPhotoView value)?  $default,){
final _that = this;
switch (_that) {
case _MarketingPhotoView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MarketingPhotoView.thumbnailUrlKey_)  String? thumbnailUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketingPhotoView() when $default != null:
return $default(_that.mediaAssetId,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MarketingPhotoView.thumbnailUrlKey_)  String? thumbnailUrl)  $default,) {final _that = this;
switch (_that) {
case _MarketingPhotoView():
return $default(_that.mediaAssetId,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MarketingPhotoView.thumbnailUrlKey_)  String? thumbnailUrl)?  $default,) {final _that = this;
switch (_that) {
case _MarketingPhotoView() when $default != null:
return $default(_that.mediaAssetId,_that.thumbnailUrl);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MarketingPhotoView extends MarketingPhotoView {
  const _MarketingPhotoView({@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: MarketingPhotoView.thumbnailUrlKey_) this.thumbnailUrl}): super._();
  factory _MarketingPhotoView.fromJson(Map<String, dynamic> json) => _$MarketingPhotoViewFromJson(json);

/// mediaAssetId
@override@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_) final  String mediaAssetId;
/// thumbnailUrl
@override@JsonKey(name: MarketingPhotoView.thumbnailUrlKey_) final  String? thumbnailUrl;

/// Create a copy of MarketingPhotoView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketingPhotoViewCopyWith<_MarketingPhotoView> get copyWith => __$MarketingPhotoViewCopyWithImpl<_MarketingPhotoView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketingPhotoViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketingPhotoView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,thumbnailUrl);

@override
String toString() {
  return 'MarketingPhotoView(mediaAssetId: $mediaAssetId, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class _$MarketingPhotoViewCopyWith<$Res> implements $MarketingPhotoViewCopyWith<$Res> {
  factory _$MarketingPhotoViewCopyWith(_MarketingPhotoView value, $Res Function(_MarketingPhotoView) _then) = __$MarketingPhotoViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MarketingPhotoView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MarketingPhotoView.thumbnailUrlKey_) String? thumbnailUrl
});




}
/// @nodoc
class __$MarketingPhotoViewCopyWithImpl<$Res>
    implements _$MarketingPhotoViewCopyWith<$Res> {
  __$MarketingPhotoViewCopyWithImpl(this._self, this._then);

  final _MarketingPhotoView _self;
  final $Res Function(_MarketingPhotoView) _then;

/// Create a copy of MarketingPhotoView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? thumbnailUrl = freezed,}) {
  return _then(_MarketingPhotoView(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
