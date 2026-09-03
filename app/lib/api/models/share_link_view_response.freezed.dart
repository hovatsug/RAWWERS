// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_link_view_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShareLinkViewResponse {

/// gigId
@JsonKey(name: ShareLinkViewResponse.gigIdKey_) String get gigId;/// scope
@JsonKey(name: ShareLinkViewResponse.scopeKey_) ShareLinkScope get scope;/// expiresAt
@JsonKey(name: ShareLinkViewResponse.expiresAtKey_) DateTime? get expiresAt;/// maxViews
@JsonKey(name: ShareLinkViewResponse.maxViewsKey_) int? get maxViews;/// viewCount
@JsonKey(name: ShareLinkViewResponse.viewCountKey_) int get viewCount;/// items
@JsonKey(name: ShareLinkViewResponse.itemsKey_) List<SharedMediaItemView>? get items;/// poweredByText
@JsonKey(name: ShareLinkViewResponse.poweredByTextKey_) String? get poweredByText;/// createGalleryCtaText
@JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_) String? get createGalleryCtaText;/// createGalleryCtaUrl
@JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_) String? get createGalleryCtaUrl;
/// Create a copy of ShareLinkViewResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareLinkViewResponseCopyWith<ShareLinkViewResponse> get copyWith => _$ShareLinkViewResponseCopyWithImpl<ShareLinkViewResponse>(this as ShareLinkViewResponse, _$identity);

  /// Serializes this ShareLinkViewResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareLinkViewResponse&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxViews, maxViews) || other.maxViews == maxViews)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.poweredByText, poweredByText) || other.poweredByText == poweredByText)&&(identical(other.createGalleryCtaText, createGalleryCtaText) || other.createGalleryCtaText == createGalleryCtaText)&&(identical(other.createGalleryCtaUrl, createGalleryCtaUrl) || other.createGalleryCtaUrl == createGalleryCtaUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,scope,expiresAt,maxViews,viewCount,const DeepCollectionEquality().hash(items),poweredByText,createGalleryCtaText,createGalleryCtaUrl);

@override
String toString() {
  return 'ShareLinkViewResponse(gigId: $gigId, scope: $scope, expiresAt: $expiresAt, maxViews: $maxViews, viewCount: $viewCount, items: $items, poweredByText: $poweredByText, createGalleryCtaText: $createGalleryCtaText, createGalleryCtaUrl: $createGalleryCtaUrl)';
}


}

