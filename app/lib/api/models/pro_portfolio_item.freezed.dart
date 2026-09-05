// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_portfolio_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPortfolioItem {

/// mediaAssetId
@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_) String get mediaAssetId;/// kind
@JsonKey(name: ProPortfolioItem.kindKey_) String get kind;/// status
@JsonKey(name: ProPortfolioItem.statusKey_) String get status;/// thumbnailUrl
@JsonKey(name: ProPortfolioItem.thumbnailUrlKey_) String? get thumbnailUrl;/// nicheSlugs
@JsonKey(name: ProPortfolioItem.nicheSlugsKey_) List<String>? get nicheSlugs;/// isCover
@JsonKey(name: ProPortfolioItem.isCoverKey_) bool get isCover;/// createdAt
@JsonKey(name: ProPortfolioItem.createdAtKey_) DateTime get createdAt;
/// Create a copy of ProPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPortfolioItemCopyWith<ProPortfolioItem> get copyWith => _$ProPortfolioItemCopyWithImpl<ProPortfolioItem>(this as ProPortfolioItem, _$identity);

  /// Serializes this ProPortfolioItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPortfolioItem&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other.nicheSlugs, nicheSlugs)&&(identical(other.isCover, isCover) || other.isCover == isCover)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,kind,status,thumbnailUrl,const DeepCollectionEquality().hash(nicheSlugs),isCover,createdAt);

