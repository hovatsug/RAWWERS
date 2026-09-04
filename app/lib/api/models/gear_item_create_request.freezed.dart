// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gear_item_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GearItemCreateRequest {

/// category
@JsonKey(name: GearItemCreateRequest.categoryKey_) GearCategory get category;/// brand
@JsonKey(name: GearItemCreateRequest.brandKey_) String? get brand;/// model
@JsonKey(name: GearItemCreateRequest.modelKey_) String? get model;/// serialNumber
@JsonKey(name: GearItemCreateRequest.serialNumberKey_) String? get serialNumber;/// purchaseDate
@JsonKey(name: GearItemCreateRequest.purchaseDateKey_) DateTime? get purchaseDate;/// notes
@JsonKey(name: GearItemCreateRequest.notesKey_) String? get notes;/// metadata
@JsonKey(name: GearItemCreateRequest.metadataKey_) Map<String, dynamic>? get metadata;
/// Create a copy of GearItemCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GearItemCreateRequestCopyWith<GearItemCreateRequest> get copyWith => _$GearItemCreateRequestCopyWithImpl<GearItemCreateRequest>(this as GearItemCreateRequest, _$identity);

  /// Serializes this GearItemCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GearItemCreateRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,brand,model,serialNumber,purchaseDate,notes,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'GearItemCreateRequest(category: $category, brand: $brand, model: $model, serialNumber: $serialNumber, purchaseDate: $purchaseDate, notes: $notes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $GearItemCreateRequestCopyWith<$Res>  {
  factory $GearItemCreateRequestCopyWith(GearItemCreateRequest value, $Res Function(GearItemCreateRequest) _then) = _$GearItemCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GearItemCreateRequest.categoryKey_) GearCategory category,@JsonKey(name: GearItemCreateRequest.brandKey_) String? brand,@JsonKey(name: GearItemCreateRequest.modelKey_) String? model,@JsonKey(name: GearItemCreateRequest.serialNumberKey_) String? serialNumber,@JsonKey(name: GearItemCreateRequest.purchaseDateKey_) DateTime? purchaseDate,@JsonKey(name: GearItemCreateRequest.notesKey_) String? notes,@JsonKey(name: GearItemCreateRequest.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$GearItemCreateRequestCopyWithImpl<$Res>
    implements $GearItemCreateRequestCopyWith<$Res> {
  _$GearItemCreateRequestCopyWithImpl(this._self, this._then);

  final GearItemCreateRequest _self;
  final $Res Function(GearItemCreateRequest) _then;

/// Create a copy of GearItemCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? brand = freezed,Object? model = freezed,Object? serialNumber = freezed,Object? purchaseDate = freezed,Object? notes = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GearCategory,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GearItemCreateRequest].
extension GearItemCreateRequestPatterns on GearItemCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GearItemCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GearItemCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GearItemCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _GearItemCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GearItemCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _GearItemCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GearItemCreateRequest.categoryKey_)  GearCategory category, @JsonKey(name: GearItemCreateRequest.brandKey_)  String? brand, @JsonKey(name: GearItemCreateRequest.modelKey_)  String? model, @JsonKey(name: GearItemCreateRequest.serialNumberKey_)  String? serialNumber, @JsonKey(name: GearItemCreateRequest.purchaseDateKey_)  DateTime? purchaseDate, @JsonKey(name: GearItemCreateRequest.notesKey_)  String? notes, @JsonKey(name: GearItemCreateRequest.metadataKey_)  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GearItemCreateRequest() when $default != null:
return $default(_that.category,_that.brand,_that.model,_that.serialNumber,_that.purchaseDate,_that.notes,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GearItemCreateRequest.categoryKey_)  GearCategory category, @JsonKey(name: GearItemCreateRequest.brandKey_)  String? brand, @JsonKey(name: GearItemCreateRequest.modelKey_)  String? model, @JsonKey(name: GearItemCreateRequest.serialNumberKey_)  String? serialNumber, @JsonKey(name: GearItemCreateRequest.purchaseDateKey_)  DateTime? purchaseDate, @JsonKey(name: GearItemCreateRequest.notesKey_)  String? notes, @JsonKey(name: GearItemCreateRequest.metadataKey_)  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _GearItemCreateRequest():
return $default(_that.category,_that.brand,_that.model,_that.serialNumber,_that.purchaseDate,_that.notes,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GearItemCreateRequest.categoryKey_)  GearCategory category, @JsonKey(name: GearItemCreateRequest.brandKey_)  String? brand, @JsonKey(name: GearItemCreateRequest.modelKey_)  String? model, @JsonKey(name: GearItemCreateRequest.serialNumberKey_)  String? serialNumber, @JsonKey(name: GearItemCreateRequest.purchaseDateKey_)  DateTime? purchaseDate, @JsonKey(name: GearItemCreateRequest.notesKey_)  String? notes, @JsonKey(name: GearItemCreateRequest.metadataKey_)  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _GearItemCreateRequest() when $default != null:
return $default(_that.category,_that.brand,_that.model,_that.serialNumber,_that.purchaseDate,_that.notes,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GearItemCreateRequest extends GearItemCreateRequest {
  const _GearItemCreateRequest({@JsonKey(name: GearItemCreateRequest.categoryKey_) required this.category, @JsonKey(name: GearItemCreateRequest.brandKey_) this.brand, @JsonKey(name: GearItemCreateRequest.modelKey_) this.model, @JsonKey(name: GearItemCreateRequest.serialNumberKey_) this.serialNumber, @JsonKey(name: GearItemCreateRequest.purchaseDateKey_) this.purchaseDate, @JsonKey(name: GearItemCreateRequest.notesKey_) this.notes, @JsonKey(name: GearItemCreateRequest.metadataKey_) final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _GearItemCreateRequest.fromJson(Map<String, dynamic> json) => _$GearItemCreateRequestFromJson(json);

/// category
@override@JsonKey(name: GearItemCreateRequest.categoryKey_) final  GearCategory category;
/// brand
@override@JsonKey(name: GearItemCreateRequest.brandKey_) final  String? brand;
/// model
@override@JsonKey(name: GearItemCreateRequest.modelKey_) final  String? model;
/// serialNumber
@override@JsonKey(name: GearItemCreateRequest.serialNumberKey_) final  String? serialNumber;
/// purchaseDate
@override@JsonKey(name: GearItemCreateRequest.purchaseDateKey_) final  DateTime? purchaseDate;
/// notes
@override@JsonKey(name: GearItemCreateRequest.notesKey_) final  String? notes;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: GearItemCreateRequest.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GearItemCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GearItemCreateRequestCopyWith<_GearItemCreateRequest> get copyWith => __$GearItemCreateRequestCopyWithImpl<_GearItemCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GearItemCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GearItemCreateRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,brand,model,serialNumber,purchaseDate,notes,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'GearItemCreateRequest(category: $category, brand: $brand, model: $model, serialNumber: $serialNumber, purchaseDate: $purchaseDate, notes: $notes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$GearItemCreateRequestCopyWith<$Res> implements $GearItemCreateRequestCopyWith<$Res> {
  factory _$GearItemCreateRequestCopyWith(_GearItemCreateRequest value, $Res Function(_GearItemCreateRequest) _then) = __$GearItemCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GearItemCreateRequest.categoryKey_) GearCategory category,@JsonKey(name: GearItemCreateRequest.brandKey_) String? brand,@JsonKey(name: GearItemCreateRequest.modelKey_) String? model,@JsonKey(name: GearItemCreateRequest.serialNumberKey_) String? serialNumber,@JsonKey(name: GearItemCreateRequest.purchaseDateKey_) DateTime? purchaseDate,@JsonKey(name: GearItemCreateRequest.notesKey_) String? notes,@JsonKey(name: GearItemCreateRequest.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$GearItemCreateRequestCopyWithImpl<$Res>
    implements _$GearItemCreateRequestCopyWith<$Res> {
  __$GearItemCreateRequestCopyWithImpl(this._self, this._then);

  final _GearItemCreateRequest _self;
  final $Res Function(_GearItemCreateRequest) _then;

/// Create a copy of GearItemCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? brand = freezed,Object? model = freezed,Object? serialNumber = freezed,Object? purchaseDate = freezed,Object? notes = freezed,Object? metadata = freezed,}) {
  return _then(_GearItemCreateRequest(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GearCategory,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
