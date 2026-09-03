// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloads_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadsResponse {

/// galleryId
@JsonKey(name: DownloadsResponse.galleryIdKey_) String get galleryId;/// urls
@JsonKey(name: DownloadsResponse.urlsKey_) Map<String, dynamic> get urls;
/// Create a copy of DownloadsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadsResponseCopyWith<DownloadsResponse> get copyWith => _$DownloadsResponseCopyWithImpl<DownloadsResponse>(this as DownloadsResponse, _$identity);

  /// Serializes this DownloadsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadsResponse&&(identical(other.galleryId, galleryId) || other.galleryId == galleryId)&&const DeepCollectionEquality().equals(other.urls, urls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,galleryId,const DeepCollectionEquality().hash(urls));

@override
String toString() {
  return 'DownloadsResponse(galleryId: $galleryId, urls: $urls)';
}


}

/// @nodoc
abstract mixin class $DownloadsResponseCopyWith<$Res>  {
  factory $DownloadsResponseCopyWith(DownloadsResponse value, $Res Function(DownloadsResponse) _then) = _$DownloadsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DownloadsResponse.galleryIdKey_) String galleryId,@JsonKey(name: DownloadsResponse.urlsKey_) Map<String, dynamic> urls
});




}
/// @nodoc
class _$DownloadsResponseCopyWithImpl<$Res>
    implements $DownloadsResponseCopyWith<$Res> {
  _$DownloadsResponseCopyWithImpl(this._self, this._then);

  final DownloadsResponse _self;
  final $Res Function(DownloadsResponse) _then;

/// Create a copy of DownloadsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? galleryId = null,Object? urls = null,}) {
  return _then(_self.copyWith(
galleryId: null == galleryId ? _self.galleryId : galleryId // ignore: cast_nullable_to_non_nullable
as String,urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadsResponse].
extension DownloadsResponsePatterns on DownloadsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadsResponse value)  $default,){
final _that = this;
switch (_that) {
case _DownloadsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DownloadsResponse.galleryIdKey_)  String galleryId, @JsonKey(name: DownloadsResponse.urlsKey_)  Map<String, dynamic> urls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadsResponse() when $default != null:
return $default(_that.galleryId,_that.urls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DownloadsResponse.galleryIdKey_)  String galleryId, @JsonKey(name: DownloadsResponse.urlsKey_)  Map<String, dynamic> urls)  $default,) {final _that = this;
switch (_that) {
case _DownloadsResponse():
return $default(_that.galleryId,_that.urls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DownloadsResponse.galleryIdKey_)  String galleryId, @JsonKey(name: DownloadsResponse.urlsKey_)  Map<String, dynamic> urls)?  $default,) {final _that = this;
switch (_that) {
case _DownloadsResponse() when $default != null:
return $default(_that.galleryId,_that.urls);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DownloadsResponse extends DownloadsResponse {
  const _DownloadsResponse({@JsonKey(name: DownloadsResponse.galleryIdKey_) required this.galleryId, @JsonKey(name: DownloadsResponse.urlsKey_) required final  Map<String, dynamic> urls}): _urls = urls,super._();
  factory _DownloadsResponse.fromJson(Map<String, dynamic> json) => _$DownloadsResponseFromJson(json);

/// galleryId
@override@JsonKey(name: DownloadsResponse.galleryIdKey_) final  String galleryId;
/// urls
 final  Map<String, dynamic> _urls;
/// urls
@override@JsonKey(name: DownloadsResponse.urlsKey_) Map<String, dynamic> get urls {
  if (_urls is EqualUnmodifiableMapView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_urls);
}


/// Create a copy of DownloadsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadsResponseCopyWith<_DownloadsResponse> get copyWith => __$DownloadsResponseCopyWithImpl<_DownloadsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadsResponse&&(identical(other.galleryId, galleryId) || other.galleryId == galleryId)&&const DeepCollectionEquality().equals(other._urls, _urls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,galleryId,const DeepCollectionEquality().hash(_urls));

@override
String toString() {
  return 'DownloadsResponse(galleryId: $galleryId, urls: $urls)';
}


}

/// @nodoc
abstract mixin class _$DownloadsResponseCopyWith<$Res> implements $DownloadsResponseCopyWith<$Res> {
  factory _$DownloadsResponseCopyWith(_DownloadsResponse value, $Res Function(_DownloadsResponse) _then) = __$DownloadsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DownloadsResponse.galleryIdKey_) String galleryId,@JsonKey(name: DownloadsResponse.urlsKey_) Map<String, dynamic> urls
});




}
/// @nodoc
class __$DownloadsResponseCopyWithImpl<$Res>
    implements _$DownloadsResponseCopyWith<$Res> {
  __$DownloadsResponseCopyWithImpl(this._self, this._then);

  final _DownloadsResponse _self;
  final $Res Function(_DownloadsResponse) _then;

/// Create a copy of DownloadsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? galleryId = null,Object? urls = null,}) {
  return _then(_DownloadsResponse(
galleryId: null == galleryId ? _self.galleryId : galleryId // ignore: cast_nullable_to_non_nullable
as String,urls: null == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
