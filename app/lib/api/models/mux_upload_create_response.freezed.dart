// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mux_upload_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuxUploadCreateResponse {

/// mediaAssetId
@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_) String get mediaAssetId;/// mux
@JsonKey(name: MuxUploadCreateResponse.muxKey_) MuxPayload get mux;
/// Create a copy of MuxUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuxUploadCreateResponseCopyWith<MuxUploadCreateResponse> get copyWith => _$MuxUploadCreateResponseCopyWithImpl<MuxUploadCreateResponse>(this as MuxUploadCreateResponse, _$identity);

  /// Serializes this MuxUploadCreateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuxUploadCreateResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.mux, mux) || other.mux == mux));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,mux);

@override
String toString() {
  return 'MuxUploadCreateResponse(mediaAssetId: $mediaAssetId, mux: $mux)';
}


}

/// @nodoc
abstract mixin class $MuxUploadCreateResponseCopyWith<$Res>  {
  factory $MuxUploadCreateResponseCopyWith(MuxUploadCreateResponse value, $Res Function(MuxUploadCreateResponse) _then) = _$MuxUploadCreateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MuxUploadCreateResponse.muxKey_) MuxPayload mux
});


$MuxPayloadCopyWith<$Res> get mux;

}
/// @nodoc
class _$MuxUploadCreateResponseCopyWithImpl<$Res>
    implements $MuxUploadCreateResponseCopyWith<$Res> {
  _$MuxUploadCreateResponseCopyWithImpl(this._self, this._then);

  final MuxUploadCreateResponse _self;
  final $Res Function(MuxUploadCreateResponse) _then;

/// Create a copy of MuxUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? mux = null,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,mux: null == mux ? _self.mux : mux // ignore: cast_nullable_to_non_nullable
as MuxPayload,
  ));
}
/// Create a copy of MuxUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MuxPayloadCopyWith<$Res> get mux {
  
  return $MuxPayloadCopyWith<$Res>(_self.mux, (value) {
    return _then(_self.copyWith(mux: value));
  });
}
}


/// Adds pattern-matching-related methods to [MuxUploadCreateResponse].
extension MuxUploadCreateResponsePatterns on MuxUploadCreateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuxUploadCreateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuxUploadCreateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuxUploadCreateResponse value)  $default,){
final _that = this;
switch (_that) {
case _MuxUploadCreateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuxUploadCreateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MuxUploadCreateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MuxUploadCreateResponse.muxKey_)  MuxPayload mux)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuxUploadCreateResponse() when $default != null:
return $default(_that.mediaAssetId,_that.mux);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MuxUploadCreateResponse.muxKey_)  MuxPayload mux)  $default,) {final _that = this;
switch (_that) {
case _MuxUploadCreateResponse():
return $default(_that.mediaAssetId,_that.mux);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MuxUploadCreateResponse.muxKey_)  MuxPayload mux)?  $default,) {final _that = this;
switch (_that) {
case _MuxUploadCreateResponse() when $default != null:
return $default(_that.mediaAssetId,_that.mux);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MuxUploadCreateResponse extends MuxUploadCreateResponse {
  const _MuxUploadCreateResponse({@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: MuxUploadCreateResponse.muxKey_) required this.mux}): super._();
  factory _MuxUploadCreateResponse.fromJson(Map<String, dynamic> json) => _$MuxUploadCreateResponseFromJson(json);

/// mediaAssetId
@override@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_) final  String mediaAssetId;
/// mux
@override@JsonKey(name: MuxUploadCreateResponse.muxKey_) final  MuxPayload mux;

/// Create a copy of MuxUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuxUploadCreateResponseCopyWith<_MuxUploadCreateResponse> get copyWith => __$MuxUploadCreateResponseCopyWithImpl<_MuxUploadCreateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuxUploadCreateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuxUploadCreateResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.mux, mux) || other.mux == mux));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,mux);

@override
String toString() {
  return 'MuxUploadCreateResponse(mediaAssetId: $mediaAssetId, mux: $mux)';
}


}

/// @nodoc
abstract mixin class _$MuxUploadCreateResponseCopyWith<$Res> implements $MuxUploadCreateResponseCopyWith<$Res> {
  factory _$MuxUploadCreateResponseCopyWith(_MuxUploadCreateResponse value, $Res Function(_MuxUploadCreateResponse) _then) = __$MuxUploadCreateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MuxUploadCreateResponse.muxKey_) MuxPayload mux
});


@override $MuxPayloadCopyWith<$Res> get mux;

}
/// @nodoc
class __$MuxUploadCreateResponseCopyWithImpl<$Res>
    implements _$MuxUploadCreateResponseCopyWith<$Res> {
  __$MuxUploadCreateResponseCopyWithImpl(this._self, this._then);

  final _MuxUploadCreateResponse _self;
  final $Res Function(_MuxUploadCreateResponse) _then;

/// Create a copy of MuxUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? mux = null,}) {
  return _then(_MuxUploadCreateResponse(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,mux: null == mux ? _self.mux : mux // ignore: cast_nullable_to_non_nullable
as MuxPayload,
  ));
}

/// Create a copy of MuxUploadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MuxPayloadCopyWith<$Res> get mux {
  
  return $MuxPayloadCopyWith<$Res>(_self.mux, (value) {
    return _then(_self.copyWith(mux: value));
  });
}
}

// dart format on
