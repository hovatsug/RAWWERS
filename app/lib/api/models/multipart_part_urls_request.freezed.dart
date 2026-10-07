// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multipart_part_urls_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultipartPartUrlsRequest {

/// partNumbers
@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_) List<int> get partNumbers;
/// Create a copy of MultipartPartUrlsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipartPartUrlsRequestCopyWith<MultipartPartUrlsRequest> get copyWith => _$MultipartPartUrlsRequestCopyWithImpl<MultipartPartUrlsRequest>(this as MultipartPartUrlsRequest, _$identity);

  /// Serializes this MultipartPartUrlsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipartPartUrlsRequest&&const DeepCollectionEquality().equals(other.partNumbers, partNumbers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(partNumbers));

@override
String toString() {
  return 'MultipartPartUrlsRequest(partNumbers: $partNumbers)';
}


}

/// @nodoc
abstract mixin class $MultipartPartUrlsRequestCopyWith<$Res>  {
  factory $MultipartPartUrlsRequestCopyWith(MultipartPartUrlsRequest value, $Res Function(MultipartPartUrlsRequest) _then) = _$MultipartPartUrlsRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_) List<int> partNumbers
});




}
/// @nodoc
class _$MultipartPartUrlsRequestCopyWithImpl<$Res>
    implements $MultipartPartUrlsRequestCopyWith<$Res> {
  _$MultipartPartUrlsRequestCopyWithImpl(this._self, this._then);

  final MultipartPartUrlsRequest _self;
  final $Res Function(MultipartPartUrlsRequest) _then;

/// Create a copy of MultipartPartUrlsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partNumbers = null,}) {
  return _then(_self.copyWith(
partNumbers: null == partNumbers ? _self.partNumbers : partNumbers // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [MultipartPartUrlsRequest].
extension MultipartPartUrlsRequestPatterns on MultipartPartUrlsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultipartPartUrlsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultipartPartUrlsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultipartPartUrlsRequest value)  $default,){
final _that = this;
switch (_that) {
case _MultipartPartUrlsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultipartPartUrlsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MultipartPartUrlsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_)  List<int> partNumbers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultipartPartUrlsRequest() when $default != null:
return $default(_that.partNumbers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_)  List<int> partNumbers)  $default,) {final _that = this;
switch (_that) {
case _MultipartPartUrlsRequest():
return $default(_that.partNumbers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_)  List<int> partNumbers)?  $default,) {final _that = this;
switch (_that) {
case _MultipartPartUrlsRequest() when $default != null:
return $default(_that.partNumbers);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MultipartPartUrlsRequest extends MultipartPartUrlsRequest {
  const _MultipartPartUrlsRequest({@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_) required final  List<int> partNumbers}): _partNumbers = partNumbers,super._();
  factory _MultipartPartUrlsRequest.fromJson(Map<String, dynamic> json) => _$MultipartPartUrlsRequestFromJson(json);

/// partNumbers
 final  List<int> _partNumbers;
/// partNumbers
@override@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_) List<int> get partNumbers {
  if (_partNumbers is EqualUnmodifiableListView) return _partNumbers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_partNumbers);
}


/// Create a copy of MultipartPartUrlsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultipartPartUrlsRequestCopyWith<_MultipartPartUrlsRequest> get copyWith => __$MultipartPartUrlsRequestCopyWithImpl<_MultipartPartUrlsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipartPartUrlsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultipartPartUrlsRequest&&const DeepCollectionEquality().equals(other._partNumbers, _partNumbers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_partNumbers));

@override
String toString() {
  return 'MultipartPartUrlsRequest(partNumbers: $partNumbers)';
}


}

/// @nodoc
abstract mixin class _$MultipartPartUrlsRequestCopyWith<$Res> implements $MultipartPartUrlsRequestCopyWith<$Res> {
  factory _$MultipartPartUrlsRequestCopyWith(_MultipartPartUrlsRequest value, $Res Function(_MultipartPartUrlsRequest) _then) = __$MultipartPartUrlsRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_) List<int> partNumbers
});




}
/// @nodoc
class __$MultipartPartUrlsRequestCopyWithImpl<$Res>
    implements _$MultipartPartUrlsRequestCopyWith<$Res> {
  __$MultipartPartUrlsRequestCopyWithImpl(this._self, this._then);

  final _MultipartPartUrlsRequest _self;
  final $Res Function(_MultipartPartUrlsRequest) _then;

/// Create a copy of MultipartPartUrlsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partNumbers = null,}) {
  return _then(_MultipartPartUrlsRequest(
partNumbers: null == partNumbers ? _self._partNumbers : partNumbers // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
