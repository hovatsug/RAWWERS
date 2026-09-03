// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'i18n_bundle_fetch_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$I18nBundleFetchResponse {

/// locale
@JsonKey(name: I18nBundleFetchResponse.localeKey_) String get locale;/// namespace
@JsonKey(name: I18nBundleFetchResponse.namespaceKey_) String get namespace;/// version
@JsonKey(name: I18nBundleFetchResponse.versionKey_) int get version;/// content
@JsonKey(name: I18nBundleFetchResponse.contentKey_) Map<String, dynamic>? get content;
/// Create a copy of I18nBundleFetchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$I18nBundleFetchResponseCopyWith<I18nBundleFetchResponse> get copyWith => _$I18nBundleFetchResponseCopyWithImpl<I18nBundleFetchResponse>(this as I18nBundleFetchResponse, _$identity);

  /// Serializes this I18nBundleFetchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is I18nBundleFetchResponse&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.namespace, namespace) || other.namespace == namespace)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.content, content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locale,namespace,version,const DeepCollectionEquality().hash(content));

@override
String toString() {
  return 'I18nBundleFetchResponse(locale: $locale, namespace: $namespace, version: $version, content: $content)';
}


}

/// @nodoc
abstract mixin class $I18nBundleFetchResponseCopyWith<$Res>  {
  factory $I18nBundleFetchResponseCopyWith(I18nBundleFetchResponse value, $Res Function(I18nBundleFetchResponse) _then) = _$I18nBundleFetchResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: I18nBundleFetchResponse.localeKey_) String locale,@JsonKey(name: I18nBundleFetchResponse.namespaceKey_) String namespace,@JsonKey(name: I18nBundleFetchResponse.versionKey_) int version,@JsonKey(name: I18nBundleFetchResponse.contentKey_) Map<String, dynamic>? content
});




}
/// @nodoc
class _$I18nBundleFetchResponseCopyWithImpl<$Res>
    implements $I18nBundleFetchResponseCopyWith<$Res> {
  _$I18nBundleFetchResponseCopyWithImpl(this._self, this._then);

  final I18nBundleFetchResponse _self;
  final $Res Function(I18nBundleFetchResponse) _then;

/// Create a copy of I18nBundleFetchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? namespace = null,Object? version = null,Object? content = freezed,}) {
  return _then(_self.copyWith(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,namespace: null == namespace ? _self.namespace : namespace // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [I18nBundleFetchResponse].
extension I18nBundleFetchResponsePatterns on I18nBundleFetchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _I18nBundleFetchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _I18nBundleFetchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _I18nBundleFetchResponse value)  $default,){
final _that = this;
switch (_that) {
case _I18nBundleFetchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _I18nBundleFetchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _I18nBundleFetchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: I18nBundleFetchResponse.localeKey_)  String locale, @JsonKey(name: I18nBundleFetchResponse.namespaceKey_)  String namespace, @JsonKey(name: I18nBundleFetchResponse.versionKey_)  int version, @JsonKey(name: I18nBundleFetchResponse.contentKey_)  Map<String, dynamic>? content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _I18nBundleFetchResponse() when $default != null:
return $default(_that.locale,_that.namespace,_that.version,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: I18nBundleFetchResponse.localeKey_)  String locale, @JsonKey(name: I18nBundleFetchResponse.namespaceKey_)  String namespace, @JsonKey(name: I18nBundleFetchResponse.versionKey_)  int version, @JsonKey(name: I18nBundleFetchResponse.contentKey_)  Map<String, dynamic>? content)  $default,) {final _that = this;
switch (_that) {
case _I18nBundleFetchResponse():
return $default(_that.locale,_that.namespace,_that.version,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: I18nBundleFetchResponse.localeKey_)  String locale, @JsonKey(name: I18nBundleFetchResponse.namespaceKey_)  String namespace, @JsonKey(name: I18nBundleFetchResponse.versionKey_)  int version, @JsonKey(name: I18nBundleFetchResponse.contentKey_)  Map<String, dynamic>? content)?  $default,) {final _that = this;
switch (_that) {
case _I18nBundleFetchResponse() when $default != null:
return $default(_that.locale,_that.namespace,_that.version,_that.content);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _I18nBundleFetchResponse extends I18nBundleFetchResponse {
  const _I18nBundleFetchResponse({@JsonKey(name: I18nBundleFetchResponse.localeKey_) required this.locale, @JsonKey(name: I18nBundleFetchResponse.namespaceKey_) required this.namespace, @JsonKey(name: I18nBundleFetchResponse.versionKey_) required this.version, @JsonKey(name: I18nBundleFetchResponse.contentKey_) final  Map<String, dynamic>? content}): _content = content,super._();
  factory _I18nBundleFetchResponse.fromJson(Map<String, dynamic> json) => _$I18nBundleFetchResponseFromJson(json);

/// locale
@override@JsonKey(name: I18nBundleFetchResponse.localeKey_) final  String locale;
/// namespace
@override@JsonKey(name: I18nBundleFetchResponse.namespaceKey_) final  String namespace;
/// version
@override@JsonKey(name: I18nBundleFetchResponse.versionKey_) final  int version;
/// content
 final  Map<String, dynamic>? _content;
/// content
@override@JsonKey(name: I18nBundleFetchResponse.contentKey_) Map<String, dynamic>? get content {
  final value = _content;
  if (value == null) return null;
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of I18nBundleFetchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$I18nBundleFetchResponseCopyWith<_I18nBundleFetchResponse> get copyWith => __$I18nBundleFetchResponseCopyWithImpl<_I18nBundleFetchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$I18nBundleFetchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _I18nBundleFetchResponse&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.namespace, namespace) || other.namespace == namespace)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._content, _content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locale,namespace,version,const DeepCollectionEquality().hash(_content));

@override
String toString() {
  return 'I18nBundleFetchResponse(locale: $locale, namespace: $namespace, version: $version, content: $content)';
}


}

/// @nodoc
abstract mixin class _$I18nBundleFetchResponseCopyWith<$Res> implements $I18nBundleFetchResponseCopyWith<$Res> {
  factory _$I18nBundleFetchResponseCopyWith(_I18nBundleFetchResponse value, $Res Function(_I18nBundleFetchResponse) _then) = __$I18nBundleFetchResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: I18nBundleFetchResponse.localeKey_) String locale,@JsonKey(name: I18nBundleFetchResponse.namespaceKey_) String namespace,@JsonKey(name: I18nBundleFetchResponse.versionKey_) int version,@JsonKey(name: I18nBundleFetchResponse.contentKey_) Map<String, dynamic>? content
});




}
/// @nodoc
class __$I18nBundleFetchResponseCopyWithImpl<$Res>
    implements _$I18nBundleFetchResponseCopyWith<$Res> {
  __$I18nBundleFetchResponseCopyWithImpl(this._self, this._then);

  final _I18nBundleFetchResponse _self;
  final $Res Function(_I18nBundleFetchResponse) _then;

/// Create a copy of I18nBundleFetchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? namespace = null,Object? version = null,Object? content = freezed,}) {
  return _then(_I18nBundleFetchResponse(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,namespace: null == namespace ? _self.namespace : namespace // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,content: freezed == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