@override
String toString() {
  return 'ProPortfolioItem(mediaAssetId: $mediaAssetId, kind: $kind, status: $status, thumbnailUrl: $thumbnailUrl, nicheSlugs: $nicheSlugs, isCover: $isCover, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProPortfolioItemCopyWith<$Res>  {
  factory $ProPortfolioItemCopyWith(ProPortfolioItem value, $Res Function(ProPortfolioItem) _then) = _$ProPortfolioItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: ProPortfolioItem.kindKey_) String kind,@JsonKey(name: ProPortfolioItem.statusKey_) String status,@JsonKey(name: ProPortfolioItem.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: ProPortfolioItem.nicheSlugsKey_) List<String>? nicheSlugs,@JsonKey(name: ProPortfolioItem.isCoverKey_) bool isCover,@JsonKey(name: ProPortfolioItem.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$ProPortfolioItemCopyWithImpl<$Res>
    implements $ProPortfolioItemCopyWith<$Res> {
  _$ProPortfolioItemCopyWithImpl(this._self, this._then);

  final ProPortfolioItem _self;
  final $Res Function(ProPortfolioItem) _then;

/// Create a copy of ProPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? kind = null,Object? status = null,Object? thumbnailUrl = freezed,Object? nicheSlugs = freezed,Object? isCover = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,nicheSlugs: freezed == nicheSlugs ? _self.nicheSlugs : nicheSlugs // ignore: cast_nullable_to_non_nullable
as List<String>?,isCover: null == isCover ? _self.isCover : isCover // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPortfolioItem].
extension ProPortfolioItemPatterns on ProPortfolioItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPortfolioItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPortfolioItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPortfolioItem value)  $default,){
final _that = this;
switch (_that) {
case _ProPortfolioItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPortfolioItem value)?  $default,){
final _that = this;
switch (_that) {
case _ProPortfolioItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ProPortfolioItem.kindKey_)  String kind, @JsonKey(name: ProPortfolioItem.statusKey_)  String status, @JsonKey(name: ProPortfolioItem.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: ProPortfolioItem.nicheSlugsKey_)  List<String>? nicheSlugs, @JsonKey(name: ProPortfolioItem.isCoverKey_)  bool isCover, @JsonKey(name: ProPortfolioItem.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPortfolioItem() when $default != null:
return $default(_that.mediaAssetId,_that.kind,_that.status,_that.thumbnailUrl,_that.nicheSlugs,_that.isCover,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ProPortfolioItem.kindKey_)  String kind, @JsonKey(name: ProPortfolioItem.statusKey_)  String status, @JsonKey(name: ProPortfolioItem.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: ProPortfolioItem.nicheSlugsKey_)  List<String>? nicheSlugs, @JsonKey(name: ProPortfolioItem.isCoverKey_)  bool isCover, @JsonKey(name: ProPortfolioItem.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProPortfolioItem():
return $default(_that.mediaAssetId,_that.kind,_that.status,_that.thumbnailUrl,_that.nicheSlugs,_that.isCover,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ProPortfolioItem.kindKey_)  String kind, @JsonKey(name: ProPortfolioItem.statusKey_)  String status, @JsonKey(name: ProPortfolioItem.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: ProPortfolioItem.nicheSlugsKey_)  List<String>? nicheSlugs, @JsonKey(name: ProPortfolioItem.isCoverKey_)  bool isCover, @JsonKey(name: ProPortfolioItem.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProPortfolioItem() when $default != null:
return $default(_that.mediaAssetId,_that.kind,_that.status,_that.thumbnailUrl,_that.nicheSlugs,_that.isCover,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPortfolioItem extends ProPortfolioItem {
  const _ProPortfolioItem({@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: ProPortfolioItem.kindKey_) required this.kind, @JsonKey(name: ProPortfolioItem.statusKey_) required this.status, @JsonKey(name: ProPortfolioItem.thumbnailUrlKey_) this.thumbnailUrl, @JsonKey(name: ProPortfolioItem.nicheSlugsKey_) final  List<String>? nicheSlugs, @JsonKey(name: ProPortfolioItem.isCoverKey_) this.isCover = false, @JsonKey(name: ProPortfolioItem.createdAtKey_) required this.createdAt}): _nicheSlugs = nicheSlugs,super._();
  factory _ProPortfolioItem.fromJson(Map<String, dynamic> json) => _$ProPortfolioItemFromJson(json);

/// mediaAssetId
@override@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_) final  String mediaAssetId;
/// kind
@override@JsonKey(name: ProPortfolioItem.kindKey_) final  String kind;
/// status
@override@JsonKey(name: ProPortfolioItem.statusKey_) final  String status;
/// thumbnailUrl
@override@JsonKey(name: ProPortfolioItem.thumbnailUrlKey_) final  String? thumbnailUrl;
/// nicheSlugs
 final  List<String>? _nicheSlugs;
/// nicheSlugs
@override@JsonKey(name: ProPortfolioItem.nicheSlugsKey_) List<String>? get nicheSlugs {
  final value = _nicheSlugs;
  if (value == null) return null;
  if (_nicheSlugs is EqualUnmodifiableListView) return _nicheSlugs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// isCover
@override@JsonKey(name: ProPortfolioItem.isCoverKey_) final  bool isCover;
/// createdAt
@override@JsonKey(name: ProPortfolioItem.createdAtKey_) final  DateTime createdAt;

/// Create a copy of ProPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPortfolioItemCopyWith<_ProPortfolioItem> get copyWith => __$ProPortfolioItemCopyWithImpl<_ProPortfolioItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPortfolioItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPortfolioItem&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other._nicheSlugs, _nicheSlugs)&&(identical(other.isCover, isCover) || other.isCover == isCover)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,kind,status,thumbnailUrl,const DeepCollectionEquality().hash(_nicheSlugs),isCover,createdAt);

@override
String toString() {
  return 'ProPortfolioItem(mediaAssetId: $mediaAssetId, kind: $kind, status: $status, thumbnailUrl: $thumbnailUrl, nicheSlugs: $nicheSlugs, isCover: $isCover, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProPortfolioItemCopyWith<$Res> implements $ProPortfolioItemCopyWith<$Res> {
  factory _$ProPortfolioItemCopyWith(_ProPortfolioItem value, $Res Function(_ProPortfolioItem) _then) = __$ProPortfolioItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPortfolioItem.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: ProPortfolioItem.kindKey_) String kind,@JsonKey(name: ProPortfolioItem.statusKey_) String status,@JsonKey(name: ProPortfolioItem.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: ProPortfolioItem.nicheSlugsKey_) List<String>? nicheSlugs,@JsonKey(name: ProPortfolioItem.isCoverKey_) bool isCover,@JsonKey(name: ProPortfolioItem.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$ProPortfolioItemCopyWithImpl<$Res>
    implements _$ProPortfolioItemCopyWith<$Res> {
  __$ProPortfolioItemCopyWithImpl(this._self, this._then);

  final _ProPortfolioItem _self;
  final $Res Function(_ProPortfolioItem) _then;

/// Create a copy of ProPortfolioItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? kind = null,Object? status = null,Object? thumbnailUrl = freezed,Object? nicheSlugs = freezed,Object? isCover = null,Object? createdAt = null,}) {
  return _then(_ProPortfolioItem(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,nicheSlugs: freezed == nicheSlugs ? _self._nicheSlugs : nicheSlugs // ignore: cast_nullable_to_non_nullable
as List<String>?,isCover: null == isCover ? _self.isCover : isCover // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
