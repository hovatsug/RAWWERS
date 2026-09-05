// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mux_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuxPayload {

/// directUploadId
@JsonKey(name: MuxPayload.directUploadIdKey_) String get directUploadId;/// uploadUrl
@JsonKey(name: MuxPayload.uploadUrlKey_) String get uploadUrl;/// expiresIn
@JsonKey(name: MuxPayload.expiresInKey_) int? get expiresIn;
/// Create a copy of MuxPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuxPayloadCopyWith<MuxPayload> get copyWith => _$MuxPayloadCopyWithImpl<MuxPayload>(this as MuxPayload, _$identity);

  /// Serializes this MuxPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuxPayload&&(identical(other.directUploadId, directUploadId) || other.directUploadId == directUploadId)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,directUploadId,uploadUrl,expiresIn);

@override
String toString() {
  return 'MuxPayload(directUploadId: $directUploadId, uploadUrl: $uploadUrl, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $MuxPayloadCopyWith<$Res>  {
  factory $MuxPayloadCopyWith(MuxPayload value, $Res Function(MuxPayload) _then) = _$MuxPayloadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MuxPayload.directUploadIdKey_) String directUploadId,@JsonKey(name: MuxPayload.uploadUrlKey_) String uploadUrl,@JsonKey(name: MuxPayload.expiresInKey_) int? expiresIn
});




}
/// @nodoc
class _$MuxPayloadCopyWithImpl<$Res>
    implements $MuxPayloadCopyWith<$Res> {
  _$MuxPayloadCopyWithImpl(this._self, this._then);

  final MuxPayload _self;
  final $Res Function(MuxPayload) _then;

/// Create a copy of MuxPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? directUploadId = null,Object? uploadUrl = null,Object? expiresIn = freezed,}) {
  return _then(_self.copyWith(
directUploadId: null == directUploadId ? _self.directUploadId : directUploadId // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MuxPayload].
extension MuxPayloadPatterns on MuxPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuxPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuxPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuxPayload value)  $default,){
final _that = this;
switch (_that) {
case _MuxPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuxPayload value)?  $default,){
final _that = this;
switch (_that) {
case _MuxPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MuxPayload.directUploadIdKey_)  String directUploadId, @JsonKey(name: MuxPayload.uploadUrlKey_)  String uploadUrl, @JsonKey(name: MuxPayload.expiresInKey_)  int? expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuxPayload() when $default != null:
return $default(_that.directUploadId,_that.uploadUrl,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MuxPayload.directUploadIdKey_)  String directUploadId, @JsonKey(name: MuxPayload.uploadUrlKey_)  String uploadUrl, @JsonKey(name: MuxPayload.expiresInKey_)  int? expiresIn)  $default,) {final _that = this;
switch (_that) {
case _MuxPayload():
return $default(_that.directUploadId,_that.uploadUrl,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MuxPayload.directUploadIdKey_)  String directUploadId, @JsonKey(name: MuxPayload.uploadUrlKey_)  String uploadUrl, @JsonKey(name: MuxPayload.expiresInKey_)  int? expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _MuxPayload() when $default != null:
return $default(_that.directUploadId,_that.uploadUrl,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MuxPayload extends MuxPayload {
  const _MuxPayload({@JsonKey(name: MuxPayload.directUploadIdKey_) required this.directUploadId, @JsonKey(name: MuxPayload.uploadUrlKey_) required this.uploadUrl, @JsonKey(name: MuxPayload.expiresInKey_) this.expiresIn}): super._();
  factory _MuxPayload.fromJson(Map<String, dynamic> json) => _$MuxPayloadFromJson(json);

/// directUploadId
@override@JsonKey(name: MuxPayload.directUploadIdKey_) final  String directUploadId;
/// uploadUrl
@override@JsonKey(name: MuxPayload.uploadUrlKey_) final  String uploadUrl;
/// expiresIn
@override@JsonKey(name: MuxPayload.expiresInKey_) final  int? expiresIn;

/// Create a copy of MuxPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuxPayloadCopyWith<_MuxPayload> get copyWith => __$MuxPayloadCopyWithImpl<_MuxPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuxPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuxPayload&&(identical(other.directUploadId, directUploadId) || other.directUploadId == directUploadId)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,directUploadId,uploadUrl,expiresIn);

@override
String toString() {
  return 'MuxPayload(directUploadId: $directUploadId, uploadUrl: $uploadUrl, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$MuxPayloadCopyWith<$Res> implements $MuxPayloadCopyWith<$Res> {
  factory _$MuxPayloadCopyWith(_MuxPayload value, $Res Function(_MuxPayload) _then) = __$MuxPayloadCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MuxPayload.directUploadIdKey_) String directUploadId,@JsonKey(name: MuxPayload.uploadUrlKey_) String uploadUrl,@JsonKey(name: MuxPayload.expiresInKey_) int? expiresIn
});




}
/// @nodoc
class __$MuxPayloadCopyWithImpl<$Res>
    implements _$MuxPayloadCopyWith<$Res> {
  __$MuxPayloadCopyWithImpl(this._self, this._then);

  final _MuxPayload _self;
  final $Res Function(_MuxPayload) _then;

/// Create a copy of MuxPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? directUploadId = null,Object? uploadUrl = null,Object? expiresIn = freezed,}) {
  return _then(_MuxPayload(
directUploadId: null == directUploadId ? _self.directUploadId : directUploadId // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
