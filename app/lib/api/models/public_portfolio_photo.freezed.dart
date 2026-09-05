// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_portfolio_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicPortfolioPhoto {

/// mediaAssetId
@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_) String get mediaAssetId;/// thumbnailUrl
@JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_) String? get thumbnailUrl;/// watermarkPreviewUrl
@JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_) String? get watermarkPreviewUrl;
/// Create a copy of PublicPortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicPortfolioPhotoCopyWith<PublicPortfolioPhoto> get copyWith => _$PublicPortfolioPhotoCopyWithImpl<PublicPortfolioPhoto>(this as PublicPortfolioPhoto, _$identity);

  /// Serializes this PublicPortfolioPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicPortfolioPhoto&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.watermarkPreviewUrl, watermarkPreviewUrl) || other.watermarkPreviewUrl == watermarkPreviewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,thumbnailUrl,watermarkPreviewUrl);

@override
String toString() {
  return 'PublicPortfolioPhoto(mediaAssetId: $mediaAssetId, thumbnailUrl: $thumbnailUrl, watermarkPreviewUrl: $watermarkPreviewUrl)';
}


}

/// @nodoc
abstract mixin class $PublicPortfolioPhotoCopyWith<$Res>  {
  factory $PublicPortfolioPhotoCopyWith(PublicPortfolioPhoto value, $Res Function(PublicPortfolioPhoto) _then) = _$PublicPortfolioPhotoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_) String? watermarkPreviewUrl
});




}
/// @nodoc
class _$PublicPortfolioPhotoCopyWithImpl<$Res>
    implements $PublicPortfolioPhotoCopyWith<$Res> {
  _$PublicPortfolioPhotoCopyWithImpl(this._self, this._then);

  final PublicPortfolioPhoto _self;
  final $Res Function(PublicPortfolioPhoto) _then;

/// Create a copy of PublicPortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? thumbnailUrl = freezed,Object? watermarkPreviewUrl = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,watermarkPreviewUrl: freezed == watermarkPreviewUrl ? _self.watermarkPreviewUrl : watermarkPreviewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicPortfolioPhoto].
extension PublicPortfolioPhotoPatterns on PublicPortfolioPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicPortfolioPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicPortfolioPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicPortfolioPhoto value)  $default,){
final _that = this;
switch (_that) {
case _PublicPortfolioPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicPortfolioPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicPortfolioPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_)  String? watermarkPreviewUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicPortfolioPhoto() when $default != null:
return $default(_that.mediaAssetId,_that.thumbnailUrl,_that.watermarkPreviewUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_)  String? watermarkPreviewUrl)  $default,) {final _that = this;
switch (_that) {
case _PublicPortfolioPhoto():
return $default(_that.mediaAssetId,_that.thumbnailUrl,_that.watermarkPreviewUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_)  String? watermarkPreviewUrl)?  $default,) {final _that = this;
switch (_that) {
case _PublicPortfolioPhoto() when $default != null:
return $default(_that.mediaAssetId,_that.thumbnailUrl,_that.watermarkPreviewUrl);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PublicPortfolioPhoto extends PublicPortfolioPhoto {
  const _PublicPortfolioPhoto({@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_) this.thumbnailUrl, @JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_) this.watermarkPreviewUrl}): super._();
  factory _PublicPortfolioPhoto.fromJson(Map<String, dynamic> json) => _$PublicPortfolioPhotoFromJson(json);

/// mediaAssetId
@override@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_) final  String mediaAssetId;
/// thumbnailUrl
@override@JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_) final  String? thumbnailUrl;
/// watermarkPreviewUrl
@override@JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_) final  String? watermarkPreviewUrl;

/// Create a copy of PublicPortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicPortfolioPhotoCopyWith<_PublicPortfolioPhoto> get copyWith => __$PublicPortfolioPhotoCopyWithImpl<_PublicPortfolioPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicPortfolioPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicPortfolioPhoto&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.watermarkPreviewUrl, watermarkPreviewUrl) || other.watermarkPreviewUrl == watermarkPreviewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,thumbnailUrl,watermarkPreviewUrl);

@override
String toString() {
  return 'PublicPortfolioPhoto(mediaAssetId: $mediaAssetId, thumbnailUrl: $thumbnailUrl, watermarkPreviewUrl: $watermarkPreviewUrl)';
}


}

/// @nodoc
abstract mixin class _$PublicPortfolioPhotoCopyWith<$Res> implements $PublicPortfolioPhotoCopyWith<$Res> {
  factory _$PublicPortfolioPhotoCopyWith(_PublicPortfolioPhoto value, $Res Function(_PublicPortfolioPhoto) _then) = __$PublicPortfolioPhotoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_) String? watermarkPreviewUrl
});




}
/// @nodoc
class __$PublicPortfolioPhotoCopyWithImpl<$Res>
    implements _$PublicPortfolioPhotoCopyWith<$Res> {
  __$PublicPortfolioPhotoCopyWithImpl(this._self, this._then);

  final _PublicPortfolioPhoto _self;
  final $Res Function(_PublicPortfolioPhoto) _then;

/// Create a copy of PublicPortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? thumbnailUrl = freezed,Object? watermarkPreviewUrl = freezed,}) {
  return _then(_PublicPortfolioPhoto(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,watermarkPreviewUrl: freezed == watermarkPreviewUrl ? _self.watermarkPreviewUrl : watermarkPreviewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
