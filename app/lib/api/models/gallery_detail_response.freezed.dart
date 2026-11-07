// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GalleryDetailResponse {

/// gallery
@JsonKey(name: GalleryDetailResponse.galleryKey_) ProofGalleryResponse get gallery;/// items
@JsonKey(name: GalleryDetailResponse.itemsKey_) List<GalleryItemView> get items;/// addonWindowEndsAt
@JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_) DateTime? get addonWindowEndsAt;/// addonOpen
@JsonKey(name: GalleryDetailResponse.addonOpenKey_) bool get addonOpen;/// chosenMediaAssetIds
@JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_) List<String>? get chosenMediaAssetIds;
/// Create a copy of GalleryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryDetailResponseCopyWith<GalleryDetailResponse> get copyWith => _$GalleryDetailResponseCopyWithImpl<GalleryDetailResponse>(this as GalleryDetailResponse, _$identity);

  /// Serializes this GalleryDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryDetailResponse&&(identical(other.gallery, gallery) || other.gallery == gallery)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.addonWindowEndsAt, addonWindowEndsAt) || other.addonWindowEndsAt == addonWindowEndsAt)&&(identical(other.addonOpen, addonOpen) || other.addonOpen == addonOpen)&&const DeepCollectionEquality().equals(other.chosenMediaAssetIds, chosenMediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gallery,const DeepCollectionEquality().hash(items),addonWindowEndsAt,addonOpen,const DeepCollectionEquality().hash(chosenMediaAssetIds));

@override
String toString() {
  return 'GalleryDetailResponse(gallery: $gallery, items: $items, addonWindowEndsAt: $addonWindowEndsAt, addonOpen: $addonOpen, chosenMediaAssetIds: $chosenMediaAssetIds)';
}


}

/// @nodoc
abstract mixin class $GalleryDetailResponseCopyWith<$Res>  {
  factory $GalleryDetailResponseCopyWith(GalleryDetailResponse value, $Res Function(GalleryDetailResponse) _then) = _$GalleryDetailResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GalleryDetailResponse.galleryKey_) ProofGalleryResponse gallery,@JsonKey(name: GalleryDetailResponse.itemsKey_) List<GalleryItemView> items,@JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_) DateTime? addonWindowEndsAt,@JsonKey(name: GalleryDetailResponse.addonOpenKey_) bool addonOpen,@JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_) List<String>? chosenMediaAssetIds
});


$ProofGalleryResponseCopyWith<$Res> get gallery;

}
/// @nodoc
class _$GalleryDetailResponseCopyWithImpl<$Res>
    implements $GalleryDetailResponseCopyWith<$Res> {
  _$GalleryDetailResponseCopyWithImpl(this._self, this._then);

  final GalleryDetailResponse _self;
  final $Res Function(GalleryDetailResponse) _then;

/// Create a copy of GalleryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gallery = null,Object? items = null,Object? addonWindowEndsAt = freezed,Object? addonOpen = null,Object? chosenMediaAssetIds = freezed,}) {
  return _then(_self.copyWith(
gallery: null == gallery ? _self.gallery : gallery // ignore: cast_nullable_to_non_nullable
as ProofGalleryResponse,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GalleryItemView>,addonWindowEndsAt: freezed == addonWindowEndsAt ? _self.addonWindowEndsAt : addonWindowEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,addonOpen: null == addonOpen ? _self.addonOpen : addonOpen // ignore: cast_nullable_to_non_nullable
as bool,chosenMediaAssetIds: freezed == chosenMediaAssetIds ? _self.chosenMediaAssetIds : chosenMediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of GalleryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProofGalleryResponseCopyWith<$Res> get gallery {
  
  return $ProofGalleryResponseCopyWith<$Res>(_self.gallery, (value) {
    return _then(_self.copyWith(gallery: value));
  });
}
}


/// Adds pattern-matching-related methods to [GalleryDetailResponse].
extension GalleryDetailResponsePatterns on GalleryDetailResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryDetailResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryDetailResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryDetailResponse value)  $default,){
final _that = this;
switch (_that) {
case _GalleryDetailResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryDetailResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryDetailResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GalleryDetailResponse.galleryKey_)  ProofGalleryResponse gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_)  List<GalleryItemView> items, @JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_)  DateTime? addonWindowEndsAt, @JsonKey(name: GalleryDetailResponse.addonOpenKey_)  bool addonOpen, @JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_)  List<String>? chosenMediaAssetIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryDetailResponse() when $default != null:
return $default(_that.gallery,_that.items,_that.addonWindowEndsAt,_that.addonOpen,_that.chosenMediaAssetIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GalleryDetailResponse.galleryKey_)  ProofGalleryResponse gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_)  List<GalleryItemView> items, @JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_)  DateTime? addonWindowEndsAt, @JsonKey(name: GalleryDetailResponse.addonOpenKey_)  bool addonOpen, @JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_)  List<String>? chosenMediaAssetIds)  $default,) {final _that = this;
switch (_that) {
case _GalleryDetailResponse():
return $default(_that.gallery,_that.items,_that.addonWindowEndsAt,_that.addonOpen,_that.chosenMediaAssetIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GalleryDetailResponse.galleryKey_)  ProofGalleryResponse gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_)  List<GalleryItemView> items, @JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_)  DateTime? addonWindowEndsAt, @JsonKey(name: GalleryDetailResponse.addonOpenKey_)  bool addonOpen, @JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_)  List<String>? chosenMediaAssetIds)?  $default,) {final _that = this;
switch (_that) {
case _GalleryDetailResponse() when $default != null:
return $default(_that.gallery,_that.items,_that.addonWindowEndsAt,_that.addonOpen,_that.chosenMediaAssetIds);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GalleryDetailResponse extends GalleryDetailResponse {
  const _GalleryDetailResponse({@JsonKey(name: GalleryDetailResponse.galleryKey_) required this.gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_) required final  List<GalleryItemView> items, @JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_) this.addonWindowEndsAt, @JsonKey(name: GalleryDetailResponse.addonOpenKey_) this.addonOpen = false, @JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_) final  List<String>? chosenMediaAssetIds}): _items = items,_chosenMediaAssetIds = chosenMediaAssetIds,super._();
  factory _GalleryDetailResponse.fromJson(Map<String, dynamic> json) => _$GalleryDetailResponseFromJson(json);

