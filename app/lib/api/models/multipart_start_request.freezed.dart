// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multipart_start_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultipartStartRequest {

/// byteSize
@JsonKey(name: MultipartStartRequest.byteSizeKey_) int get byteSize;
/// Create a copy of MultipartStartRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipartStartRequestCopyWith<MultipartStartRequest> get copyWith => _$MultipartStartRequestCopyWithImpl<MultipartStartRequest>(this as MultipartStartRequest, _$identity);

  /// Serializes this MultipartStartRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipartStartRequest&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,byteSize);

@override
String toString() {
  return 'MultipartStartRequest(byteSize: $byteSize)';
}


}

/// @nodoc
abstract mixin class $MultipartStartRequestCopyWith<$Res>  {
  factory $MultipartStartRequestCopyWith(MultipartStartRequest value, $Res Function(MultipartStartRequest) _then) = _$MultipartStartRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MultipartStartRequest.byteSizeKey_) int byteSize
});




}
/// @nodoc
class _$MultipartStartRequestCopyWithImpl<$Res>
    implements $MultipartStartRequestCopyWith<$Res> {
  _$MultipartStartRequestCopyWithImpl(this._self, this._then);

  final MultipartStartRequest _self;
  final $Res Function(MultipartStartRequest) _then;

/// Create a copy of MultipartStartRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byteSize = null,}) {
  return _then(_self.copyWith(
byteSize: null == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MultipartStartRequest].
extension MultipartStartRequestPatterns on MultipartStartRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultipartStartRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultipartStartRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultipartStartRequest value)  $default,){
final _that = this;
switch (_that) {
case _MultipartStartRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultipartStartRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MultipartStartRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartStartRequest.byteSizeKey_)  int byteSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultipartStartRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartStartRequest.byteSizeKey_)  int byteSize)  $default,) {final _that = this;
switch (_that) {
case _MultipartStartRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MultipartStartRequest.byteSizeKey_)  int byteSize)?  $default,) {final _that = this;
switch (_that) {
case _MultipartStartRequest() when $default != null:
return $default(_that.byteSize);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MultipartStartRequest extends MultipartStartRequest {
  const _MultipartStartRequest({@JsonKey(name: MultipartStartRequest.byteSizeKey_) required this.byteSize}): super._();
  factory _MultipartStartRequest.fromJson(Map<String, dynamic> json) => _$MultipartStartRequestFromJson(json);

/// byteSize
@override@JsonKey(name: MultipartStartRequest.byteSizeKey_) final  int byteSize;

/// Create a copy of MultipartStartRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultipartStartRequestCopyWith<_MultipartStartRequest> get copyWith => __$MultipartStartRequestCopyWithImpl<_MultipartStartRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipartStartRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultipartStartRequest&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,byteSize);

@override
String toString() {
  return 'MultipartStartRequest(byteSize: $byteSize)';
}


}

/// @nodoc
abstract mixin class _$MultipartStartRequestCopyWith<$Res> implements $MultipartStartRequestCopyWith<$Res> {
  factory _$MultipartStartRequestCopyWith(_MultipartStartRequest value, $Res Function(_MultipartStartRequest) _then) = __$MultipartStartRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MultipartStartRequest.byteSizeKey_) int byteSize
});




}
/// @nodoc
class __$MultipartStartRequestCopyWithImpl<$Res>
    implements _$MultipartStartRequestCopyWith<$Res> {
  __$MultipartStartRequestCopyWithImpl(this._self, this._then);

  final _MultipartStartRequest _self;
  final $Res Function(_MultipartStartRequest) _then;

/// Create a copy of MultipartStartRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byteSize = null,}) {
  return _then(_MultipartStartRequest(
byteSize: null == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
