// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_link_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShareLinkCreateResponse {

/// id
@JsonKey(name: ShareLinkCreateResponse.idKey_) String get id;/// token
@JsonKey(name: ShareLinkCreateResponse.tokenKey_) String get token;/// shareUrl
@JsonKey(name: ShareLinkCreateResponse.shareUrlKey_) String get shareUrl;/// expiresAt
@JsonKey(name: ShareLinkCreateResponse.expiresAtKey_) DateTime? get expiresAt;/// maxViews
@JsonKey(name: ShareLinkCreateResponse.maxViewsKey_) int? get maxViews;
/// Create a copy of ShareLinkCreateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareLinkCreateResponseCopyWith<ShareLinkCreateResponse> get copyWith => _$ShareLinkCreateResponseCopyWithImpl<ShareLinkCreateResponse>(this as ShareLinkCreateResponse, _$identity);

  /// Serializes this ShareLinkCreateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareLinkCreateResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.token, token) || other.token == token)&&(identical(other.shareUrl, shareUrl) || other.shareUrl == shareUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxViews, maxViews) || other.maxViews == maxViews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,token,shareUrl,expiresAt,maxViews);

@override
String toString() {
  return 'ShareLinkCreateResponse(id: $id, token: $token, shareUrl: $shareUrl, expiresAt: $expiresAt, maxViews: $maxViews)';
}


}

