// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multipart_parts_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultipartPartsResponse {

/// partSize
@JsonKey(name: MultipartPartsResponse.partSizeKey_) int get partSize;/// partCount
@JsonKey(name: MultipartPartsResponse.partCountKey_) int get partCount;/// parts
@JsonKey(name: MultipartPartsResponse.partsKey_) List<MultipartPartView> get parts;
/// Create a copy of MultipartPartsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipartPartsResponseCopyWith<MultipartPartsResponse> get copyWith => _$MultipartPartsResponseCopyWithImpl<MultipartPartsResponse>(this as MultipartPartsResponse, _$identity);

  /// Serializes this MultipartPartsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipartPartsResponse&&(identical(other.partSize, partSize) || other.partSize == partSize)&&(identical(other.partCount, partCount) || other.partCount == partCount)&&const DeepCollectionEquality().equals(other.parts, parts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partSize,partCount,const DeepCollectionEquality().hash(parts));

@override
String toString() {
  return 'MultipartPartsResponse(partSize: $partSize, partCount: $partCount, parts: $parts)';
}


}

/// @nodoc
abstract mixin class $MultipartPartsResponseCopyWith<$Res>  {
  factory $MultipartPartsResponseCopyWith(MultipartPartsResponse value, $Res Function(MultipartPartsResponse) _then) = _$MultipartPartsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MultipartPartsResponse.partSizeKey_) int partSize,@JsonKey(name: MultipartPartsResponse.partCountKey_) int partCount,@JsonKey(name: MultipartPartsResponse.partsKey_) List<MultipartPartView> parts
});




}
/// @nodoc
class _$MultipartPartsResponseCopyWithImpl<$Res>
    implements $MultipartPartsResponseCopyWith<$Res> {
  _$MultipartPartsResponseCopyWithImpl(this._self, this._then);

  final MultipartPartsResponse _self;
  final $Res Function(MultipartPartsResponse) _then;

/// Create a copy of MultipartPartsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partSize = null,Object? partCount = null,Object? parts = null,}) {
  return _then(_self.copyWith(
partSize: null == partSize ? _self.partSize : partSize // ignore: cast_nullable_to_non_nullable
as int,partCount: null == partCount ? _self.partCount : partCount // ignore: cast_nullable_to_non_nullable
as int,parts: null == parts ? _self.parts : parts // ignore: cast_nullable_to_non_nullable
as List<MultipartPartView>,
  ));
}

}


/// Adds pattern-matching-related methods to [MultipartPartsResponse].
extension MultipartPartsResponsePatterns on MultipartPartsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultipartPartsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultipartPartsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultipartPartsResponse value)  $default,){
final _that = this;
switch (_that) {
case _MultipartPartsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultipartPartsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MultipartPartsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartsResponse.partSizeKey_)  int partSize, @JsonKey(name: MultipartPartsResponse.partCountKey_)  int partCount, @JsonKey(name: MultipartPartsResponse.partsKey_)  List<MultipartPartView> parts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultipartPartsResponse() when $default != null:
return $default(_that.partSize,_that.partCount,_that.parts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartsResponse.partSizeKey_)  int partSize, @JsonKey(name: MultipartPartsResponse.partCountKey_)  int partCount, @JsonKey(name: MultipartPartsResponse.partsKey_)  List<MultipartPartView> parts)  $default,) {final _that = this;
switch (_that) {
case _MultipartPartsResponse():
return $default(_that.partSize,_that.partCount,_that.parts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MultipartPartsResponse.partSizeKey_)  int partSize, @JsonKey(name: MultipartPartsResponse.partCountKey_)  int partCount, @JsonKey(name: MultipartPartsResponse.partsKey_)  List<MultipartPartView> parts)?  $default,) {final _that = this;
switch (_that) {
case _MultipartPartsResponse() when $default != null:
return $default(_that.partSize,_that.partCount,_that.parts);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MultipartPartsResponse extends MultipartPartsResponse {
  const _MultipartPartsResponse({@JsonKey(name: MultipartPartsResponse.partSizeKey_) required this.partSize, @JsonKey(name: MultipartPartsResponse.partCountKey_) required this.partCount, @JsonKey(name: MultipartPartsResponse.partsKey_) required final  List<MultipartPartView> parts}): _parts = parts,super._();
  factory _MultipartPartsResponse.fromJson(Map<String, dynamic> json) => _$MultipartPartsResponseFromJson(json);

/// partSize
@override@JsonKey(name: MultipartPartsResponse.partSizeKey_) final  int partSize;
/// partCount
@override@JsonKey(name: MultipartPartsResponse.partCountKey_) final  int partCount;
/// parts
 final  List<MultipartPartView> _parts;
/// parts
@override@JsonKey(name: MultipartPartsResponse.partsKey_) List<MultipartPartView> get parts {
  if (_parts is EqualUnmodifiableListView) return _parts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parts);
}


/// Create a copy of MultipartPartsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultipartPartsResponseCopyWith<_MultipartPartsResponse> get copyWith => __$MultipartPartsResponseCopyWithImpl<_MultipartPartsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipartPartsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultipartPartsResponse&&(identical(other.partSize, partSize) || other.partSize == partSize)&&(identical(other.partCount, partCount) || other.partCount == partCount)&&const DeepCollectionEquality().equals(other._parts, _parts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partSize,partCount,const DeepCollectionEquality().hash(_parts));

@override
String toString() {
  return 'MultipartPartsResponse(partSize: $partSize, partCount: $partCount, parts: $parts)';
}


}

/// @nodoc
abstract mixin class _$MultipartPartsResponseCopyWith<$Res> implements $MultipartPartsResponseCopyWith<$Res> {
  factory _$MultipartPartsResponseCopyWith(_MultipartPartsResponse value, $Res Function(_MultipartPartsResponse) _then) = __$MultipartPartsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MultipartPartsResponse.partSizeKey_) int partSize,@JsonKey(name: MultipartPartsResponse.partCountKey_) int partCount,@JsonKey(name: MultipartPartsResponse.partsKey_) List<MultipartPartView> parts
});




}
/// @nodoc
class __$MultipartPartsResponseCopyWithImpl<$Res>
    implements _$MultipartPartsResponseCopyWith<$Res> {
  __$MultipartPartsResponseCopyWithImpl(this._self, this._then);

  final _MultipartPartsResponse _self;
  final $Res Function(_MultipartPartsResponse) _then;

/// Create a copy of MultipartPartsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partSize = null,Object? partCount = null,Object? parts = null,}) {
  return _then(_MultipartPartsResponse(
partSize: null == partSize ? _self.partSize : partSize // ignore: cast_nullable_to_non_nullable
as int,partCount: null == partCount ? _self.partCount : partCount // ignore: cast_nullable_to_non_nullable
as int,parts: null == parts ? _self._parts : parts // ignore: cast_nullable_to_non_nullable
as List<MultipartPartView>,
  ));
}


}

// dart format on
