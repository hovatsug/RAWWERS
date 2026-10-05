// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gear_frame_submit_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GearFrameSubmitRequest {

/// evidenceMediaAssetId
@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_) String get evidenceMediaAssetId;
/// Create a copy of GearFrameSubmitRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GearFrameSubmitRequestCopyWith<GearFrameSubmitRequest> get copyWith => _$GearFrameSubmitRequestCopyWithImpl<GearFrameSubmitRequest>(this as GearFrameSubmitRequest, _$identity);

  /// Serializes this GearFrameSubmitRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GearFrameSubmitRequest&&(identical(other.evidenceMediaAssetId, evidenceMediaAssetId) || other.evidenceMediaAssetId == evidenceMediaAssetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,evidenceMediaAssetId);

@override
String toString() {
  return 'GearFrameSubmitRequest(evidenceMediaAssetId: $evidenceMediaAssetId)';
}


}

/// @nodoc
abstract mixin class $GearFrameSubmitRequestCopyWith<$Res>  {
  factory $GearFrameSubmitRequestCopyWith(GearFrameSubmitRequest value, $Res Function(GearFrameSubmitRequest) _then) = _$GearFrameSubmitRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_) String evidenceMediaAssetId
});




}
/// @nodoc
class _$GearFrameSubmitRequestCopyWithImpl<$Res>
    implements $GearFrameSubmitRequestCopyWith<$Res> {
  _$GearFrameSubmitRequestCopyWithImpl(this._self, this._then);

  final GearFrameSubmitRequest _self;
  final $Res Function(GearFrameSubmitRequest) _then;

/// Create a copy of GearFrameSubmitRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? evidenceMediaAssetId = null,}) {
  return _then(_self.copyWith(
evidenceMediaAssetId: null == evidenceMediaAssetId ? _self.evidenceMediaAssetId : evidenceMediaAssetId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GearFrameSubmitRequest].
extension GearFrameSubmitRequestPatterns on GearFrameSubmitRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GearFrameSubmitRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GearFrameSubmitRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GearFrameSubmitRequest value)  $default,){
final _that = this;
switch (_that) {
case _GearFrameSubmitRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GearFrameSubmitRequest value)?  $default,){
final _that = this;
switch (_that) {
case _GearFrameSubmitRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_)  String evidenceMediaAssetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GearFrameSubmitRequest() when $default != null:
return $default(_that.evidenceMediaAssetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_)  String evidenceMediaAssetId)  $default,) {final _that = this;
switch (_that) {
case _GearFrameSubmitRequest():
return $default(_that.evidenceMediaAssetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_)  String evidenceMediaAssetId)?  $default,) {final _that = this;
switch (_that) {
case _GearFrameSubmitRequest() when $default != null:
return $default(_that.evidenceMediaAssetId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GearFrameSubmitRequest extends GearFrameSubmitRequest {
  const _GearFrameSubmitRequest({@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_) required this.evidenceMediaAssetId}): super._();
  factory _GearFrameSubmitRequest.fromJson(Map<String, dynamic> json) => _$GearFrameSubmitRequestFromJson(json);

/// evidenceMediaAssetId
@override@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_) final  String evidenceMediaAssetId;

/// Create a copy of GearFrameSubmitRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GearFrameSubmitRequestCopyWith<_GearFrameSubmitRequest> get copyWith => __$GearFrameSubmitRequestCopyWithImpl<_GearFrameSubmitRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GearFrameSubmitRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GearFrameSubmitRequest&&(identical(other.evidenceMediaAssetId, evidenceMediaAssetId) || other.evidenceMediaAssetId == evidenceMediaAssetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,evidenceMediaAssetId);

@override
String toString() {
  return 'GearFrameSubmitRequest(evidenceMediaAssetId: $evidenceMediaAssetId)';
}


}

/// @nodoc
abstract mixin class _$GearFrameSubmitRequestCopyWith<$Res> implements $GearFrameSubmitRequestCopyWith<$Res> {
  factory _$GearFrameSubmitRequestCopyWith(_GearFrameSubmitRequest value, $Res Function(_GearFrameSubmitRequest) _then) = __$GearFrameSubmitRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_) String evidenceMediaAssetId
});




}
/// @nodoc
class __$GearFrameSubmitRequestCopyWithImpl<$Res>
    implements _$GearFrameSubmitRequestCopyWith<$Res> {
  __$GearFrameSubmitRequestCopyWithImpl(this._self, this._then);

  final _GearFrameSubmitRequest _self;
  final $Res Function(_GearFrameSubmitRequest) _then;

/// Create a copy of GearFrameSubmitRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? evidenceMediaAssetId = null,}) {
  return _then(_GearFrameSubmitRequest(
evidenceMediaAssetId: null == evidenceMediaAssetId ? _self.evidenceMediaAssetId : evidenceMediaAssetId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