/// @nodoc
abstract mixin class $ShareLinkViewResponseCopyWith<$Res>  {
  factory $ShareLinkViewResponseCopyWith(ShareLinkViewResponse value, $Res Function(ShareLinkViewResponse) _then) = _$ShareLinkViewResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShareLinkViewResponse.gigIdKey_) String gigId,@JsonKey(name: ShareLinkViewResponse.scopeKey_) ShareLinkScope scope,@JsonKey(name: ShareLinkViewResponse.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ShareLinkViewResponse.maxViewsKey_) int? maxViews,@JsonKey(name: ShareLinkViewResponse.viewCountKey_) int viewCount,@JsonKey(name: ShareLinkViewResponse.itemsKey_) List<SharedMediaItemView>? items,@JsonKey(name: ShareLinkViewResponse.poweredByTextKey_) String? poweredByText,@JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_) String? createGalleryCtaText,@JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_) String? createGalleryCtaUrl
});




}
/// @nodoc
class _$ShareLinkViewResponseCopyWithImpl<$Res>
    implements $ShareLinkViewResponseCopyWith<$Res> {
  _$ShareLinkViewResponseCopyWithImpl(this._self, this._then);

  final ShareLinkViewResponse _self;
  final $Res Function(ShareLinkViewResponse) _then;

/// Create a copy of ShareLinkViewResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gigId = null,Object? scope = null,Object? expiresAt = freezed,Object? maxViews = freezed,Object? viewCount = null,Object? items = freezed,Object? poweredByText = freezed,Object? createGalleryCtaText = freezed,Object? createGalleryCtaUrl = freezed,}) {
  return _then(_self.copyWith(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ShareLinkScope,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxViews: freezed == maxViews ? _self.maxViews : maxViews // ignore: cast_nullable_to_non_nullable
as int?,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SharedMediaItemView>?,poweredByText: freezed == poweredByText ? _self.poweredByText : poweredByText // ignore: cast_nullable_to_non_nullable
as String?,createGalleryCtaText: freezed == createGalleryCtaText ? _self.createGalleryCtaText : createGalleryCtaText // ignore: cast_nullable_to_non_nullable
as String?,createGalleryCtaUrl: freezed == createGalleryCtaUrl ? _self.createGalleryCtaUrl : createGalleryCtaUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareLinkViewResponse].
extension ShareLinkViewResponsePatterns on ShareLinkViewResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareLinkViewResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareLinkViewResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareLinkViewResponse value)  $default,){
final _that = this;
switch (_that) {
case _ShareLinkViewResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareLinkViewResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ShareLinkViewResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShareLinkViewResponse.gigIdKey_)  String gigId, @JsonKey(name: ShareLinkViewResponse.scopeKey_)  ShareLinkScope scope, @JsonKey(name: ShareLinkViewResponse.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkViewResponse.maxViewsKey_)  int? maxViews, @JsonKey(name: ShareLinkViewResponse.viewCountKey_)  int viewCount, @JsonKey(name: ShareLinkViewResponse.itemsKey_)  List<SharedMediaItemView>? items, @JsonKey(name: ShareLinkViewResponse.poweredByTextKey_)  String? poweredByText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_)  String? createGalleryCtaText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_)  String? createGalleryCtaUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareLinkViewResponse() when $default != null:
return $default(_that.gigId,_that.scope,_that.expiresAt,_that.maxViews,_that.viewCount,_that.items,_that.poweredByText,_that.createGalleryCtaText,_that.createGalleryCtaUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShareLinkViewResponse.gigIdKey_)  String gigId, @JsonKey(name: ShareLinkViewResponse.scopeKey_)  ShareLinkScope scope, @JsonKey(name: ShareLinkViewResponse.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkViewResponse.maxViewsKey_)  int? maxViews, @JsonKey(name: ShareLinkViewResponse.viewCountKey_)  int viewCount, @JsonKey(name: ShareLinkViewResponse.itemsKey_)  List<SharedMediaItemView>? items, @JsonKey(name: ShareLinkViewResponse.poweredByTextKey_)  String? poweredByText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_)  String? createGalleryCtaText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_)  String? createGalleryCtaUrl)  $default,) {final _that = this;
switch (_that) {
case _ShareLinkViewResponse():
return $default(_that.gigId,_that.scope,_that.expiresAt,_that.maxViews,_that.viewCount,_that.items,_that.poweredByText,_that.createGalleryCtaText,_that.createGalleryCtaUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShareLinkViewResponse.gigIdKey_)  String gigId, @JsonKey(name: ShareLinkViewResponse.scopeKey_)  ShareLinkScope scope, @JsonKey(name: ShareLinkViewResponse.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ShareLinkViewResponse.maxViewsKey_)  int? maxViews, @JsonKey(name: ShareLinkViewResponse.viewCountKey_)  int viewCount, @JsonKey(name: ShareLinkViewResponse.itemsKey_)  List<SharedMediaItemView>? items, @JsonKey(name: ShareLinkViewResponse.poweredByTextKey_)  String? poweredByText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_)  String? createGalleryCtaText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_)  String? createGalleryCtaUrl)?  $default,) {final _that = this;
switch (_that) {
case _ShareLinkViewResponse() when $default != null:
return $default(_that.gigId,_that.scope,_that.expiresAt,_that.maxViews,_that.viewCount,_that.items,_that.poweredByText,_that.createGalleryCtaText,_that.createGalleryCtaUrl);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShareLinkViewResponse extends ShareLinkViewResponse {
  const _ShareLinkViewResponse({@JsonKey(name: ShareLinkViewResponse.gigIdKey_) required this.gigId, @JsonKey(name: ShareLinkViewResponse.scopeKey_) required this.scope, @JsonKey(name: ShareLinkViewResponse.expiresAtKey_) this.expiresAt, @JsonKey(name: ShareLinkViewResponse.maxViewsKey_) this.maxViews, @JsonKey(name: ShareLinkViewResponse.viewCountKey_) required this.viewCount, @JsonKey(name: ShareLinkViewResponse.itemsKey_) final  List<SharedMediaItemView>? items, @JsonKey(name: ShareLinkViewResponse.poweredByTextKey_) this.poweredByText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_) this.createGalleryCtaText, @JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_) this.createGalleryCtaUrl}): _items = items,super._();
  factory _ShareLinkViewResponse.fromJson(Map<String, dynamic> json) => _$ShareLinkViewResponseFromJson(json);

/// gigId
@override@JsonKey(name: ShareLinkViewResponse.gigIdKey_) final  String gigId;
/// scope
@override@JsonKey(name: ShareLinkViewResponse.scopeKey_) final  ShareLinkScope scope;
/// expiresAt
@override@JsonKey(name: ShareLinkViewResponse.expiresAtKey_) final  DateTime? expiresAt;
/// maxViews
@override@JsonKey(name: ShareLinkViewResponse.maxViewsKey_) final  int? maxViews;
/// viewCount
@override@JsonKey(name: ShareLinkViewResponse.viewCountKey_) final  int viewCount;
/// items
 final  List<SharedMediaItemView>? _items;
/// items
@override@JsonKey(name: ShareLinkViewResponse.itemsKey_) List<SharedMediaItemView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// poweredByText
@override@JsonKey(name: ShareLinkViewResponse.poweredByTextKey_) final  String? poweredByText;
/// createGalleryCtaText
@override@JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_) final  String? createGalleryCtaText;
/// createGalleryCtaUrl
@override@JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_) final  String? createGalleryCtaUrl;

