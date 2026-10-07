// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multipart_part_url.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultipartPartUrl {

/// partNumber
@JsonKey(name: MultipartPartUrl.partNumberKey_) int get partNumber;/// url
@JsonKey(name: MultipartPartUrl.urlKey_) String get url;
/// Create a copy of MultipartPartUrl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipartPartUrlCopyWith<MultipartPartUrl> get copyWith => _$MultipartPartUrlCopyWithImpl<MultipartPartUrl>(this as MultipartPartUrl, _$identity);

  /// Serializes this MultipartPartUrl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipartPartUrl&&(identical(other.partNumber, partNumber) || other.partNumber == partNumber)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partNumber,url);

@override
String toString() {
  return 'MultipartPartUrl(partNumber: $partNumber, url: $url)';
}


}

/// @nodoc
abstract mixin class $MultipartPartUrlCopyWith<$Res>  {
  factory $MultipartPartUrlCopyWith(MultipartPartUrl value, $Res Function(MultipartPartUrl) _then) = _$MultipartPartUrlCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MultipartPartUrl.partNumberKey_) int partNumber,@JsonKey(name: MultipartPartUrl.urlKey_) String url
});




}
/// @nodoc
class _$MultipartPartUrlCopyWithImpl<$Res>
    implements $MultipartPartUrlCopyWith<$Res> {
  _$MultipartPartUrlCopyWithImpl(this._self, this._then);

  final MultipartPartUrl _self;
  final $Res Function(MultipartPartUrl) _then;

/// Create a copy of MultipartPartUrl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partNumber = null,Object? url = null,}) {
  return _then(_self.copyWith(
partNumber: null == partNumber ? _self.partNumber : partNumber // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MultipartPartUrl].
extension MultipartPartUrlPatterns on MultipartPartUrl {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultipartPartUrl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultipartPartUrl() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultipartPartUrl value)  $default,){
final _that = this;
switch (_that) {
case _MultipartPartUrl():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultipartPartUrl value)?  $default,){
final _that = this;
switch (_that) {
case _MultipartPartUrl() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartUrl.partNumberKey_)  int partNumber, @JsonKey(name: MultipartPartUrl.urlKey_)  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultipartPartUrl() when $default != null:
return $default(_that.partNumber,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartUrl.partNumberKey_)  int partNumber, @JsonKey(name: MultipartPartUrl.urlKey_)  String url)  $default,) {final _that = this;
switch (_that) {
case _MultipartPartUrl():
return $default(_that.partNumber,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MultipartPartUrl.partNumberKey_)  int partNumber, @JsonKey(name: MultipartPartUrl.urlKey_)  String url)?  $default,) {final _that = this;
switch (_that) {
case _MultipartPartUrl() when $default != null:
return $default(_that.partNumber,_that.url);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MultipartPartUrl extends MultipartPartUrl {
  const _MultipartPartUrl({@JsonKey(name: MultipartPartUrl.partNumberKey_) required this.partNumber, @JsonKey(name: MultipartPartUrl.urlKey_) required this.url}): super._();
  factory _MultipartPartUrl.fromJson(Map<String, dynamic> json) => _$MultipartPartUrlFromJson(json);

/// partNumber
@override@JsonKey(name: MultipartPartUrl.partNumberKey_) final  int partNumber;
/// url
@override@JsonKey(name: MultipartPartUrl.urlKey_) final  String url;

/// Create a copy of MultipartPartUrl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultipartPartUrlCopyWith<_MultipartPartUrl> get copyWith => __$MultipartPartUrlCopyWithImpl<_MultipartPartUrl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipartPartUrlToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultipartPartUrl&&(identical(other.partNumber, partNumber) || other.partNumber == partNumber)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partNumber,url);

@override
String toString() {
  return 'MultipartPartUrl(partNumber: $partNumber, url: $url)';
}


}

/// @nodoc
abstract mixin class _$MultipartPartUrlCopyWith<$Res> implements $MultipartPartUrlCopyWith<$Res> {
  factory _$MultipartPartUrlCopyWith(_MultipartPartUrl value, $Res Function(_MultipartPartUrl) _then) = __$MultipartPartUrlCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MultipartPartUrl.partNumberKey_) int partNumber,@JsonKey(name: MultipartPartUrl.urlKey_) String url
});




}
/// @nodoc
class __$MultipartPartUrlCopyWithImpl<$Res>
    implements _$MultipartPartUrlCopyWith<$Res> {
  __$MultipartPartUrlCopyWithImpl(this._self, this._then);

  final _MultipartPartUrl _self;
  final $Res Function(_MultipartPartUrl) _then;

/// Create a copy of MultipartPartUrl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partNumber = null,Object? url = null,}) {
  return _then(_MultipartPartUrl(
partNumber: null == partNumber ? _self.partNumber : partNumber // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
