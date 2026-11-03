// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_browse_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfBrowseItem {

/// id
@JsonKey(name: ShelfBrowseItem.idKey_) String get id;/// title
@JsonKey(name: ShelfBrowseItem.titleKey_) String get title;/// brand
@JsonKey(name: ShelfBrowseItem.brandKey_) String? get brand;/// category
@JsonKey(name: ShelfBrowseItem.categoryKey_) String get category;/// description
@JsonKey(name: ShelfBrowseItem.descriptionKey_) String? get description;/// imageUrl
@JsonKey(name: ShelfBrowseItem.imageUrlKey_) String? get imageUrl;/// level
@JsonKey(name: ShelfBrowseItem.levelKey_) int get level;/// priceRaww
@JsonKey(name: ShelfBrowseItem.priceRawwKey_) int get priceRaww;/// inStock
@JsonKey(name: ShelfBrowseItem.inStockKey_) bool get inStock;/// fitsYourGear
@JsonKey(name: ShelfBrowseItem.fitsYourGearKey_) bool get fitsYourGear;/// wished
@JsonKey(name: ShelfBrowseItem.wishedKey_) bool get wished;/// affordable
@JsonKey(name: ShelfBrowseItem.affordableKey_) bool get affordable;/// locked
@JsonKey(name: ShelfBrowseItem.lockedKey_) bool get locked;
/// Create a copy of ShelfBrowseItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfBrowseItemCopyWith<ShelfBrowseItem> get copyWith => _$ShelfBrowseItemCopyWithImpl<ShelfBrowseItem>(this as ShelfBrowseItem, _$identity);

  /// Serializes this ShelfBrowseItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfBrowseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.level, level) || other.level == level)&&(identical(other.priceRaww, priceRaww) || other.priceRaww == priceRaww)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.fitsYourGear, fitsYourGear) || other.fitsYourGear == fitsYourGear)&&(identical(other.wished, wished) || other.wished == wished)&&(identical(other.affordable, affordable) || other.affordable == affordable)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,brand,category,description,imageUrl,level,priceRaww,inStock,fitsYourGear,wished,affordable,locked);

