// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multipart_start_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultipartStartResponse {

/// partSize
@JsonKey(name: MultipartStartResponse.partSizeKey_) int get partSize;/// partCount
@JsonKey(name: MultipartStartResponse.partCountKey_) int get partCount;
/// Create a copy of MultipartStartResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipartStartResponseCopyWith<MultipartStartResponse> get copyWith => _$MultipartStartResponseCopyWithImpl<MultipartStartResponse>(this as MultipartStartResponse, _$identity);

  /// Serializes this MultipartStartResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipartStartResponse&&(identical(other.partSize, partSize) || other.partSize == partSize)&&(identical(other.partCount, partCount) || other.partCount == partCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partSize,partCount);

@override
String toString() {
  return 'MultipartStartResponse(partSize: $partSize, partCount: $partCount)';
}


}

/// @nodoc
abstract mixin class $MultipartStartResponseCopyWith<$Res>  {
  factory $MultipartStartResponseCopyWith(MultipartStartResponse value, $Res Function(MultipartStartResponse) _then) = _$MultipartStartResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MultipartStartResponse.partSizeKey_) int partSize,@JsonKey(name: MultipartStartResponse.partCountKey_) int partCount
});




}
/// @nodoc
class _$MultipartStartResponseCopyWithImpl<$Res>
    implements $MultipartStartResponseCopyWith<$Res> {
  _$MultipartStartResponseCopyWithImpl(this._self, this._then);

  final MultipartStartResponse _self;
  final $Res Function(MultipartStartResponse) _then;

/// Create a copy of MultipartStartResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partSize = null,Object? partCount = null,}) {
  return _then(_self.copyWith(
partSize: null == partSize ? _self.partSize : partSize // ignore: cast_nullable_to_non_nullable
as int,partCount: null == partCount ? _self.partCount : partCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MultipartStartResponse].
extension MultipartStartResponsePatterns on MultipartStartResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultipartStartResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultipartStartResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultipartStartResponse value)  $default,){
final _that = this;
switch (_that) {
case _MultipartStartResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultipartStartResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MultipartStartResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartStartResponse.partSizeKey_)  int partSize, @JsonKey(name: MultipartStartResponse.partCountKey_)  int partCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultipartStartResponse() when $default != null:
return $default(_that.partSize,_that.partCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartStartResponse.partSizeKey_)  int partSize, @JsonKey(name: MultipartStartResponse.partCountKey_)  int partCount)  $default,) {final _that = this;
switch (_that) {
case _MultipartStartResponse():
return $default(_that.partSize,_that.partCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MultipartStartResponse.partSizeKey_)  int partSize, @JsonKey(name: MultipartStartResponse.partCountKey_)  int partCount)?  $default,) {final _that = this;
switch (_that) {
case _MultipartStartResponse() when $default != null:
return $default(_that.partSize,_that.partCount);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MultipartStartResponse extends MultipartStartResponse {
  const _MultipartStartResponse({@JsonKey(name: MultipartStartResponse.partSizeKey_) required this.partSize, @JsonKey(name: MultipartStartResponse.partCountKey_) required this.partCount}): super._();
  factory _MultipartStartResponse.fromJson(Map<String, dynamic> json) => _$MultipartStartResponseFromJson(json);

/// partSize
@override@JsonKey(name: MultipartStartResponse.partSizeKey_) final  int partSize;
/// partCount
@override@JsonKey(name: MultipartStartResponse.partCountKey_) final  int partCount;

/// Create a copy of MultipartStartResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultipartStartResponseCopyWith<_MultipartStartResponse> get copyWith => __$MultipartStartResponseCopyWithImpl<_MultipartStartResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipartStartResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultipartStartResponse&&(identical(other.partSize, partSize) || other.partSize == partSize)&&(identical(other.partCount, partCount) || other.partCount == partCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partSize,partCount);

@override
String toString() {
  return 'MultipartStartResponse(partSize: $partSize, partCount: $partCount)';
}


}

/// @nodoc
abstract mixin class _$MultipartStartResponseCopyWith<$Res> implements $MultipartStartResponseCopyWith<$Res> {
  factory _$MultipartStartResponseCopyWith(_MultipartStartResponse value, $Res Function(_MultipartStartResponse) _then) = __$MultipartStartResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MultipartStartResponse.partSizeKey_) int partSize,@JsonKey(name: MultipartStartResponse.partCountKey_) int partCount
});




}
/// @nodoc
class __$MultipartStartResponseCopyWithImpl<$Res>
    implements _$MultipartStartResponseCopyWith<$Res> {
  __$MultipartStartResponseCopyWithImpl(this._self, this._then);

  final _MultipartStartResponse _self;
  final $Res Function(_MultipartStartResponse) _then;

/// Create a copy of MultipartStartResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partSize = null,Object? partCount = null,}) {
  return _then(_MultipartStartResponse(
partSize: null == partSize ? _self.partSize : partSize // ignore: cast_nullable_to_non_nullable
as int,partCount: null == partCount ? _self.partCount : partCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
