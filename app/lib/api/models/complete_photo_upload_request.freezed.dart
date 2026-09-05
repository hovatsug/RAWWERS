// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_photo_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompletePhotoUploadRequest {

/// byteSize
@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_) int? get byteSize;
/// Create a copy of CompletePhotoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletePhotoUploadRequestCopyWith<CompletePhotoUploadRequest> get copyWith => _$CompletePhotoUploadRequestCopyWithImpl<CompletePhotoUploadRequest>(this as CompletePhotoUploadRequest, _$identity);

  /// Serializes this CompletePhotoUploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletePhotoUploadRequest&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,byteSize);

@override
String toString() {
  return 'CompletePhotoUploadRequest(byteSize: $byteSize)';
}


}

/// @nodoc
abstract mixin class $CompletePhotoUploadRequestCopyWith<$Res>  {
  factory $CompletePhotoUploadRequestCopyWith(CompletePhotoUploadRequest value, $Res Function(CompletePhotoUploadRequest) _then) = _$CompletePhotoUploadRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_) int? byteSize
});




}
/// @nodoc
class _$CompletePhotoUploadRequestCopyWithImpl<$Res>
    implements $CompletePhotoUploadRequestCopyWith<$Res> {
  _$CompletePhotoUploadRequestCopyWithImpl(this._self, this._then);

  final CompletePhotoUploadRequest _self;
  final $Res Function(CompletePhotoUploadRequest) _then;

/// Create a copy of CompletePhotoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byteSize = freezed,}) {
  return _then(_self.copyWith(
byteSize: freezed == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompletePhotoUploadRequest].
extension CompletePhotoUploadRequestPatterns on CompletePhotoUploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompletePhotoUploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompletePhotoUploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompletePhotoUploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _CompletePhotoUploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompletePhotoUploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CompletePhotoUploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_)  int? byteSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompletePhotoUploadRequest() when $default != null:
return $default(_that.byteSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_)  int? byteSize)  $default,) {final _that = this;
switch (_that) {
case _CompletePhotoUploadRequest():
return $default(_that.byteSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_)  int? byteSize)?  $default,) {final _that = this;
switch (_that) {
case _CompletePhotoUploadRequest() when $default != null:
return $default(_that.byteSize);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CompletePhotoUploadRequest extends CompletePhotoUploadRequest {
  const _CompletePhotoUploadRequest({@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_) this.byteSize}): super._();
  factory _CompletePhotoUploadRequest.fromJson(Map<String, dynamic> json) => _$CompletePhotoUploadRequestFromJson(json);

/// byteSize
@override@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_) final  int? byteSize;

/// Create a copy of CompletePhotoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompletePhotoUploadRequestCopyWith<_CompletePhotoUploadRequest> get copyWith => __$CompletePhotoUploadRequestCopyWithImpl<_CompletePhotoUploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompletePhotoUploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompletePhotoUploadRequest&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,byteSize);

@override
String toString() {
  return 'CompletePhotoUploadRequest(byteSize: $byteSize)';
}


}

/// @nodoc
abstract mixin class _$CompletePhotoUploadRequestCopyWith<$Res> implements $CompletePhotoUploadRequestCopyWith<$Res> {
  factory _$CompletePhotoUploadRequestCopyWith(_CompletePhotoUploadRequest value, $Res Function(_CompletePhotoUploadRequest) _then) = __$CompletePhotoUploadRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_) int? byteSize
});




}
/// @nodoc
class __$CompletePhotoUploadRequestCopyWithImpl<$Res>
    implements _$CompletePhotoUploadRequestCopyWith<$Res> {
  __$CompletePhotoUploadRequestCopyWithImpl(this._self, this._then);

  final _CompletePhotoUploadRequest _self;
  final $Res Function(_CompletePhotoUploadRequest) _then;

/// Create a copy of CompletePhotoUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byteSize = freezed,}) {
  return _then(_CompletePhotoUploadRequest(
byteSize: freezed == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