/// Create a copy of ShareLinkViewResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareLinkViewResponseCopyWith<_ShareLinkViewResponse> get copyWith => __$ShareLinkViewResponseCopyWithImpl<_ShareLinkViewResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareLinkViewResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareLinkViewResponse&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxViews, maxViews) || other.maxViews == maxViews)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.poweredByText, poweredByText) || other.poweredByText == poweredByText)&&(identical(other.createGalleryCtaText, createGalleryCtaText) || other.createGalleryCtaText == createGalleryCtaText)&&(identical(other.createGalleryCtaUrl, createGalleryCtaUrl) || other.createGalleryCtaUrl == createGalleryCtaUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,scope,expiresAt,maxViews,viewCount,const DeepCollectionEquality().hash(_items),poweredByText,createGalleryCtaText,createGalleryCtaUrl);

@override
String toString() {
  return 'ShareLinkViewResponse(gigId: $gigId, scope: $scope, expiresAt: $expiresAt, maxViews: $maxViews, viewCount: $viewCount, items: $items, poweredByText: $poweredByText, createGalleryCtaText: $createGalleryCtaText, createGalleryCtaUrl: $createGalleryCtaUrl)';
}


}

/// @nodoc
abstract mixin class _$ShareLinkViewResponseCopyWith<$Res> implements $ShareLinkViewResponseCopyWith<$Res> {
  factory _$ShareLinkViewResponseCopyWith(_ShareLinkViewResponse value, $Res Function(_ShareLinkViewResponse) _then) = __$ShareLinkViewResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShareLinkViewResponse.gigIdKey_) String gigId,@JsonKey(name: ShareLinkViewResponse.scopeKey_) ShareLinkScope scope,@JsonKey(name: ShareLinkViewResponse.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ShareLinkViewResponse.maxViewsKey_) int? maxViews,@JsonKey(name: ShareLinkViewResponse.viewCountKey_) int viewCount,@JsonKey(name: ShareLinkViewResponse.itemsKey_) List<SharedMediaItemView>? items,@JsonKey(name: ShareLinkViewResponse.poweredByTextKey_) String? poweredByText,@JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_) String? createGalleryCtaText,@JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_) String? createGalleryCtaUrl
});




}
/// @nodoc
class __$ShareLinkViewResponseCopyWithImpl<$Res>
    implements _$ShareLinkViewResponseCopyWith<$Res> {
  __$ShareLinkViewResponseCopyWithImpl(this._self, this._then);

  final _ShareLinkViewResponse _self;
  final $Res Function(_ShareLinkViewResponse) _then;

/// Create a copy of ShareLinkViewResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gigId = null,Object? scope = null,Object? expiresAt = freezed,Object? maxViews = freezed,Object? viewCount = null,Object? items = freezed,Object? poweredByText = freezed,Object? createGalleryCtaText = freezed,Object? createGalleryCtaUrl = freezed,}) {
  return _then(_ShareLinkViewResponse(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ShareLinkScope,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxViews: freezed == maxViews ? _self.maxViews : maxViews // ignore: cast_nullable_to_non_nullable
as int?,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SharedMediaItemView>?,poweredByText: freezed == poweredByText ? _self.poweredByText : poweredByText // ignore: cast_nullable_to_non_nullable
as String?,createGalleryCtaText: freezed == createGalleryCtaText ? _self.createGalleryCtaText : createGalleryCtaText // ignore: cast_nullable_to_non_nullable
as String?,createGalleryCtaUrl: freezed == createGalleryCtaUrl ? _self.createGalleryCtaUrl : createGalleryCtaUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
