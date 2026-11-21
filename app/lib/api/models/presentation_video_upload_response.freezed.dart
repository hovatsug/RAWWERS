// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentation_video_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresentationVideoUploadResponse {

/// mediaAssetId
@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_) String get mediaAssetId;/// uploadUrl
@JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_) String get uploadUrl;/// status
@JsonKey(name: PresentationVideoUploadResponse.statusKey_) String get status;
/// Create a copy of PresentationVideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresentationVideoUploadResponseCopyWith<PresentationVideoUploadResponse> get copyWith => _$PresentationVideoUploadResponseCopyWithImpl<PresentationVideoUploadResponse>(this as PresentationVideoUploadResponse, _$identity);

  /// Serializes this PresentationVideoUploadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationVideoUploadResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,uploadUrl,status);

@override
String toString() {
  return 'PresentationVideoUploadResponse(mediaAssetId: $mediaAssetId, uploadUrl: $uploadUrl, status: $status)';
}


}

/// @nodoc
abstract mixin class $PresentationVideoUploadResponseCopyWith<$Res>  {
  factory $PresentationVideoUploadResponseCopyWith(PresentationVideoUploadResponse value, $Res Function(PresentationVideoUploadResponse) _then) = _$PresentationVideoUploadResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_) String uploadUrl,@JsonKey(name: PresentationVideoUploadResponse.statusKey_) String status
});




}
/// @nodoc
class _$PresentationVideoUploadResponseCopyWithImpl<$Res>
    implements $PresentationVideoUploadResponseCopyWith<$Res> {
  _$PresentationVideoUploadResponseCopyWithImpl(this._self, this._then);

  final PresentationVideoUploadResponse _self;
  final $Res Function(PresentationVideoUploadResponse) _then;

/// Create a copy of PresentationVideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? uploadUrl = null,Object? status = null,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PresentationVideoUploadResponse].
extension PresentationVideoUploadResponsePatterns on PresentationVideoUploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresentationVideoUploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresentationVideoUploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresentationVideoUploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoUploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresentationVideoUploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoUploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_)  String uploadUrl, @JsonKey(name: PresentationVideoUploadResponse.statusKey_)  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresentationVideoUploadResponse() when $default != null:
return $default(_that.mediaAssetId,_that.uploadUrl,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_)  String uploadUrl, @JsonKey(name: PresentationVideoUploadResponse.statusKey_)  String status)  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoUploadResponse():
return $default(_that.mediaAssetId,_that.uploadUrl,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_)  String uploadUrl, @JsonKey(name: PresentationVideoUploadResponse.statusKey_)  String status)?  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoUploadResponse() when $default != null:
return $default(_that.mediaAssetId,_that.uploadUrl,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PresentationVideoUploadResponse extends PresentationVideoUploadResponse {
  const _PresentationVideoUploadResponse({@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_) required this.uploadUrl, @JsonKey(name: PresentationVideoUploadResponse.statusKey_) required this.status}): super._();
  factory _PresentationVideoUploadResponse.fromJson(Map<String, dynamic> json) => _$PresentationVideoUploadResponseFromJson(json);

/// mediaAssetId
@override@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_) final  String mediaAssetId;
/// uploadUrl
@override@JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_) final  String uploadUrl;
/// status
@override@JsonKey(name: PresentationVideoUploadResponse.statusKey_) final  String status;

/// Create a copy of PresentationVideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresentationVideoUploadResponseCopyWith<_PresentationVideoUploadResponse> get copyWith => __$PresentationVideoUploadResponseCopyWithImpl<_PresentationVideoUploadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresentationVideoUploadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresentationVideoUploadResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,uploadUrl,status);

@override
String toString() {
  return 'PresentationVideoUploadResponse(mediaAssetId: $mediaAssetId, uploadUrl: $uploadUrl, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PresentationVideoUploadResponseCopyWith<$Res> implements $PresentationVideoUploadResponseCopyWith<$Res> {
  factory _$PresentationVideoUploadResponseCopyWith(_PresentationVideoUploadResponse value, $Res Function(_PresentationVideoUploadResponse) _then) = __$PresentationVideoUploadResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_) String uploadUrl,@JsonKey(name: PresentationVideoUploadResponse.statusKey_) String status
});




}
/// @nodoc
class __$PresentationVideoUploadResponseCopyWithImpl<$Res>
    implements _$PresentationVideoUploadResponseCopyWith<$Res> {
  __$PresentationVideoUploadResponseCopyWithImpl(this._self, this._then);

  final _PresentationVideoUploadResponse _self;
  final $Res Function(_PresentationVideoUploadResponse) _then;

/// Create a copy of PresentationVideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? uploadUrl = null,Object? status = null,}) {
  return _then(_PresentationVideoUploadResponse(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
