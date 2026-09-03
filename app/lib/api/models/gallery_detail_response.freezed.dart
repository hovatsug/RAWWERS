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
@JsonKey(name: GalleryDetailResponse.itemsKey_) List<GalleryItemView> get items;
/// Create a copy of GalleryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryDetailResponseCopyWith<GalleryDetailResponse> get copyWith => _$GalleryDetailResponseCopyWithImpl<GalleryDetailResponse>(this as GalleryDetailResponse, _$identity);

  /// Serializes this GalleryDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryDetailResponse&&(identical(other.gallery, gallery) || other.gallery == gallery)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gallery,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'GalleryDetailResponse(gallery: $gallery, items: $items)';
}


}

/// @nodoc
abstract mixin class $GalleryDetailResponseCopyWith<$Res>  {
  factory $GalleryDetailResponseCopyWith(GalleryDetailResponse value, $Res Function(GalleryDetailResponse) _then) = _$GalleryDetailResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GalleryDetailResponse.galleryKey_) ProofGalleryResponse gallery,@JsonKey(name: GalleryDetailResponse.itemsKey_) List<GalleryItemView> items
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
@pragma('vm:prefer-inline') @override $Res call({Object? gallery = null,Object? items = null,}) {
  return _then(_self.copyWith(
gallery: null == gallery ? _self.gallery : gallery // ignore: cast_nullable_to_non_nullable
as ProofGalleryResponse,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GalleryItemView>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GalleryDetailResponse.galleryKey_)  ProofGalleryResponse gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_)  List<GalleryItemView> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryDetailResponse() when $default != null:
return $default(_that.gallery,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GalleryDetailResponse.galleryKey_)  ProofGalleryResponse gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_)  List<GalleryItemView> items)  $default,) {final _that = this;
switch (_that) {
case _GalleryDetailResponse():
return $default(_that.gallery,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GalleryDetailResponse.galleryKey_)  ProofGalleryResponse gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_)  List<GalleryItemView> items)?  $default,) {final _that = this;
switch (_that) {
case _GalleryDetailResponse() when $default != null:
return $default(_that.gallery,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GalleryDetailResponse extends GalleryDetailResponse {
  const _GalleryDetailResponse({@JsonKey(name: GalleryDetailResponse.galleryKey_) required this.gallery, @JsonKey(name: GalleryDetailResponse.itemsKey_) required final  List<GalleryItemView> items}): _items = items,super._();
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryDetailResponse&&(identical(other.gallery, gallery) || other.gallery == gallery)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gallery,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'GalleryDetailResponse(gallery: $gallery, items: $items)';
}


}

/// @nodoc
abstract mixin class _$GalleryDetailResponseCopyWith<$Res> implements $GalleryDetailResponseCopyWith<$Res> {
  factory _$GalleryDetailResponseCopyWith(_GalleryDetailResponse value, $Res Function(_GalleryDetailResponse) _then) = __$GalleryDetailResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GalleryDetailResponse.galleryKey_) ProofGalleryResponse gallery,@JsonKey(name: GalleryDetailResponse.itemsKey_) List<GalleryItemView> items
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
@override @pragma('vm:prefer-inline') $Res call({Object? gallery = null,Object? items = null,}) {
  return _then(_GalleryDetailResponse(
gallery: null == gallery ? _self.gallery : gallery // ignore: cast_nullable_to_non_nullable
as ProofGalleryResponse,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GalleryItemView>,
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