@override
String toString() {
  return 'ShelfBrowseItem(id: $id, title: $title, brand: $brand, category: $category, description: $description, imageUrl: $imageUrl, level: $level, priceRaww: $priceRaww, inStock: $inStock, fitsYourGear: $fitsYourGear, wished: $wished, affordable: $affordable, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $ShelfBrowseItemCopyWith<$Res>  {
  factory $ShelfBrowseItemCopyWith(ShelfBrowseItem value, $Res Function(ShelfBrowseItem) _then) = _$ShelfBrowseItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfBrowseItem.idKey_) String id,@JsonKey(name: ShelfBrowseItem.titleKey_) String title,@JsonKey(name: ShelfBrowseItem.brandKey_) String? brand,@JsonKey(name: ShelfBrowseItem.categoryKey_) String category,@JsonKey(name: ShelfBrowseItem.descriptionKey_) String? description,@JsonKey(name: ShelfBrowseItem.imageUrlKey_) String? imageUrl,@JsonKey(name: ShelfBrowseItem.levelKey_) int level,@JsonKey(name: ShelfBrowseItem.priceRawwKey_) int priceRaww,@JsonKey(name: ShelfBrowseItem.inStockKey_) bool inStock,@JsonKey(name: ShelfBrowseItem.fitsYourGearKey_) bool fitsYourGear,@JsonKey(name: ShelfBrowseItem.wishedKey_) bool wished,@JsonKey(name: ShelfBrowseItem.affordableKey_) bool affordable,@JsonKey(name: ShelfBrowseItem.lockedKey_) bool locked
});




}
/// @nodoc
class _$ShelfBrowseItemCopyWithImpl<$Res>
    implements $ShelfBrowseItemCopyWith<$Res> {
  _$ShelfBrowseItemCopyWithImpl(this._self, this._then);

  final ShelfBrowseItem _self;
  final $Res Function(ShelfBrowseItem) _then;

/// Create a copy of ShelfBrowseItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? brand = freezed,Object? category = null,Object? description = freezed,Object? imageUrl = freezed,Object? level = null,Object? priceRaww = null,Object? inStock = null,Object? fitsYourGear = null,Object? wished = null,Object? affordable = null,Object? locked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,priceRaww: null == priceRaww ? _self.priceRaww : priceRaww // ignore: cast_nullable_to_non_nullable
as int,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,fitsYourGear: null == fitsYourGear ? _self.fitsYourGear : fitsYourGear // ignore: cast_nullable_to_non_nullable
as bool,wished: null == wished ? _self.wished : wished // ignore: cast_nullable_to_non_nullable
as bool,affordable: null == affordable ? _self.affordable : affordable // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfBrowseItem].
extension ShelfBrowseItemPatterns on ShelfBrowseItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfBrowseItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfBrowseItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfBrowseItem value)  $default,){
final _that = this;
switch (_that) {
case _ShelfBrowseItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfBrowseItem value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfBrowseItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfBrowseItem.idKey_)  String id, @JsonKey(name: ShelfBrowseItem.titleKey_)  String title, @JsonKey(name: ShelfBrowseItem.brandKey_)  String? brand, @JsonKey(name: ShelfBrowseItem.categoryKey_)  String category, @JsonKey(name: ShelfBrowseItem.descriptionKey_)  String? description, @JsonKey(name: ShelfBrowseItem.imageUrlKey_)  String? imageUrl, @JsonKey(name: ShelfBrowseItem.levelKey_)  int level, @JsonKey(name: ShelfBrowseItem.priceRawwKey_)  int priceRaww, @JsonKey(name: ShelfBrowseItem.inStockKey_)  bool inStock, @JsonKey(name: ShelfBrowseItem.fitsYourGearKey_)  bool fitsYourGear, @JsonKey(name: ShelfBrowseItem.wishedKey_)  bool wished, @JsonKey(name: ShelfBrowseItem.affordableKey_)  bool affordable, @JsonKey(name: ShelfBrowseItem.lockedKey_)  bool locked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfBrowseItem() when $default != null:
return $default(_that.id,_that.title,_that.brand,_that.category,_that.description,_that.imageUrl,_that.level,_that.priceRaww,_that.inStock,_that.fitsYourGear,_that.wished,_that.affordable,_that.locked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfBrowseItem.idKey_)  String id, @JsonKey(name: ShelfBrowseItem.titleKey_)  String title, @JsonKey(name: ShelfBrowseItem.brandKey_)  String? brand, @JsonKey(name: ShelfBrowseItem.categoryKey_)  String category, @JsonKey(name: ShelfBrowseItem.descriptionKey_)  String? description, @JsonKey(name: ShelfBrowseItem.imageUrlKey_)  String? imageUrl, @JsonKey(name: ShelfBrowseItem.levelKey_)  int level, @JsonKey(name: ShelfBrowseItem.priceRawwKey_)  int priceRaww, @JsonKey(name: ShelfBrowseItem.inStockKey_)  bool inStock, @JsonKey(name: ShelfBrowseItem.fitsYourGearKey_)  bool fitsYourGear, @JsonKey(name: ShelfBrowseItem.wishedKey_)  bool wished, @JsonKey(name: ShelfBrowseItem.affordableKey_)  bool affordable, @JsonKey(name: ShelfBrowseItem.lockedKey_)  bool locked)  $default,) {final _that = this;
switch (_that) {
case _ShelfBrowseItem():
return $default(_that.id,_that.title,_that.brand,_that.category,_that.description,_that.imageUrl,_that.level,_that.priceRaww,_that.inStock,_that.fitsYourGear,_that.wished,_that.affordable,_that.locked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfBrowseItem.idKey_)  String id, @JsonKey(name: ShelfBrowseItem.titleKey_)  String title, @JsonKey(name: ShelfBrowseItem.brandKey_)  String? brand, @JsonKey(name: ShelfBrowseItem.categoryKey_)  String category, @JsonKey(name: ShelfBrowseItem.descriptionKey_)  String? description, @JsonKey(name: ShelfBrowseItem.imageUrlKey_)  String? imageUrl, @JsonKey(name: ShelfBrowseItem.levelKey_)  int level, @JsonKey(name: ShelfBrowseItem.priceRawwKey_)  int priceRaww, @JsonKey(name: ShelfBrowseItem.inStockKey_)  bool inStock, @JsonKey(name: ShelfBrowseItem.fitsYourGearKey_)  bool fitsYourGear, @JsonKey(name: ShelfBrowseItem.wishedKey_)  bool wished, @JsonKey(name: ShelfBrowseItem.affordableKey_)  bool affordable, @JsonKey(name: ShelfBrowseItem.lockedKey_)  bool locked)?  $default,) {final _that = this;
switch (_that) {
case _ShelfBrowseItem() when $default != null:
return $default(_that.id,_that.title,_that.brand,_that.category,_that.description,_that.imageUrl,_that.level,_that.priceRaww,_that.inStock,_that.fitsYourGear,_that.wished,_that.affordable,_that.locked);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfBrowseItem extends ShelfBrowseItem {
  const _ShelfBrowseItem({@JsonKey(name: ShelfBrowseItem.idKey_) required this.id, @JsonKey(name: ShelfBrowseItem.titleKey_) required this.title, @JsonKey(name: ShelfBrowseItem.brandKey_) this.brand, @JsonKey(name: ShelfBrowseItem.categoryKey_) required this.category, @JsonKey(name: ShelfBrowseItem.descriptionKey_) this.description, @JsonKey(name: ShelfBrowseItem.imageUrlKey_) this.imageUrl, @JsonKey(name: ShelfBrowseItem.levelKey_) required this.level, @JsonKey(name: ShelfBrowseItem.priceRawwKey_) required this.priceRaww, @JsonKey(name: ShelfBrowseItem.inStockKey_) required this.inStock, @JsonKey(name: ShelfBrowseItem.fitsYourGearKey_) required this.fitsYourGear, @JsonKey(name: ShelfBrowseItem.wishedKey_) required this.wished, @JsonKey(name: ShelfBrowseItem.affordableKey_) required this.affordable, @JsonKey(name: ShelfBrowseItem.lockedKey_) required this.locked}): super._();
  factory _ShelfBrowseItem.fromJson(Map<String, dynamic> json) => _$ShelfBrowseItemFromJson(json);

/// id
@override@JsonKey(name: ShelfBrowseItem.idKey_) final  String id;
/// title
@override@JsonKey(name: ShelfBrowseItem.titleKey_) final  String title;
/// brand
@override@JsonKey(name: ShelfBrowseItem.brandKey_) final  String? brand;
/// category
@override@JsonKey(name: ShelfBrowseItem.categoryKey_) final  String category;
/// description
@override@JsonKey(name: ShelfBrowseItem.descriptionKey_) final  String? description;
/// imageUrl
@override@JsonKey(name: ShelfBrowseItem.imageUrlKey_) final  String? imageUrl;
/// level
@override@JsonKey(name: ShelfBrowseItem.levelKey_) final  int level;
/// priceRaww
@override@JsonKey(name: ShelfBrowseItem.priceRawwKey_) final  int priceRaww;
/// inStock
@override@JsonKey(name: ShelfBrowseItem.inStockKey_) final  bool inStock;
/// fitsYourGear
@override@JsonKey(name: ShelfBrowseItem.fitsYourGearKey_) final  bool fitsYourGear;
/// wished
@override@JsonKey(name: ShelfBrowseItem.wishedKey_) final  bool wished;
/// affordable
@override@JsonKey(name: ShelfBrowseItem.affordableKey_) final  bool affordable;
/// locked
@override@JsonKey(name: ShelfBrowseItem.lockedKey_) final  bool locked;

/// Create a copy of ShelfBrowseItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfBrowseItemCopyWith<_ShelfBrowseItem> get copyWith => __$ShelfBrowseItemCopyWithImpl<_ShelfBrowseItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfBrowseItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfBrowseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.level, level) || other.level == level)&&(identical(other.priceRaww, priceRaww) || other.priceRaww == priceRaww)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.fitsYourGear, fitsYourGear) || other.fitsYourGear == fitsYourGear)&&(identical(other.wished, wished) || other.wished == wished)&&(identical(other.affordable, affordable) || other.affordable == affordable)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,brand,category,description,imageUrl,level,priceRaww,inStock,fitsYourGear,wished,affordable,locked);

@override
String toString() {
  return 'ShelfBrowseItem(id: $id, title: $title, brand: $brand, category: $category, description: $description, imageUrl: $imageUrl, level: $level, priceRaww: $priceRaww, inStock: $inStock, fitsYourGear: $fitsYourGear, wished: $wished, affordable: $affordable, locked: $locked)';
}


}

/// @nodoc
abstract mixin class _$ShelfBrowseItemCopyWith<$Res> implements $ShelfBrowseItemCopyWith<$Res> {
  factory _$ShelfBrowseItemCopyWith(_ShelfBrowseItem value, $Res Function(_ShelfBrowseItem) _then) = __$ShelfBrowseItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfBrowseItem.idKey_) String id,@JsonKey(name: ShelfBrowseItem.titleKey_) String title,@JsonKey(name: ShelfBrowseItem.brandKey_) String? brand,@JsonKey(name: ShelfBrowseItem.categoryKey_) String category,@JsonKey(name: ShelfBrowseItem.descriptionKey_) String? description,@JsonKey(name: ShelfBrowseItem.imageUrlKey_) String? imageUrl,@JsonKey(name: ShelfBrowseItem.levelKey_) int level,@JsonKey(name: ShelfBrowseItem.priceRawwKey_) int priceRaww,@JsonKey(name: ShelfBrowseItem.inStockKey_) bool inStock,@JsonKey(name: ShelfBrowseItem.fitsYourGearKey_) bool fitsYourGear,@JsonKey(name: ShelfBrowseItem.wishedKey_) bool wished,@JsonKey(name: ShelfBrowseItem.affordableKey_) bool affordable,@JsonKey(name: ShelfBrowseItem.lockedKey_) bool locked
});




}
/// @nodoc
class __$ShelfBrowseItemCopyWithImpl<$Res>
    implements _$ShelfBrowseItemCopyWith<$Res> {
  __$ShelfBrowseItemCopyWithImpl(this._self, this._then);

  final _ShelfBrowseItem _self;
  final $Res Function(_ShelfBrowseItem) _then;

/// Create a copy of ShelfBrowseItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? brand = freezed,Object? category = null,Object? description = freezed,Object? imageUrl = freezed,Object? level = null,Object? priceRaww = null,Object? inStock = null,Object? fitsYourGear = null,Object? wished = null,Object? affordable = null,Object? locked = null,}) {
  return _then(_ShelfBrowseItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,priceRaww: null == priceRaww ? _self.priceRaww : priceRaww // ignore: cast_nullable_to_non_nullable
as int,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,fitsYourGear: null == fitsYourGear ? _self.fitsYourGear : fitsYourGear // ignore: cast_nullable_to_non_nullable
as bool,wished: null == wished ? _self.wished : wished // ignore: cast_nullable_to_non_nullable
as bool,affordable: null == affordable ? _self.affordable : affordable // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
