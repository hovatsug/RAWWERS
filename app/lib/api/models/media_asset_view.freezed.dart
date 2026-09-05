// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_asset_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaAssetView {

/// id
@JsonKey(name: MediaAssetView.idKey_) String get id;/// ownerUserId
@JsonKey(name: MediaAssetView.ownerUserIdKey_) String get ownerUserId;/// kind
@JsonKey(name: MediaAssetView.kindKey_) String get kind;/// purpose
@JsonKey(name: MediaAssetView.purposeKey_) String get purpose;/// provider
@JsonKey(name: MediaAssetView.providerKey_) String get provider;/// status
@JsonKey(name: MediaAssetView.statusKey_) String get status;/// visibility
@JsonKey(name: MediaAssetView.visibilityKey_) String get visibility;/// contentType
@JsonKey(name: MediaAssetView.contentTypeKey_) String? get contentType;/// byteSize
@JsonKey(name: MediaAssetView.byteSizeKey_) int? get byteSize;/// meta
@JsonKey(name: MediaAssetView.metaKey_) Map<String, dynamic>? get meta;/// createdAt
@JsonKey(name: MediaAssetView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: MediaAssetView.updatedAtKey_) DateTime get updatedAt;/// variants
@JsonKey(name: MediaAssetView.variantsKey_) List<MediaObjectView>? get variants;/// playbackId
@JsonKey(name: MediaAssetView.playbackIdKey_) String? get playbackId;/// isPublic
@JsonKey(name: MediaAssetView.isPublicKey_) bool get isPublic;/// nicheTags
@JsonKey(name: MediaAssetView.nicheTagsKey_) List<String>? get nicheTags;
/// Create a copy of MediaAssetView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaAssetViewCopyWith<MediaAssetView> get copyWith => _$MediaAssetViewCopyWithImpl<MediaAssetView>(this as MediaAssetView, _$identity);

  /// Serializes this MediaAssetView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaAssetView&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.status, status) || other.status == status)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.variants, variants)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other.nicheTags, nicheTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerUserId,kind,purpose,provider,status,visibility,contentType,byteSize,const DeepCollectionEquality().hash(meta),createdAt,updatedAt,const DeepCollectionEquality().hash(variants),playbackId,isPublic,const DeepCollectionEquality().hash(nicheTags));

@override
String toString() {
  return 'MediaAssetView(id: $id, ownerUserId: $ownerUserId, kind: $kind, purpose: $purpose, provider: $provider, status: $status, visibility: $visibility, contentType: $contentType, byteSize: $byteSize, meta: $meta, createdAt: $createdAt, updatedAt: $updatedAt, variants: $variants, playbackId: $playbackId, isPublic: $isPublic, nicheTags: $nicheTags)';
}


}

