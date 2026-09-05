// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_item_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GalleryItemView {

/// mediaAssetId
@JsonKey(name: GalleryItemView.mediaAssetIdKey_) String get mediaAssetId;/// sortOrder
@JsonKey(name: GalleryItemView.sortOrderKey_) int get sortOrder;/// thumbnailUrl
@JsonKey(name: GalleryItemView.thumbnailUrlKey_) String? get thumbnailUrl;/// watermarkPreviewUrl
@JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_) String? get watermarkPreviewUrl;
/// Create a copy of GalleryItemView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryItemViewCopyWith<GalleryItemView> get copyWith => _$GalleryItemViewCopyWithImpl<GalleryItemView>(this as GalleryItemView, _$identity);

  /// Serializes this GalleryItemView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryItemView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.watermarkPreviewUrl, watermarkPreviewUrl) || other.watermarkPreviewUrl == watermarkPreviewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,sortOrder,thumbnailUrl,watermarkPreviewUrl);

@override
String toString() {
  return 'GalleryItemView(mediaAssetId: $mediaAssetId, sortOrder: $sortOrder, thumbnailUrl: $thumbnailUrl, watermarkPreviewUrl: $watermarkPreviewUrl)';
}


}

/// @nodoc
abstract mixin class $GalleryItemViewCopyWith<$Res>  {
  factory $GalleryItemViewCopyWith(GalleryItemView value, $Res Function(GalleryItemView) _then) = _$GalleryItemViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GalleryItemView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: GalleryItemView.sortOrderKey_) int sortOrder,@JsonKey(name: GalleryItemView.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_) String? watermarkPreviewUrl
});




}
/// @nodoc
class _$GalleryItemViewCopyWithImpl<$Res>
    implements $GalleryItemViewCopyWith<$Res> {
  _$GalleryItemViewCopyWithImpl(this._self, this._then);

  final GalleryItemView _self;
  final $Res Function(GalleryItemView) _then;

/// Create a copy of GalleryItemView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? sortOrder = null,Object? thumbnailUrl = freezed,Object? watermarkPreviewUrl = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,watermarkPreviewUrl: freezed == watermarkPreviewUrl ? _self.watermarkPreviewUrl : watermarkPreviewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryItemView].
extension GalleryItemViewPatterns on GalleryItemView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryItemView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryItemView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryItemView value)  $default,){
final _that = this;
switch (_that) {
case _GalleryItemView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryItemView value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryItemView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GalleryItemView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: GalleryItemView.sortOrderKey_)  int sortOrder, @JsonKey(name: GalleryItemView.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_)  String? watermarkPreviewUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryItemView() when $default != null:
return $default(_that.mediaAssetId,_that.sortOrder,_that.thumbnailUrl,_that.watermarkPreviewUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GalleryItemView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: GalleryItemView.sortOrderKey_)  int sortOrder, @JsonKey(name: GalleryItemView.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_)  String? watermarkPreviewUrl)  $default,) {final _that = this;
switch (_that) {
case _GalleryItemView():
return $default(_that.mediaAssetId,_that.sortOrder,_that.thumbnailUrl,_that.watermarkPreviewUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GalleryItemView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: GalleryItemView.sortOrderKey_)  int sortOrder, @JsonKey(name: GalleryItemView.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_)  String? watermarkPreviewUrl)?  $default,) {final _that = this;
switch (_that) {
case _GalleryItemView() when $default != null:
return $default(_that.mediaAssetId,_that.sortOrder,_that.thumbnailUrl,_that.watermarkPreviewUrl);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GalleryItemView extends GalleryItemView {
  const _GalleryItemView({@JsonKey(name: GalleryItemView.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: GalleryItemView.sortOrderKey_) required this.sortOrder, @JsonKey(name: GalleryItemView.thumbnailUrlKey_) this.thumbnailUrl, @JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_) this.watermarkPreviewUrl}): super._();
  factory _GalleryItemView.fromJson(Map<String, dynamic> json) => _$GalleryItemViewFromJson(json);

/// mediaAssetId
@override@JsonKey(name: GalleryItemView.mediaAssetIdKey_) final  String mediaAssetId;
/// sortOrder
@override@JsonKey(name: GalleryItemView.sortOrderKey_) final  int sortOrder;
/// thumbnailUrl
@override@JsonKey(name: GalleryItemView.thumbnailUrlKey_) final  String? thumbnailUrl;
/// watermarkPreviewUrl
@override@JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_) final  String? watermarkPreviewUrl;

/// Create a copy of GalleryItemView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryItemViewCopyWith<_GalleryItemView> get copyWith => __$GalleryItemViewCopyWithImpl<_GalleryItemView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryItemViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryItemView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.watermarkPreviewUrl, watermarkPreviewUrl) || other.watermarkPreviewUrl == watermarkPreviewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,sortOrder,thumbnailUrl,watermarkPreviewUrl);

@override
String toString() {
  return 'GalleryItemView(mediaAssetId: $mediaAssetId, sortOrder: $sortOrder, thumbnailUrl: $thumbnailUrl, watermarkPreviewUrl: $watermarkPreviewUrl)';
}


}

/// @nodoc
abstract mixin class _$GalleryItemViewCopyWith<$Res> implements $GalleryItemViewCopyWith<$Res> {
  factory _$GalleryItemViewCopyWith(_GalleryItemView value, $Res Function(_GalleryItemView) _then) = __$GalleryItemViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GalleryItemView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: GalleryItemView.sortOrderKey_) int sortOrder,@JsonKey(name: GalleryItemView.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_) String? watermarkPreviewUrl
});




}
/// @nodoc
class __$GalleryItemViewCopyWithImpl<$Res>
    implements _$GalleryItemViewCopyWith<$Res> {
  __$GalleryItemViewCopyWithImpl(this._self, this._then);

  final _GalleryItemView _self;
  final $Res Function(_GalleryItemView) _then;

/// Create a copy of GalleryItemView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? sortOrder = null,Object? thumbnailUrl = freezed,Object? watermarkPreviewUrl = freezed,}) {
  return _then(_GalleryItemView(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,watermarkPreviewUrl: freezed == watermarkPreviewUrl ? _self.watermarkPreviewUrl : watermarkPreviewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
