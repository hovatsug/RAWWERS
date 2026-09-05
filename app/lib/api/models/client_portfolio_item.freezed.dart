// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_portfolio_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientPortfolioItem {

/// mediaAssetId
@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_) String get mediaAssetId;/// kind
@JsonKey(name: ClientPortfolioItem.kindKey_) String get kind;/// thumbnailUrl
@JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_) String? get thumbnailUrl;
/// Create a copy of ClientPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientPortfolioItemCopyWith<ClientPortfolioItem> get copyWith => _$ClientPortfolioItemCopyWithImpl<ClientPortfolioItem>(this as ClientPortfolioItem, _$identity);

  /// Serializes this ClientPortfolioItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientPortfolioItem&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,kind,thumbnailUrl);

@override
String toString() {
  return 'ClientPortfolioItem(mediaAssetId: $mediaAssetId, kind: $kind, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class $ClientPortfolioItemCopyWith<$Res>  {
  factory $ClientPortfolioItemCopyWith(ClientPortfolioItem value, $Res Function(ClientPortfolioItem) _then) = _$ClientPortfolioItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: ClientPortfolioItem.kindKey_) String kind,@JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_) String? thumbnailUrl
});




}
/// @nodoc
class _$ClientPortfolioItemCopyWithImpl<$Res>
    implements $ClientPortfolioItemCopyWith<$Res> {
  _$ClientPortfolioItemCopyWithImpl(this._self, this._then);

  final ClientPortfolioItem _self;
  final $Res Function(ClientPortfolioItem) _then;

/// Create a copy of ClientPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? kind = null,Object? thumbnailUrl = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientPortfolioItem].
extension ClientPortfolioItemPatterns on ClientPortfolioItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientPortfolioItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientPortfolioItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientPortfolioItem value)  $default,){
final _that = this;
switch (_that) {
case _ClientPortfolioItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientPortfolioItem value)?  $default,){
final _that = this;
switch (_that) {
case _ClientPortfolioItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ClientPortfolioItem.kindKey_)  String kind, @JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_)  String? thumbnailUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientPortfolioItem() when $default != null:
return $default(_that.mediaAssetId,_that.kind,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ClientPortfolioItem.kindKey_)  String kind, @JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_)  String? thumbnailUrl)  $default,) {final _that = this;
switch (_that) {
case _ClientPortfolioItem():
return $default(_that.mediaAssetId,_that.kind,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ClientPortfolioItem.kindKey_)  String kind, @JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_)  String? thumbnailUrl)?  $default,) {final _that = this;
switch (_that) {
case _ClientPortfolioItem() when $default != null:
return $default(_that.mediaAssetId,_that.kind,_that.thumbnailUrl);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientPortfolioItem extends ClientPortfolioItem {
  const _ClientPortfolioItem({@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: ClientPortfolioItem.kindKey_) required this.kind, @JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_) this.thumbnailUrl}): super._();
  factory _ClientPortfolioItem.fromJson(Map<String, dynamic> json) => _$ClientPortfolioItemFromJson(json);

/// mediaAssetId
@override@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_) final  String mediaAssetId;
/// kind
@override@JsonKey(name: ClientPortfolioItem.kindKey_) final  String kind;
/// thumbnailUrl
@override@JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_) final  String? thumbnailUrl;

/// Create a copy of ClientPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientPortfolioItemCopyWith<_ClientPortfolioItem> get copyWith => __$ClientPortfolioItemCopyWithImpl<_ClientPortfolioItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientPortfolioItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientPortfolioItem&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,kind,thumbnailUrl);

@override
String toString() {
  return 'ClientPortfolioItem(mediaAssetId: $mediaAssetId, kind: $kind, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class _$ClientPortfolioItemCopyWith<$Res> implements $ClientPortfolioItemCopyWith<$Res> {
  factory _$ClientPortfolioItemCopyWith(_ClientPortfolioItem value, $Res Function(_ClientPortfolioItem) _then) = __$ClientPortfolioItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: ClientPortfolioItem.kindKey_) String kind,@JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_) String? thumbnailUrl
});




}
/// @nodoc
class __$ClientPortfolioItemCopyWithImpl<$Res>
    implements _$ClientPortfolioItemCopyWith<$Res> {
  __$ClientPortfolioItemCopyWithImpl(this._self, this._then);

  final _ClientPortfolioItem _self;
  final $Res Function(_ClientPortfolioItem) _then;

/// Create a copy of ClientPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? kind = null,Object? thumbnailUrl = freezed,}) {
  return _then(_ClientPortfolioItem(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
