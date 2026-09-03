// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_upload_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoUploadCreateRequest {

/// purpose
@JsonKey(name: PhotoUploadCreateRequest.purposeKey_) MediaPurpose get purpose;/// contentType
@JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_) String get contentType;/// fileName
@JsonKey(name: PhotoUploadCreateRequest.fileNameKey_) String? get fileName;
/// Create a copy of PhotoUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoUploadCreateRequestCopyWith<PhotoUploadCreateRequest> get copyWith => _$PhotoUploadCreateRequestCopyWithImpl<PhotoUploadCreateRequest>(this as PhotoUploadCreateRequest, _$identity);

  /// Serializes this PhotoUploadCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoUploadCreateRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,contentType,fileName);

@override
String toString() {
  return 'PhotoUploadCreateRequest(purpose: $purpose, contentType: $contentType, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $PhotoUploadCreateRequestCopyWith<$Res>  {
  factory $PhotoUploadCreateRequestCopyWith(PhotoUploadCreateRequest value, $Res Function(PhotoUploadCreateRequest) _then) = _$PhotoUploadCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PhotoUploadCreateRequest.purposeKey_) MediaPurpose purpose,@JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_) String contentType,@JsonKey(name: PhotoUploadCreateRequest.fileNameKey_) String? fileName
});




}
/// @nodoc
class _$PhotoUploadCreateRequestCopyWithImpl<$Res>
    implements $PhotoUploadCreateRequestCopyWith<$Res> {
  _$PhotoUploadCreateRequestCopyWithImpl(this._self, this._then);

  final PhotoUploadCreateRequest _self;
  final $Res Function(PhotoUploadCreateRequest) _then;

/// Create a copy of PhotoUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purpose = null,Object? contentType = null,Object? fileName = freezed,}) {
  return _then(_self.copyWith(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as MediaPurpose,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoUploadCreateRequest].
extension PhotoUploadCreateRequestPatterns on PhotoUploadCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoUploadCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoUploadCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoUploadCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoUploadCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PhotoUploadCreateRequest.purposeKey_)  MediaPurpose purpose, @JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_)  String contentType, @JsonKey(name: PhotoUploadCreateRequest.fileNameKey_)  String? fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoUploadCreateRequest() when $default != null:
return $default(_that.purpose,_that.contentType,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PhotoUploadCreateRequest.purposeKey_)  MediaPurpose purpose, @JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_)  String contentType, @JsonKey(name: PhotoUploadCreateRequest.fileNameKey_)  String? fileName)  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadCreateRequest():
return $default(_that.purpose,_that.contentType,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PhotoUploadCreateRequest.purposeKey_)  MediaPurpose purpose, @JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_)  String contentType, @JsonKey(name: PhotoUploadCreateRequest.fileNameKey_)  String? fileName)?  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadCreateRequest() when $default != null:
return $default(_that.purpose,_that.contentType,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PhotoUploadCreateRequest extends PhotoUploadCreateRequest {
  const _PhotoUploadCreateRequest({@JsonKey(name: PhotoUploadCreateRequest.purposeKey_) required this.purpose, @JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_) required this.contentType, @JsonKey(name: PhotoUploadCreateRequest.fileNameKey_) this.fileName}): super._();
  factory _PhotoUploadCreateRequest.fromJson(Map<String, dynamic> json) => _$PhotoUploadCreateRequestFromJson(json);

/// purpose
@override@JsonKey(name: PhotoUploadCreateRequest.purposeKey_) final  MediaPurpose purpose;
/// contentType
@override@JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_) final  String contentType;
/// fileName
@override@JsonKey(name: PhotoUploadCreateRequest.fileNameKey_) final  String? fileName;

/// Create a copy of PhotoUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoUploadCreateRequestCopyWith<_PhotoUploadCreateRequest> get copyWith => __$PhotoUploadCreateRequestCopyWithImpl<_PhotoUploadCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoUploadCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoUploadCreateRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,contentType,fileName);

@override
String toString() {
  return 'PhotoUploadCreateRequest(purpose: $purpose, contentType: $contentType, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$PhotoUploadCreateRequestCopyWith<$Res> implements $PhotoUploadCreateRequestCopyWith<$Res> {
  factory _$PhotoUploadCreateRequestCopyWith(_PhotoUploadCreateRequest value, $Res Function(_PhotoUploadCreateRequest) _then) = __$PhotoUploadCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PhotoUploadCreateRequest.purposeKey_) MediaPurpose purpose,@JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_) String contentType,@JsonKey(name: PhotoUploadCreateRequest.fileNameKey_) String? fileName
});




}
/// @nodoc
class __$PhotoUploadCreateRequestCopyWithImpl<$Res>
    implements _$PhotoUploadCreateRequestCopyWith<$Res> {
  __$PhotoUploadCreateRequestCopyWithImpl(this._self, this._then);

  final _PhotoUploadCreateRequest _self;
  final $Res Function(_PhotoUploadCreateRequest) _then;

/// Create a copy of PhotoUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purpose = null,Object? contentType = null,Object? fileName = freezed,}) {
  return _then(_PhotoUploadCreateRequest(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as MediaPurpose,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
