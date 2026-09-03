// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadPayload {

/// method
@JsonKey(name: UploadPayload.methodKey_) String get method;/// url
@JsonKey(name: UploadPayload.urlKey_) String get url;/// headers
@JsonKey(name: UploadPayload.headersKey_) Map<String, dynamic>? get headers;/// storageKey
@JsonKey(name: UploadPayload.storageKeyKey_) String get storageKey;/// expiresIn
@JsonKey(name: UploadPayload.expiresInKey_) int get expiresIn;
/// Create a copy of UploadPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadPayloadCopyWith<UploadPayload> get copyWith => _$UploadPayloadCopyWithImpl<UploadPayload>(this as UploadPayload, _$identity);

  /// Serializes this UploadPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadPayload&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.headers, headers)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(headers),storageKey,expiresIn);

@override
String toString() {
  return 'UploadPayload(method: $method, url: $url, headers: $headers, storageKey: $storageKey, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $UploadPayloadCopyWith<$Res>  {
  factory $UploadPayloadCopyWith(UploadPayload value, $Res Function(UploadPayload) _then) = _$UploadPayloadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UploadPayload.methodKey_) String method,@JsonKey(name: UploadPayload.urlKey_) String url,@JsonKey(name: UploadPayload.headersKey_) Map<String, dynamic>? headers,@JsonKey(name: UploadPayload.storageKeyKey_) String storageKey,@JsonKey(name: UploadPayload.expiresInKey_) int expiresIn
});




}
/// @nodoc
class _$UploadPayloadCopyWithImpl<$Res>
    implements $UploadPayloadCopyWith<$Res> {
  _$UploadPayloadCopyWithImpl(this._self, this._then);

  final UploadPayload _self;
  final $Res Function(UploadPayload) _then;

/// Create a copy of UploadPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? url = null,Object? headers = freezed,Object? storageKey = null,Object? expiresIn = null,}) {
  return _then(_self.copyWith(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,storageKey: null == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadPayload].
extension UploadPayloadPatterns on UploadPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadPayload value)  $default,){
final _that = this;
switch (_that) {
case _UploadPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadPayload value)?  $default,){
final _that = this;
switch (_that) {
case _UploadPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UploadPayload.methodKey_)  String method, @JsonKey(name: UploadPayload.urlKey_)  String url, @JsonKey(name: UploadPayload.headersKey_)  Map<String, dynamic>? headers, @JsonKey(name: UploadPayload.storageKeyKey_)  String storageKey, @JsonKey(name: UploadPayload.expiresInKey_)  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadPayload() when $default != null:
return $default(_that.method,_that.url,_that.headers,_that.storageKey,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UploadPayload.methodKey_)  String method, @JsonKey(name: UploadPayload.urlKey_)  String url, @JsonKey(name: UploadPayload.headersKey_)  Map<String, dynamic>? headers, @JsonKey(name: UploadPayload.storageKeyKey_)  String storageKey, @JsonKey(name: UploadPayload.expiresInKey_)  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _UploadPayload():
return $default(_that.method,_that.url,_that.headers,_that.storageKey,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UploadPayload.methodKey_)  String method, @JsonKey(name: UploadPayload.urlKey_)  String url, @JsonKey(name: UploadPayload.headersKey_)  Map<String, dynamic>? headers, @JsonKey(name: UploadPayload.storageKeyKey_)  String storageKey, @JsonKey(name: UploadPayload.expiresInKey_)  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _UploadPayload() when $default != null:
return $default(_that.method,_that.url,_that.headers,_that.storageKey,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UploadPayload extends UploadPayload {
  const _UploadPayload({@JsonKey(name: UploadPayload.methodKey_) required this.method, @JsonKey(name: UploadPayload.urlKey_) required this.url, @JsonKey(name: UploadPayload.headersKey_) final  Map<String, dynamic>? headers, @JsonKey(name: UploadPayload.storageKeyKey_) required this.storageKey, @JsonKey(name: UploadPayload.expiresInKey_) required this.expiresIn}): _headers = headers,super._();
  factory _UploadPayload.fromJson(Map<String, dynamic> json) => _$UploadPayloadFromJson(json);

/// method
@override@JsonKey(name: UploadPayload.methodKey_) final  String method;
/// url
@override@JsonKey(name: UploadPayload.urlKey_) final  String url;
/// headers
 final  Map<String, dynamic>? _headers;
/// headers
@override@JsonKey(name: UploadPayload.headersKey_) Map<String, dynamic>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// storageKey
@override@JsonKey(name: UploadPayload.storageKeyKey_) final  String storageKey;
/// expiresIn
@override@JsonKey(name: UploadPayload.expiresInKey_) final  int expiresIn;

/// Create a copy of UploadPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadPayloadCopyWith<_UploadPayload> get copyWith => __$UploadPayloadCopyWithImpl<_UploadPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadPayload&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._headers, _headers)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(_headers),storageKey,expiresIn);

@override
String toString() {
  return 'UploadPayload(method: $method, url: $url, headers: $headers, storageKey: $storageKey, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$UploadPayloadCopyWith<$Res> implements $UploadPayloadCopyWith<$Res> {
  factory _$UploadPayloadCopyWith(_UploadPayload value, $Res Function(_UploadPayload) _then) = __$UploadPayloadCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UploadPayload.methodKey_) String method,@JsonKey(name: UploadPayload.urlKey_) String url,@JsonKey(name: UploadPayload.headersKey_) Map<String, dynamic>? headers,@JsonKey(name: UploadPayload.storageKeyKey_) String storageKey,@JsonKey(name: UploadPayload.expiresInKey_) int expiresIn
});




}
/// @nodoc
class __$UploadPayloadCopyWithImpl<$Res>
    implements _$UploadPayloadCopyWith<$Res> {
  __$UploadPayloadCopyWithImpl(this._self, this._then);

  final _UploadPayload _self;
  final $Res Function(_UploadPayload) _then;

/// Create a copy of UploadPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? url = null,Object? headers = freezed,Object? storageKey = null,Object? expiresIn = null,}) {
  return _then(_UploadPayload(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,storageKey: null == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
