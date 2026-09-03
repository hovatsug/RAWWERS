// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_upload_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoUploadCreateResponse {

/// mediaAssetId
@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_) String get mediaAssetId;/// upload
@JsonKey(name: PhotoUploadCreateResponse.uploadKey_) UploadPayload get upload;
/// Create a copy of PhotoUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoUploadCreateResponseCopyWith<PhotoUploadCreateResponse> get copyWith => _$PhotoUploadCreateResponseCopyWithImpl<PhotoUploadCreateResponse>(this as PhotoUploadCreateResponse, _$identity);

  /// Serializes this PhotoUploadCreateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoUploadCreateResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.upload, upload) || other.upload == upload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,upload);

@override
String toString() {
  return 'PhotoUploadCreateResponse(mediaAssetId: $mediaAssetId, upload: $upload)';
}


}

/// @nodoc
abstract mixin class $PhotoUploadCreateResponseCopyWith<$Res>  {
  factory $PhotoUploadCreateResponseCopyWith(PhotoUploadCreateResponse value, $Res Function(PhotoUploadCreateResponse) _then) = _$PhotoUploadCreateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PhotoUploadCreateResponse.uploadKey_) UploadPayload upload
});


$UploadPayloadCopyWith<$Res> get upload;

}
/// @nodoc
class _$PhotoUploadCreateResponseCopyWithImpl<$Res>
    implements $PhotoUploadCreateResponseCopyWith<$Res> {
  _$PhotoUploadCreateResponseCopyWithImpl(this._self, this._then);

  final PhotoUploadCreateResponse _self;
  final $Res Function(PhotoUploadCreateResponse) _then;

/// Create a copy of PhotoUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? upload = null,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as UploadPayload,
  ));
}
/// Create a copy of PhotoUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadPayloadCopyWith<$Res> get upload {
  
  return $UploadPayloadCopyWith<$Res>(_self.upload, (value) {
    return _then(_self.copyWith(upload: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhotoUploadCreateResponse].
extension PhotoUploadCreateResponsePatterns on PhotoUploadCreateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoUploadCreateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoUploadCreateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoUploadCreateResponse value)  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadCreateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoUploadCreateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadCreateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PhotoUploadCreateResponse.uploadKey_)  UploadPayload upload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoUploadCreateResponse() when $default != null:
return $default(_that.mediaAssetId,_that.upload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PhotoUploadCreateResponse.uploadKey_)  UploadPayload upload)  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadCreateResponse():
return $default(_that.mediaAssetId,_that.upload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PhotoUploadCreateResponse.uploadKey_)  UploadPayload upload)?  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadCreateResponse() when $default != null:
return $default(_that.mediaAssetId,_that.upload);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PhotoUploadCreateResponse extends PhotoUploadCreateResponse {
  const _PhotoUploadCreateResponse({@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: PhotoUploadCreateResponse.uploadKey_) required this.upload}): super._();
  factory _PhotoUploadCreateResponse.fromJson(Map<String, dynamic> json) => _$PhotoUploadCreateResponseFromJson(json);

/// mediaAssetId
@override@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_) final  String mediaAssetId;
/// upload
@override@JsonKey(name: PhotoUploadCreateResponse.uploadKey_) final  UploadPayload upload;

/// Create a copy of PhotoUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoUploadCreateResponseCopyWith<_PhotoUploadCreateResponse> get copyWith => __$PhotoUploadCreateResponseCopyWithImpl<_PhotoUploadCreateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoUploadCreateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoUploadCreateResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.upload, upload) || other.upload == upload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,upload);

@override
String toString() {
  return 'PhotoUploadCreateResponse(mediaAssetId: $mediaAssetId, upload: $upload)';
}


}

/// @nodoc
abstract mixin class _$PhotoUploadCreateResponseCopyWith<$Res> implements $PhotoUploadCreateResponseCopyWith<$Res> {
  factory _$PhotoUploadCreateResponseCopyWith(_PhotoUploadCreateResponse value, $Res Function(_PhotoUploadCreateResponse) _then) = __$PhotoUploadCreateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PhotoUploadCreateResponse.uploadKey_) UploadPayload upload
});


@override $UploadPayloadCopyWith<$Res> get upload;

}
/// @nodoc
class __$PhotoUploadCreateResponseCopyWithImpl<$Res>
    implements _$PhotoUploadCreateResponseCopyWith<$Res> {
  __$PhotoUploadCreateResponseCopyWithImpl(this._self, this._then);

  final _PhotoUploadCreateResponse _self;
  final $Res Function(_PhotoUploadCreateResponse) _then;

/// Create a copy of PhotoUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? upload = null,}) {
  return _then(_PhotoUploadCreateResponse(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as UploadPayload,
  ));
}

/// Create a copy of PhotoUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadPayloadCopyWith<$Res> get upload {
  
  return $UploadPayloadCopyWith<$Res>(_self.upload, (value) {
    return _then(_self.copyWith(upload: value));
  });
}
}

// dart format on
