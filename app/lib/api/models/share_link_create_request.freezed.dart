// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_link_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShareLinkCreateRequest {

/// scope
@JsonKey(name: ShareLinkCreateRequest.scopeKey_) ShareLinkScope get scope;/// expiresAt
@JsonKey(name: ShareLinkCreateRequest.expiresAtKey_) DateTime? get expiresAt;/// maxViews
@JsonKey(name: ShareLinkCreateRequest.maxViewsKey_) int? get maxViews;/// mediaAssetIds
@JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_) List<String>? get mediaAssetIds;
/// Create a copy of ShareLinkCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareLinkCreateRequestCopyWith<ShareLinkCreateRequest> get copyWith => _$ShareLinkCreateRequestCopyWithImpl<ShareLinkCreateRequest>(this as ShareLinkCreateRequest, _$identity);

  /// Serializes this ShareLinkCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareLinkCreateRequest&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxViews, maxViews) || other.maxViews == maxViews)&&const DeepCollectionEquality().equals(other.mediaAssetIds, mediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scope,expiresAt,maxViews,const DeepCollectionEquality().hash(mediaAssetIds));

@override
String toString() {
  return 'ShareLinkCreateRequest(scope: $scope, expiresAt: $expiresAt, maxViews: $maxViews, mediaAssetIds: $mediaAssetIds)';
}


}

/// @nodoc
abstract mixin class $ShareLinkCreateRequestCopyWith<$Res>  {
  factory $ShareLinkCreateRequestCopyWith(ShareLinkCreateRequest value, $Res Function(ShareLinkCreateRequest) _then) = _$ShareLinkCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShareLinkCreateRequest.scopeKey_) ShareLinkScope scope,@JsonKey(name: ShareLinkCreateRequest.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ShareLinkCreateRequest.maxViewsKey_) int? maxViews,@JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_) List<String>? mediaAssetIds
});




}
/// @nodoc
class _$ShareLinkCreateRequestCopyWithImpl<$Res>
    implements $ShareLinkCreateRequestCopyWith<$Res> {
  _$ShareLinkCreateRequestCopyWithImpl(this._self, this._then);

  final ShareLinkCreateRequest _self;
  final $Res Function(ShareLinkCreateRequest) _then;

/// Create a copy of ShareLinkCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scope = null,Object? expiresAt = freezed,Object? maxViews = freezed,Object? mediaAssetIds = freezed,}) {
  return _then(_self.copyWith(
scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ShareLinkScope,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxViews: freezed == maxViews ? _self.maxViews : maxViews // ignore: cast_nullable_to_non_nullable
as int?,mediaAssetIds: freezed == mediaAssetIds ? _self.mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareLinkCreateRequest].
extension ShareLinkCreateRequestPatterns on ShareLinkCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareLinkCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareLinkCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareLinkCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ShareLinkCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareLinkCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ShareLinkCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShareLinkCreateRequest.scopeKey_)  ShareLinkScope scope, @JsonKey(name: ShareLinkCreateRequest.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkCreateRequest.maxViewsKey_)  int? maxViews, @JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_)  List<String>? mediaAssetIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareLinkCreateRequest() when $default != null:
return $default(_that.scope,_that.expiresAt,_that.maxViews,_that.mediaAssetIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShareLinkCreateRequest.scopeKey_)  ShareLinkScope scope, @JsonKey(name: ShareLinkCreateRequest.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkCreateRequest.maxViewsKey_)  int? maxViews, @JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_)  List<String>? mediaAssetIds)  $default,) {final _that = this;
switch (_that) {
case _ShareLinkCreateRequest():
return $default(_that.scope,_that.expiresAt,_that.maxViews,_that.mediaAssetIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShareLinkCreateRequest.scopeKey_)  ShareLinkScope scope, @JsonKey(name: ShareLinkCreateRequest.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkCreateRequest.maxViewsKey_)  int? maxViews, @JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_)  List<String>? mediaAssetIds)?  $default,) {final _that = this;
switch (_that) {
case _ShareLinkCreateRequest() when $default != null:
return $default(_that.scope,_that.expiresAt,_that.maxViews,_that.mediaAssetIds);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShareLinkCreateRequest extends ShareLinkCreateRequest {
  const _ShareLinkCreateRequest({@JsonKey(name: ShareLinkCreateRequest.scopeKey_) required this.scope, @JsonKey(name: ShareLinkCreateRequest.expiresAtKey_) this.expiresAt, @JsonKey(name: ShareLinkCreateRequest.maxViewsKey_) this.maxViews, @JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_) final  List<String>? mediaAssetIds}): _mediaAssetIds = mediaAssetIds,super._();
  factory _ShareLinkCreateRequest.fromJson(Map<String, dynamic> json) => _$ShareLinkCreateRequestFromJson(json);

/// scope
@override@JsonKey(name: ShareLinkCreateRequest.scopeKey_) final  ShareLinkScope scope;
/// expiresAt
@override@JsonKey(name: ShareLinkCreateRequest.expiresAtKey_) final  DateTime? expiresAt;
/// maxViews
@override@JsonKey(name: ShareLinkCreateRequest.maxViewsKey_) final  int? maxViews;
/// mediaAssetIds
 final  List<String>? _mediaAssetIds;
/// mediaAssetIds
@override@JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_) List<String>? get mediaAssetIds {
  final value = _mediaAssetIds;
  if (value == null) return null;
  if (_mediaAssetIds is EqualUnmodifiableListView) return _mediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ShareLinkCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareLinkCreateRequestCopyWith<_ShareLinkCreateRequest> get copyWith => __$ShareLinkCreateRequestCopyWithImpl<_ShareLinkCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareLinkCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareLinkCreateRequest&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxViews, maxViews) || other.maxViews == maxViews)&&const DeepCollectionEquality().equals(other._mediaAssetIds, _mediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scope,expiresAt,maxViews,const DeepCollectionEquality().hash(_mediaAssetIds));

@override
String toString() {
  return 'ShareLinkCreateRequest(scope: $scope, expiresAt: $expiresAt, maxViews: $maxViews, mediaAssetIds: $mediaAssetIds)';
}


}

/// @nodoc
abstract mixin class _$ShareLinkCreateRequestCopyWith<$Res> implements $ShareLinkCreateRequestCopyWith<$Res> {
  factory _$ShareLinkCreateRequestCopyWith(_ShareLinkCreateRequest value, $Res Function(_ShareLinkCreateRequest) _then) = __$ShareLinkCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShareLinkCreateRequest.scopeKey_) ShareLinkScope scope,@JsonKey(name: ShareLinkCreateRequest.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ShareLinkCreateRequest.maxViewsKey_) int? maxViews,@JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_) List<String>? mediaAssetIds
});




}
/// @nodoc
class __$ShareLinkCreateRequestCopyWithImpl<$Res>
    implements _$ShareLinkCreateRequestCopyWith<$Res> {
  __$ShareLinkCreateRequestCopyWithImpl(this._self, this._then);

  final _ShareLinkCreateRequest _self;
  final $Res Function(_ShareLinkCreateRequest) _then;

/// Create a copy of ShareLinkCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scope = null,Object? expiresAt = freezed,Object? maxViews = freezed,Object? mediaAssetIds = freezed,}) {
  return _then(_ShareLinkCreateRequest(
scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ShareLinkScope,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxViews: freezed == maxViews ? _self.maxViews : maxViews // ignore: cast_nullable_to_non_nullable
as int?,mediaAssetIds: freezed == mediaAssetIds ? _self._mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