/// @nodoc
abstract mixin class $MediaAssetViewCopyWith<$Res>  {
  factory $MediaAssetViewCopyWith(MediaAssetView value, $Res Function(MediaAssetView) _then) = _$MediaAssetViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MediaAssetView.idKey_) String id,@JsonKey(name: MediaAssetView.ownerUserIdKey_) String ownerUserId,@JsonKey(name: MediaAssetView.kindKey_) String kind,@JsonKey(name: MediaAssetView.purposeKey_) String purpose,@JsonKey(name: MediaAssetView.providerKey_) String provider,@JsonKey(name: MediaAssetView.statusKey_) String status,@JsonKey(name: MediaAssetView.visibilityKey_) String visibility,@JsonKey(name: MediaAssetView.contentTypeKey_) String? contentType,@JsonKey(name: MediaAssetView.byteSizeKey_) int? byteSize,@JsonKey(name: MediaAssetView.metaKey_) Map<String, dynamic>? meta,@JsonKey(name: MediaAssetView.createdAtKey_) DateTime createdAt,@JsonKey(name: MediaAssetView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: MediaAssetView.variantsKey_) List<MediaObjectView>? variants,@JsonKey(name: MediaAssetView.playbackIdKey_) String? playbackId,@JsonKey(name: MediaAssetView.isPublicKey_) bool isPublic,@JsonKey(name: MediaAssetView.nicheTagsKey_) List<String>? nicheTags
});




}
/// @nodoc
class _$MediaAssetViewCopyWithImpl<$Res>
    implements $MediaAssetViewCopyWith<$Res> {
  _$MediaAssetViewCopyWithImpl(this._self, this._then);

  final MediaAssetView _self;
  final $Res Function(MediaAssetView) _then;

/// Create a copy of MediaAssetView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerUserId = null,Object? kind = null,Object? purpose = null,Object? provider = null,Object? status = null,Object? visibility = null,Object? contentType = freezed,Object? byteSize = freezed,Object? meta = freezed,Object? createdAt = null,Object? updatedAt = null,Object? variants = freezed,Object? playbackId = freezed,Object? isPublic = null,Object? nicheTags = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,byteSize: freezed == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,variants: freezed == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<MediaObjectView>?,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,nicheTags: freezed == nicheTags ? _self.nicheTags : nicheTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaAssetView].
extension MediaAssetViewPatterns on MediaAssetView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaAssetView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaAssetView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaAssetView value)  $default,){
final _that = this;
switch (_that) {
case _MediaAssetView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaAssetView value)?  $default,){
final _that = this;
switch (_that) {
case _MediaAssetView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MediaAssetView.idKey_)  String id, @JsonKey(name: MediaAssetView.ownerUserIdKey_)  String ownerUserId, @JsonKey(name: MediaAssetView.kindKey_)  String kind, @JsonKey(name: MediaAssetView.purposeKey_)  String purpose, @JsonKey(name: MediaAssetView.providerKey_)  String provider, @JsonKey(name: MediaAssetView.statusKey_)  String status, @JsonKey(name: MediaAssetView.visibilityKey_)  String visibility, @JsonKey(name: MediaAssetView.contentTypeKey_)  String? contentType, @JsonKey(name: MediaAssetView.byteSizeKey_)  int? byteSize, @JsonKey(name: MediaAssetView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: MediaAssetView.createdAtKey_)  DateTime createdAt, @JsonKey(name: MediaAssetView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: MediaAssetView.variantsKey_)  List<MediaObjectView>? variants, @JsonKey(name: MediaAssetView.playbackIdKey_)  String? playbackId, @JsonKey(name: MediaAssetView.isPublicKey_)  bool isPublic, @JsonKey(name: MediaAssetView.nicheTagsKey_)  List<String>? nicheTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaAssetView() when $default != null:
return $default(_that.id,_that.ownerUserId,_that.kind,_that.purpose,_that.provider,_that.status,_that.visibility,_that.contentType,_that.byteSize,_that.meta,_that.createdAt,_that.updatedAt,_that.variants,_that.playbackId,_that.isPublic,_that.nicheTags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MediaAssetView.idKey_)  String id, @JsonKey(name: MediaAssetView.ownerUserIdKey_)  String ownerUserId, @JsonKey(name: MediaAssetView.kindKey_)  String kind, @JsonKey(name: MediaAssetView.purposeKey_)  String purpose, @JsonKey(name: MediaAssetView.providerKey_)  String provider, @JsonKey(name: MediaAssetView.statusKey_)  String status, @JsonKey(name: MediaAssetView.visibilityKey_)  String visibility, @JsonKey(name: MediaAssetView.contentTypeKey_)  String? contentType, @JsonKey(name: MediaAssetView.byteSizeKey_)  int? byteSize, @JsonKey(name: MediaAssetView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: MediaAssetView.createdAtKey_)  DateTime createdAt, @JsonKey(name: MediaAssetView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: MediaAssetView.variantsKey_)  List<MediaObjectView>? variants, @JsonKey(name: MediaAssetView.playbackIdKey_)  String? playbackId, @JsonKey(name: MediaAssetView.isPublicKey_)  bool isPublic, @JsonKey(name: MediaAssetView.nicheTagsKey_)  List<String>? nicheTags)  $default,) {final _that = this;
switch (_that) {
case _MediaAssetView():
return $default(_that.id,_that.ownerUserId,_that.kind,_that.purpose,_that.provider,_that.status,_that.visibility,_that.contentType,_that.byteSize,_that.meta,_that.createdAt,_that.updatedAt,_that.variants,_that.playbackId,_that.isPublic,_that.nicheTags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MediaAssetView.idKey_)  String id, @JsonKey(name: MediaAssetView.ownerUserIdKey_)  String ownerUserId, @JsonKey(name: MediaAssetView.kindKey_)  String kind, @JsonKey(name: MediaAssetView.purposeKey_)  String purpose, @JsonKey(name: MediaAssetView.providerKey_)  String provider, @JsonKey(name: MediaAssetView.statusKey_)  String status, @JsonKey(name: MediaAssetView.visibilityKey_)  String visibility, @JsonKey(name: MediaAssetView.contentTypeKey_)  String? contentType, @JsonKey(name: MediaAssetView.byteSizeKey_)  int? byteSize, @JsonKey(name: MediaAssetView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: MediaAssetView.createdAtKey_)  DateTime createdAt, @JsonKey(name: MediaAssetView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: MediaAssetView.variantsKey_)  List<MediaObjectView>? variants, @JsonKey(name: MediaAssetView.playbackIdKey_)  String? playbackId, @JsonKey(name: MediaAssetView.isPublicKey_)  bool isPublic, @JsonKey(name: MediaAssetView.nicheTagsKey_)  List<String>? nicheTags)?  $default,) {final _that = this;
switch (_that) {
case _MediaAssetView() when $default != null:
return $default(_that.id,_that.ownerUserId,_that.kind,_that.purpose,_that.provider,_that.status,_that.visibility,_that.contentType,_that.byteSize,_that.meta,_that.createdAt,_that.updatedAt,_that.variants,_that.playbackId,_that.isPublic,_that.nicheTags);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MediaAssetView extends MediaAssetView {
  const _MediaAssetView({@JsonKey(name: MediaAssetView.idKey_) required this.id, @JsonKey(name: MediaAssetView.ownerUserIdKey_) required this.ownerUserId, @JsonKey(name: MediaAssetView.kindKey_) required this.kind, @JsonKey(name: MediaAssetView.purposeKey_) required this.purpose, @JsonKey(name: MediaAssetView.providerKey_) required this.provider, @JsonKey(name: MediaAssetView.statusKey_) required this.status, @JsonKey(name: MediaAssetView.visibilityKey_) required this.visibility, @JsonKey(name: MediaAssetView.contentTypeKey_) this.contentType, @JsonKey(name: MediaAssetView.byteSizeKey_) this.byteSize, @JsonKey(name: MediaAssetView.metaKey_) final  Map<String, dynamic>? meta, @JsonKey(name: MediaAssetView.createdAtKey_) required this.createdAt, @JsonKey(name: MediaAssetView.updatedAtKey_) required this.updatedAt, @JsonKey(name: MediaAssetView.variantsKey_) final  List<MediaObjectView>? variants, @JsonKey(name: MediaAssetView.playbackIdKey_) this.playbackId, @JsonKey(name: MediaAssetView.isPublicKey_) this.isPublic = false, @JsonKey(name: MediaAssetView.nicheTagsKey_) final  List<String>? nicheTags}): _meta = meta,_variants = variants,_nicheTags = nicheTags,super._();
  factory _MediaAssetView.fromJson(Map<String, dynamic> json) => _$MediaAssetViewFromJson(json);

/// id
@override@JsonKey(name: MediaAssetView.idKey_) final  String id;
/// ownerUserId
@override@JsonKey(name: MediaAssetView.ownerUserIdKey_) final  String ownerUserId;
/// kind
@override@JsonKey(name: MediaAssetView.kindKey_) final  String kind;
/// purpose
@override@JsonKey(name: MediaAssetView.purposeKey_) final  String purpose;
/// provider
@override@JsonKey(name: MediaAssetView.providerKey_) final  String provider;
/// status
@override@JsonKey(name: MediaAssetView.statusKey_) final  String status;
/// visibility
@override@JsonKey(name: MediaAssetView.visibilityKey_) final  String visibility;
/// contentType
@override@JsonKey(name: MediaAssetView.contentTypeKey_) final  String? contentType;
/// byteSize
@override@JsonKey(name: MediaAssetView.byteSizeKey_) final  int? byteSize;
/// meta
 final  Map<String, dynamic>? _meta;
/// meta
@override@JsonKey(name: MediaAssetView.metaKey_) Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: MediaAssetView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: MediaAssetView.updatedAtKey_) final  DateTime updatedAt;
/// variants
 final  List<MediaObjectView>? _variants;
/// variants
@override@JsonKey(name: MediaAssetView.variantsKey_) List<MediaObjectView>? get variants {
  final value = _variants;
  if (value == null) return null;
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// playbackId
@override@JsonKey(name: MediaAssetView.playbackIdKey_) final  String? playbackId;
/// isPublic
@override@JsonKey(name: MediaAssetView.isPublicKey_) final  bool isPublic;
/// nicheTags
 final  List<String>? _nicheTags;
/// nicheTags
@override@JsonKey(name: MediaAssetView.nicheTagsKey_) List<String>? get nicheTags {
  final value = _nicheTags;
  if (value == null) return null;
  if (_nicheTags is EqualUnmodifiableListView) return _nicheTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MediaAssetView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaAssetViewCopyWith<_MediaAssetView> get copyWith => __$MediaAssetViewCopyWithImpl<_MediaAssetView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaAssetViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaAssetView&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.status, status) || other.status == status)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._variants, _variants)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other._nicheTags, _nicheTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerUserId,kind,purpose,provider,status,visibility,contentType,byteSize,const DeepCollectionEquality().hash(_meta),createdAt,updatedAt,const DeepCollectionEquality().hash(_variants),playbackId,isPublic,const DeepCollectionEquality().hash(_nicheTags));

