// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gear_item_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GearItemView {

/// id
@JsonKey(name: GearItemView.idKey_) String get id;/// proUserId
@JsonKey(name: GearItemView.proUserIdKey_) String get proUserId;/// category
@JsonKey(name: GearItemView.categoryKey_) GearCategory get category;/// brand
@JsonKey(name: GearItemView.brandKey_) String? get brand;/// model
@JsonKey(name: GearItemView.modelKey_) String? get model;/// serialNumber
@JsonKey(name: GearItemView.serialNumberKey_) String? get serialNumber;/// purchaseDate
@JsonKey(name: GearItemView.purchaseDateKey_) DateTime? get purchaseDate;/// notes
@JsonKey(name: GearItemView.notesKey_) String? get notes;/// meta
@JsonKey(name: GearItemView.metaKey_) Map<String, dynamic>? get meta;/// createdAt
@JsonKey(name: GearItemView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: GearItemView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of GearItemView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GearItemViewCopyWith<GearItemView> get copyWith => _$GearItemViewCopyWithImpl<GearItemView>(this as GearItemView, _$identity);

  /// Serializes this GearItemView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GearItemView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.category, category) || other.category == category)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,category,brand,model,serialNumber,purchaseDate,notes,const DeepCollectionEquality().hash(meta),createdAt,updatedAt);

@override
String toString() {
  return 'GearItemView(id: $id, proUserId: $proUserId, category: $category, brand: $brand, model: $model, serialNumber: $serialNumber, purchaseDate: $purchaseDate, notes: $notes, meta: $meta, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GearItemViewCopyWith<$Res>  {
  factory $GearItemViewCopyWith(GearItemView value, $Res Function(GearItemView) _then) = _$GearItemViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GearItemView.idKey_) String id,@JsonKey(name: GearItemView.proUserIdKey_) String proUserId,@JsonKey(name: GearItemView.categoryKey_) GearCategory category,@JsonKey(name: GearItemView.brandKey_) String? brand,@JsonKey(name: GearItemView.modelKey_) String? model,@JsonKey(name: GearItemView.serialNumberKey_) String? serialNumber,@JsonKey(name: GearItemView.purchaseDateKey_) DateTime? purchaseDate,@JsonKey(name: GearItemView.notesKey_) String? notes,@JsonKey(name: GearItemView.metaKey_) Map<String, dynamic>? meta,@JsonKey(name: GearItemView.createdAtKey_) DateTime createdAt,@JsonKey(name: GearItemView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$GearItemViewCopyWithImpl<$Res>
    implements $GearItemViewCopyWith<$Res> {
  _$GearItemViewCopyWithImpl(this._self, this._then);

  final GearItemView _self;
  final $Res Function(GearItemView) _then;

/// Create a copy of GearItemView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? category = null,Object? brand = freezed,Object? model = freezed,Object? serialNumber = freezed,Object? purchaseDate = freezed,Object? notes = freezed,Object? meta = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GearCategory,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GearItemView].
extension GearItemViewPatterns on GearItemView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GearItemView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GearItemView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GearItemView value)  $default,){
final _that = this;
switch (_that) {
case _GearItemView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GearItemView value)?  $default,){
final _that = this;
switch (_that) {
case _GearItemView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GearItemView.idKey_)  String id, @JsonKey(name: GearItemView.proUserIdKey_)  String proUserId, @JsonKey(name: GearItemView.categoryKey_)  GearCategory category, @JsonKey(name: GearItemView.brandKey_)  String? brand, @JsonKey(name: GearItemView.modelKey_)  String? model, @JsonKey(name: GearItemView.serialNumberKey_)  String? serialNumber, @JsonKey(name: GearItemView.purchaseDateKey_)  DateTime? purchaseDate, @JsonKey(name: GearItemView.notesKey_)  String? notes, @JsonKey(name: GearItemView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: GearItemView.createdAtKey_)  DateTime createdAt, @JsonKey(name: GearItemView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GearItemView() when $default != null:
return $default(_that.id,_that.proUserId,_that.category,_that.brand,_that.model,_that.serialNumber,_that.purchaseDate,_that.notes,_that.meta,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GearItemView.idKey_)  String id, @JsonKey(name: GearItemView.proUserIdKey_)  String proUserId, @JsonKey(name: GearItemView.categoryKey_)  GearCategory category, @JsonKey(name: GearItemView.brandKey_)  String? brand, @JsonKey(name: GearItemView.modelKey_)  String? model, @JsonKey(name: GearItemView.serialNumberKey_)  String? serialNumber, @JsonKey(name: GearItemView.purchaseDateKey_)  DateTime? purchaseDate, @JsonKey(name: GearItemView.notesKey_)  String? notes, @JsonKey(name: GearItemView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: GearItemView.createdAtKey_)  DateTime createdAt, @JsonKey(name: GearItemView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GearItemView():
return $default(_that.id,_that.proUserId,_that.category,_that.brand,_that.model,_that.serialNumber,_that.purchaseDate,_that.notes,_that.meta,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GearItemView.idKey_)  String id, @JsonKey(name: GearItemView.proUserIdKey_)  String proUserId, @JsonKey(name: GearItemView.categoryKey_)  GearCategory category, @JsonKey(name: GearItemView.brandKey_)  String? brand, @JsonKey(name: GearItemView.modelKey_)  String? model, @JsonKey(name: GearItemView.serialNumberKey_)  String? serialNumber, @JsonKey(name: GearItemView.purchaseDateKey_)  DateTime? purchaseDate, @JsonKey(name: GearItemView.notesKey_)  String? notes, @JsonKey(name: GearItemView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: GearItemView.createdAtKey_)  DateTime createdAt, @JsonKey(name: GearItemView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GearItemView() when $default != null:
return $default(_that.id,_that.proUserId,_that.category,_that.brand,_that.model,_that.serialNumber,_that.purchaseDate,_that.notes,_that.meta,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GearItemView extends GearItemView {
  const _GearItemView({@JsonKey(name: GearItemView.idKey_) required this.id, @JsonKey(name: GearItemView.proUserIdKey_) required this.proUserId, @JsonKey(name: GearItemView.categoryKey_) required this.category, @JsonKey(name: GearItemView.brandKey_) this.brand, @JsonKey(name: GearItemView.modelKey_) this.model, @JsonKey(name: GearItemView.serialNumberKey_) this.serialNumber, @JsonKey(name: GearItemView.purchaseDateKey_) this.purchaseDate, @JsonKey(name: GearItemView.notesKey_) this.notes, @JsonKey(name: GearItemView.metaKey_) final  Map<String, dynamic>? meta, @JsonKey(name: GearItemView.createdAtKey_) required this.createdAt, @JsonKey(name: GearItemView.updatedAtKey_) required this.updatedAt}): _meta = meta,super._();
  factory _GearItemView.fromJson(Map<String, dynamic> json) => _$GearItemViewFromJson(json);

/// id
@override@JsonKey(name: GearItemView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: GearItemView.proUserIdKey_) final  String proUserId;
/// category
@override@JsonKey(name: GearItemView.categoryKey_) final  GearCategory category;
/// brand
@override@JsonKey(name: GearItemView.brandKey_) final  String? brand;
/// model
@override@JsonKey(name: GearItemView.modelKey_) final  String? model;
/// serialNumber
@override@JsonKey(name: GearItemView.serialNumberKey_) final  String? serialNumber;
/// purchaseDate
@override@JsonKey(name: GearItemView.purchaseDateKey_) final  DateTime? purchaseDate;
/// notes
@override@JsonKey(name: GearItemView.notesKey_) final  String? notes;
/// meta
 final  Map<String, dynamic>? _meta;
/// meta
@override@JsonKey(name: GearItemView.metaKey_) Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: GearItemView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: GearItemView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of GearItemView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GearItemViewCopyWith<_GearItemView> get copyWith => __$GearItemViewCopyWithImpl<_GearItemView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GearItemViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GearItemView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.category, category) || other.category == category)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,category,brand,model,serialNumber,purchaseDate,notes,const DeepCollectionEquality().hash(_meta),createdAt,updatedAt);

@override
String toString() {
  return 'GearItemView(id: $id, proUserId: $proUserId, category: $category, brand: $brand, model: $model, serialNumber: $serialNumber, purchaseDate: $purchaseDate, notes: $notes, meta: $meta, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GearItemViewCopyWith<$Res> implements $GearItemViewCopyWith<$Res> {
  factory _$GearItemViewCopyWith(_GearItemView value, $Res Function(_GearItemView) _then) = __$GearItemViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GearItemView.idKey_) String id,@JsonKey(name: GearItemView.proUserIdKey_) String proUserId,@JsonKey(name: GearItemView.categoryKey_) GearCategory category,@JsonKey(name: GearItemView.brandKey_) String? brand,@JsonKey(name: GearItemView.modelKey_) String? model,@JsonKey(name: GearItemView.serialNumberKey_) String? serialNumber,@JsonKey(name: GearItemView.purchaseDateKey_) DateTime? purchaseDate,@JsonKey(name: GearItemView.notesKey_) String? notes,@JsonKey(name: GearItemView.metaKey_) Map<String, dynamic>? meta,@JsonKey(name: GearItemView.createdAtKey_) DateTime createdAt,@JsonKey(name: GearItemView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$GearItemViewCopyWithImpl<$Res>
    implements _$GearItemViewCopyWith<$Res> {
  __$GearItemViewCopyWithImpl(this._self, this._then);

  final _GearItemView _self;
  final $Res Function(_GearItemView) _then;

/// Create a copy of GearItemView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? category = null,Object? brand = freezed,Object? model = freezed,Object? serialNumber = freezed,Object? purchaseDate = freezed,Object? notes = freezed,Object? meta = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_GearItemView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GearCategory,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