/// gallery
@override@JsonKey(name: GalleryDetailResponse.galleryKey_) final  ProofGalleryResponse gallery;
/// items
 final  List<GalleryItemView> _items;
/// items
@override@JsonKey(name: GalleryDetailResponse.itemsKey_) List<GalleryItemView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// addonWindowEndsAt
@override@JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_) final  DateTime? addonWindowEndsAt;
/// addonOpen
@override@JsonKey(name: GalleryDetailResponse.addonOpenKey_) final  bool addonOpen;
/// chosenMediaAssetIds
 final  List<String>? _chosenMediaAssetIds;
/// chosenMediaAssetIds
@override@JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_) List<String>? get chosenMediaAssetIds {
  final value = _chosenMediaAssetIds;
  if (value == null) return null;
  if (_chosenMediaAssetIds is EqualUnmodifiableListView) return _chosenMediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GalleryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryDetailResponseCopyWith<_GalleryDetailResponse> get copyWith => __$GalleryDetailResponseCopyWithImpl<_GalleryDetailResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryDetailResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryDetailResponse&&(identical(other.gallery, gallery) || other.gallery == gallery)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.addonWindowEndsAt, addonWindowEndsAt) || other.addonWindowEndsAt == addonWindowEndsAt)&&(identical(other.addonOpen, addonOpen) || other.addonOpen == addonOpen)&&const DeepCollectionEquality().equals(other._chosenMediaAssetIds, _chosenMediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gallery,const DeepCollectionEquality().hash(_items),addonWindowEndsAt,addonOpen,const DeepCollectionEquality().hash(_chosenMediaAssetIds));

@override
String toString() {
  return 'GalleryDetailResponse(gallery: $gallery, items: $items, addonWindowEndsAt: $addonWindowEndsAt, addonOpen: $addonOpen, chosenMediaAssetIds: $chosenMediaAssetIds)';
}


}

/// @nodoc
abstract mixin class _$GalleryDetailResponseCopyWith<$Res> implements $GalleryDetailResponseCopyWith<$Res> {
  factory _$GalleryDetailResponseCopyWith(_GalleryDetailResponse value, $Res Function(_GalleryDetailResponse) _then) = __$GalleryDetailResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GalleryDetailResponse.galleryKey_) ProofGalleryResponse gallery,@JsonKey(name: GalleryDetailResponse.itemsKey_) List<GalleryItemView> items,@JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_) DateTime? addonWindowEndsAt,@JsonKey(name: GalleryDetailResponse.addonOpenKey_) bool addonOpen,@JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_) List<String>? chosenMediaAssetIds
});


@override $ProofGalleryResponseCopyWith<$Res> get gallery;

}
/// @nodoc
class __$GalleryDetailResponseCopyWithImpl<$Res>
    implements _$GalleryDetailResponseCopyWith<$Res> {
  __$GalleryDetailResponseCopyWithImpl(this._self, this._then);

  final _GalleryDetailResponse _self;
  final $Res Function(_GalleryDetailResponse) _then;

/// Create a copy of GalleryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gallery = null,Object? items = null,Object? addonWindowEndsAt = freezed,Object? addonOpen = null,Object? chosenMediaAssetIds = freezed,}) {
  return _then(_GalleryDetailResponse(
gallery: null == gallery ? _self.gallery : gallery // ignore: cast_nullable_to_non_nullable
as ProofGalleryResponse,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GalleryItemView>,addonWindowEndsAt: freezed == addonWindowEndsAt ? _self.addonWindowEndsAt : addonWindowEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,addonOpen: null == addonOpen ? _self.addonOpen : addonOpen // ignore: cast_nullable_to_non_nullable
as bool,chosenMediaAssetIds: freezed == chosenMediaAssetIds ? _self._chosenMediaAssetIds : chosenMediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of GalleryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProofGalleryResponseCopyWith<$Res> get gallery {
  
  return $ProofGalleryResponseCopyWith<$Res>(_self.gallery, (value) {
    return _then(_self.copyWith(gallery: value));
  });
}
}

// dart format on