@override
String toString() {
  return 'MediaAssetView(id: $id, ownerUserId: $ownerUserId, kind: $kind, purpose: $purpose, provider: $provider, status: $status, visibility: $visibility, contentType: $contentType, byteSize: $byteSize, meta: $meta, createdAt: $createdAt, updatedAt: $updatedAt, variants: $variants, playbackId: $playbackId, isPublic: $isPublic, nicheTags: $nicheTags)';
}


}

/// @nodoc
abstract mixin class _$MediaAssetViewCopyWith<$Res> implements $MediaAssetViewCopyWith<$Res> {
  factory _$MediaAssetViewCopyWith(_MediaAssetView value, $Res Function(_MediaAssetView) _then) = __$MediaAssetViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MediaAssetView.idKey_) String id,@JsonKey(name: MediaAssetView.ownerUserIdKey_) String ownerUserId,@JsonKey(name: MediaAssetView.kindKey_) String kind,@JsonKey(name: MediaAssetView.purposeKey_) String purpose,@JsonKey(name: MediaAssetView.providerKey_) String provider,@JsonKey(name: MediaAssetView.statusKey_) String status,@JsonKey(name: MediaAssetView.visibilityKey_) String visibility,@JsonKey(name: MediaAssetView.contentTypeKey_) String? contentType,@JsonKey(name: MediaAssetView.byteSizeKey_) int? byteSize,@JsonKey(name: MediaAssetView.metaKey_) Map<String, dynamic>? meta,@JsonKey(name: MediaAssetView.createdAtKey_) DateTime createdAt,@JsonKey(name: MediaAssetView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: MediaAssetView.variantsKey_) List<MediaObjectView>? variants,@JsonKey(name: MediaAssetView.playbackIdKey_) String? playbackId,@JsonKey(name: MediaAssetView.isPublicKey_) bool isPublic,@JsonKey(name: MediaAssetView.nicheTagsKey_) List<String>? nicheTags
});




}
/// @nodoc
class __$MediaAssetViewCopyWithImpl<$Res>
    implements _$MediaAssetViewCopyWith<$Res> {
  __$MediaAssetViewCopyWithImpl(this._self, this._then);

  final _MediaAssetView _self;
  final $Res Function(_MediaAssetView) _then;

/// Create a copy of MediaAssetView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerUserId = null,Object? kind = null,Object? purpose = null,Object? provider = null,Object? status = null,Object? visibility = null,Object? contentType = freezed,Object? byteSize = freezed,Object? meta = freezed,Object? createdAt = null,Object? updatedAt = null,Object? variants = freezed,Object? playbackId = freezed,Object? isPublic = null,Object? nicheTags = freezed,}) {
  return _then(_MediaAssetView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,byteSize: freezed == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,variants: freezed == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<MediaObjectView>?,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,nicheTags: freezed == nicheTags ? _self._nicheTags : nicheTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