/// @nodoc
abstract mixin class $ShareLinkCreateResponseCopyWith<$Res>  {
  factory $ShareLinkCreateResponseCopyWith(ShareLinkCreateResponse value, $Res Function(ShareLinkCreateResponse) _then) = _$ShareLinkCreateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShareLinkCreateResponse.idKey_) String id,@JsonKey(name: ShareLinkCreateResponse.tokenKey_) String token,@JsonKey(name: ShareLinkCreateResponse.shareUrlKey_) String shareUrl,@JsonKey(name: ShareLinkCreateResponse.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ShareLinkCreateResponse.maxViewsKey_) int? maxViews
});




}
/// @nodoc
class _$ShareLinkCreateResponseCopyWithImpl<$Res>
    implements $ShareLinkCreateResponseCopyWith<$Res> {
  _$ShareLinkCreateResponseCopyWithImpl(this._self, this._then);

  final ShareLinkCreateResponse _self;
  final $Res Function(ShareLinkCreateResponse) _then;

/// Create a copy of ShareLinkCreateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? token = null,Object? shareUrl = null,Object? expiresAt = freezed,Object? maxViews = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,shareUrl: null == shareUrl ? _self.shareUrl : shareUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxViews: freezed == maxViews ? _self.maxViews : maxViews // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareLinkCreateResponse].
extension ShareLinkCreateResponsePatterns on ShareLinkCreateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareLinkCreateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareLinkCreateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareLinkCreateResponse value)  $default,){
final _that = this;
switch (_that) {
case _ShareLinkCreateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareLinkCreateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ShareLinkCreateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShareLinkCreateResponse.idKey_)  String id, @JsonKey(name: ShareLinkCreateResponse.tokenKey_)  String token, @JsonKey(name: ShareLinkCreateResponse.shareUrlKey_)  String shareUrl, @JsonKey(name: ShareLinkCreateResponse.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkCreateResponse.maxViewsKey_)  int? maxViews)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareLinkCreateResponse() when $default != null:
return $default(_that.id,_that.token,_that.shareUrl,_that.expiresAt,_that.maxViews);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShareLinkCreateResponse.idKey_)  String id, @JsonKey(name: ShareLinkCreateResponse.tokenKey_)  String token, @JsonKey(name: ShareLinkCreateResponse.shareUrlKey_)  String shareUrl, @JsonKey(name: ShareLinkCreateResponse.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkCreateResponse.maxViewsKey_)  int? maxViews)  $default,) {final _that = this;
switch (_that) {
case _ShareLinkCreateResponse():
return $default(_that.id,_that.token,_that.shareUrl,_that.expiresAt,_that.maxViews);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShareLinkCreateResponse.idKey_)  String id, @JsonKey(name: ShareLinkCreateResponse.tokenKey_)  String token, @JsonKey(name: ShareLinkCreateResponse.shareUrlKey_)  String shareUrl, @JsonKey(name: ShareLinkCreateResponse.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkCreateResponse.maxViewsKey_)  int? maxViews)?  $default,) {final _that = this;
switch (_that) {
case _ShareLinkCreateResponse() when $default != null:
return $default(_that.id,_that.token,_that.shareUrl,_that.expiresAt,_that.maxViews);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShareLinkCreateResponse extends ShareLinkCreateResponse {
  const _ShareLinkCreateResponse({@JsonKey(name: ShareLinkCreateResponse.idKey_) required this.id, @JsonKey(name: ShareLinkCreateResponse.tokenKey_) required this.token, @JsonKey(name: ShareLinkCreateResponse.shareUrlKey_) required this.shareUrl, @JsonKey(name: ShareLinkCreateResponse.expiresAtKey_) this.expiresAt, @JsonKey(name: ShareLinkCreateResponse.maxViewsKey_) this.maxViews}): super._();
  factory _ShareLinkCreateResponse.fromJson(Map<String, dynamic> json) => _$ShareLinkCreateResponseFromJson(json);

/// id
@override@JsonKey(name: ShareLinkCreateResponse.idKey_) final  String id;
/// token
@override@JsonKey(name: ShareLinkCreateResponse.tokenKey_) final  String token;
/// shareUrl
@override@JsonKey(name: ShareLinkCreateResponse.shareUrlKey_) final  String shareUrl;
/// expiresAt
@override@JsonKey(name: ShareLinkCreateResponse.expiresAtKey_) final  DateTime? expiresAt;
/// maxViews
@override@JsonKey(name: ShareLinkCreateResponse.maxViewsKey_) final  int? maxViews;

/// Create a copy of ShareLinkCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareLinkCreateResponseCopyWith<_ShareLinkCreateResponse> get copyWith => __$ShareLinkCreateResponseCopyWithImpl<_ShareLinkCreateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareLinkCreateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareLinkCreateResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.token, token) || other.token == token)&&(identical(other.shareUrl, shareUrl) || other.shareUrl == shareUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxViews, maxViews) || other.maxViews == maxViews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,token,shareUrl,expiresAt,maxViews);

@override
String toString() {
  return 'ShareLinkCreateResponse(id: $id, token: $token, shareUrl: $shareUrl, expiresAt: $expiresAt, maxViews: $maxViews)';
}


}

/// @nodoc
abstract mixin class _$ShareLinkCreateResponseCopyWith<$Res> implements $ShareLinkCreateResponseCopyWith<$Res> {
  factory _$ShareLinkCreateResponseCopyWith(_ShareLinkCreateResponse value, $Res Function(_ShareLinkCreateResponse) _then) = __$ShareLinkCreateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShareLinkCreateResponse.idKey_) String id,@JsonKey(name: ShareLinkCreateResponse.tokenKey_) String token,@JsonKey(name: ShareLinkCreateResponse.shareUrlKey_) String shareUrl,@JsonKey(name: ShareLinkCreateResponse.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ShareLinkCreateResponse.maxViewsKey_) int? maxViews
});




}
/// @nodoc
class __$ShareLinkCreateResponseCopyWithImpl<$Res>
    implements _$ShareLinkCreateResponseCopyWith<$Res> {
  __$ShareLinkCreateResponseCopyWithImpl(this._self, this._then);

  final _ShareLinkCreateResponse _self;
  final $Res Function(_ShareLinkCreateResponse) _then;

/// Create a copy of ShareLinkCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? token = null,Object? shareUrl = null,Object? expiresAt = freezed,Object? maxViews = freezed,}) {
  return _then(_ShareLinkCreateResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,shareUrl: null == shareUrl ? _self.shareUrl : shareUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxViews: freezed == maxViews ? _self.maxViews : maxViews // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
