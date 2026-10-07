// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multipart_part_urls_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultipartPartUrlsResponse {

/// parts
@JsonKey(name: MultipartPartUrlsResponse.partsKey_) List<MultipartPartUrl> get parts;/// expiresIn
@JsonKey(name: MultipartPartUrlsResponse.expiresInKey_) int get expiresIn;
/// Create a copy of MultipartPartUrlsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipartPartUrlsResponseCopyWith<MultipartPartUrlsResponse> get copyWith => _$MultipartPartUrlsResponseCopyWithImpl<MultipartPartUrlsResponse>(this as MultipartPartUrlsResponse, _$identity);

  /// Serializes this MultipartPartUrlsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipartPartUrlsResponse&&const DeepCollectionEquality().equals(other.parts, parts)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(parts),expiresIn);

@override
String toString() {
  return 'MultipartPartUrlsResponse(parts: $parts, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $MultipartPartUrlsResponseCopyWith<$Res>  {
  factory $MultipartPartUrlsResponseCopyWith(MultipartPartUrlsResponse value, $Res Function(MultipartPartUrlsResponse) _then) = _$MultipartPartUrlsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MultipartPartUrlsResponse.partsKey_) List<MultipartPartUrl> parts,@JsonKey(name: MultipartPartUrlsResponse.expiresInKey_) int expiresIn
});




}
/// @nodoc
class _$MultipartPartUrlsResponseCopyWithImpl<$Res>
    implements $MultipartPartUrlsResponseCopyWith<$Res> {
  _$MultipartPartUrlsResponseCopyWithImpl(this._self, this._then);

  final MultipartPartUrlsResponse _self;
  final $Res Function(MultipartPartUrlsResponse) _then;

/// Create a copy of MultipartPartUrlsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? parts = null,Object? expiresIn = null,}) {
  return _then(_self.copyWith(
parts: null == parts ? _self.parts : parts // ignore: cast_nullable_to_non_nullable
as List<MultipartPartUrl>,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MultipartPartUrlsResponse].
extension MultipartPartUrlsResponsePatterns on MultipartPartUrlsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultipartPartUrlsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultipartPartUrlsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultipartPartUrlsResponse value)  $default,){
final _that = this;
switch (_that) {
case _MultipartPartUrlsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultipartPartUrlsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MultipartPartUrlsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartUrlsResponse.partsKey_)  List<MultipartPartUrl> parts, @JsonKey(name: MultipartPartUrlsResponse.expiresInKey_)  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultipartPartUrlsResponse() when $default != null:
return $default(_that.parts,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartUrlsResponse.partsKey_)  List<MultipartPartUrl> parts, @JsonKey(name: MultipartPartUrlsResponse.expiresInKey_)  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _MultipartPartUrlsResponse():
return $default(_that.parts,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MultipartPartUrlsResponse.partsKey_)  List<MultipartPartUrl> parts, @JsonKey(name: MultipartPartUrlsResponse.expiresInKey_)  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _MultipartPartUrlsResponse() when $default != null:
return $default(_that.parts,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MultipartPartUrlsResponse extends MultipartPartUrlsResponse {
  const _MultipartPartUrlsResponse({@JsonKey(name: MultipartPartUrlsResponse.partsKey_) required final  List<MultipartPartUrl> parts, @JsonKey(name: MultipartPartUrlsResponse.expiresInKey_) required this.expiresIn}): _parts = parts,super._();
  factory _MultipartPartUrlsResponse.fromJson(Map<String, dynamic> json) => _$MultipartPartUrlsResponseFromJson(json);

/// parts
 final  List<MultipartPartUrl> _parts;
/// parts
@override@JsonKey(name: MultipartPartUrlsResponse.partsKey_) List<MultipartPartUrl> get parts {
  if (_parts is EqualUnmodifiableListView) return _parts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parts);
}

/// expiresIn
@override@JsonKey(name: MultipartPartUrlsResponse.expiresInKey_) final  int expiresIn;

/// Create a copy of MultipartPartUrlsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultipartPartUrlsResponseCopyWith<_MultipartPartUrlsResponse> get copyWith => __$MultipartPartUrlsResponseCopyWithImpl<_MultipartPartUrlsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipartPartUrlsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultipartPartUrlsResponse&&const DeepCollectionEquality().equals(other._parts, _parts)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_parts),expiresIn);

@override
String toString() {
  return 'MultipartPartUrlsResponse(parts: $parts, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$MultipartPartUrlsResponseCopyWith<$Res> implements $MultipartPartUrlsResponseCopyWith<$Res> {
  factory _$MultipartPartUrlsResponseCopyWith(_MultipartPartUrlsResponse value, $Res Function(_MultipartPartUrlsResponse) _then) = __$MultipartPartUrlsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MultipartPartUrlsResponse.partsKey_) List<MultipartPartUrl> parts,@JsonKey(name: MultipartPartUrlsResponse.expiresInKey_) int expiresIn
});




}
/// @nodoc
class __$MultipartPartUrlsResponseCopyWithImpl<$Res>
    implements _$MultipartPartUrlsResponseCopyWith<$Res> {
  __$MultipartPartUrlsResponseCopyWithImpl(this._self, this._then);

  final _MultipartPartUrlsResponse _self;
  final $Res Function(_MultipartPartUrlsResponse) _then;

/// Create a copy of MultipartPartUrlsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? parts = null,Object? expiresIn = null,}) {
  return _then(_MultipartPartUrlsResponse(
parts: null == parts ? _self._parts : parts // ignore: cast_nullable_to_non_nullable
as List<MultipartPartUrl>,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
