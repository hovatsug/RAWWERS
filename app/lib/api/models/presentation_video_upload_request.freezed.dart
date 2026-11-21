// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentation_video_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresentationVideoUploadRequest {

/// byteSize
@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_) int get byteSize;/// durationSeconds
@JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_) double? get durationSeconds;/// contentType
@JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_) String? get contentType;/// requestId
@JsonKey(name: PresentationVideoUploadRequest.requestIdKey_) String get requestId;
/// Create a copy of PresentationVideoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresentationVideoUploadRequestCopyWith<PresentationVideoUploadRequest> get copyWith => _$PresentationVideoUploadRequestCopyWithImpl<PresentationVideoUploadRequest>(this as PresentationVideoUploadRequest, _$identity);

  /// Serializes this PresentationVideoUploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationVideoUploadRequest&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,byteSize,durationSeconds,contentType,requestId);

@override
String toString() {
  return 'PresentationVideoUploadRequest(byteSize: $byteSize, durationSeconds: $durationSeconds, contentType: $contentType, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class $PresentationVideoUploadRequestCopyWith<$Res>  {
  factory $PresentationVideoUploadRequestCopyWith(PresentationVideoUploadRequest value, $Res Function(PresentationVideoUploadRequest) _then) = _$PresentationVideoUploadRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_) int byteSize,@JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_) double? durationSeconds,@JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_) String? contentType,@JsonKey(name: PresentationVideoUploadRequest.requestIdKey_) String requestId
});




}
/// @nodoc
class _$PresentationVideoUploadRequestCopyWithImpl<$Res>
    implements $PresentationVideoUploadRequestCopyWith<$Res> {
  _$PresentationVideoUploadRequestCopyWithImpl(this._self, this._then);

  final PresentationVideoUploadRequest _self;
  final $Res Function(PresentationVideoUploadRequest) _then;

/// Create a copy of PresentationVideoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byteSize = null,Object? durationSeconds = freezed,Object? contentType = freezed,Object? requestId = null,}) {
  return _then(_self.copyWith(
byteSize: null == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PresentationVideoUploadRequest].
extension PresentationVideoUploadRequestPatterns on PresentationVideoUploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresentationVideoUploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresentationVideoUploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresentationVideoUploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoUploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresentationVideoUploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PresentationVideoUploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_)  int byteSize, @JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_)  double? durationSeconds, @JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_)  String? contentType, @JsonKey(name: PresentationVideoUploadRequest.requestIdKey_)  String requestId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresentationVideoUploadRequest() when $default != null:
return $default(_that.byteSize,_that.durationSeconds,_that.contentType,_that.requestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_)  int byteSize, @JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_)  double? durationSeconds, @JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_)  String? contentType, @JsonKey(name: PresentationVideoUploadRequest.requestIdKey_)  String requestId)  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoUploadRequest():
return $default(_that.byteSize,_that.durationSeconds,_that.contentType,_that.requestId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_)  int byteSize, @JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_)  double? durationSeconds, @JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_)  String? contentType, @JsonKey(name: PresentationVideoUploadRequest.requestIdKey_)  String requestId)?  $default,) {final _that = this;
switch (_that) {
case _PresentationVideoUploadRequest() when $default != null:
return $default(_that.byteSize,_that.durationSeconds,_that.contentType,_that.requestId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PresentationVideoUploadRequest extends PresentationVideoUploadRequest {
  const _PresentationVideoUploadRequest({@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_) required this.byteSize, @JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_) this.durationSeconds, @JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_) this.contentType, @JsonKey(name: PresentationVideoUploadRequest.requestIdKey_) required this.requestId}): super._();
  factory _PresentationVideoUploadRequest.fromJson(Map<String, dynamic> json) => _$PresentationVideoUploadRequestFromJson(json);

/// byteSize
@override@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_) final  int byteSize;
/// durationSeconds
@override@JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_) final  double? durationSeconds;
/// contentType
@override@JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_) final  String? contentType;
/// requestId
@override@JsonKey(name: PresentationVideoUploadRequest.requestIdKey_) final  String requestId;

/// Create a copy of PresentationVideoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresentationVideoUploadRequestCopyWith<_PresentationVideoUploadRequest> get copyWith => __$PresentationVideoUploadRequestCopyWithImpl<_PresentationVideoUploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresentationVideoUploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresentationVideoUploadRequest&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,byteSize,durationSeconds,contentType,requestId);

@override
String toString() {
  return 'PresentationVideoUploadRequest(byteSize: $byteSize, durationSeconds: $durationSeconds, contentType: $contentType, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class _$PresentationVideoUploadRequestCopyWith<$Res> implements $PresentationVideoUploadRequestCopyWith<$Res> {
  factory _$PresentationVideoUploadRequestCopyWith(_PresentationVideoUploadRequest value, $Res Function(_PresentationVideoUploadRequest) _then) = __$PresentationVideoUploadRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_) int byteSize,@JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_) double? durationSeconds,@JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_) String? contentType,@JsonKey(name: PresentationVideoUploadRequest.requestIdKey_) String requestId
});




}
/// @nodoc
class __$PresentationVideoUploadRequestCopyWithImpl<$Res>
    implements _$PresentationVideoUploadRequestCopyWith<$Res> {
  __$PresentationVideoUploadRequestCopyWithImpl(this._self, this._then);

  final _PresentationVideoUploadRequest _self;
  final $Res Function(_PresentationVideoUploadRequest) _then;

/// Create a copy of PresentationVideoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byteSize = null,Object? durationSeconds = freezed,Object? contentType = freezed,Object? requestId = null,}) {
  return _then(_PresentationVideoUploadRequest(
byteSize: null == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
