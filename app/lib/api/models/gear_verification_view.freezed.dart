// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gear_verification_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GearVerificationView {

/// id
@JsonKey(name: GearVerificationView.idKey_) String get id;/// category
@JsonKey(name: GearVerificationView.categoryKey_) GearCategory get category;/// status
@JsonKey(name: GearVerificationView.statusKey_) VerificationStatus get status;/// make
@JsonKey(name: GearVerificationView.makeKey_) String? get make;/// model
@JsonKey(name: GearVerificationView.modelKey_) String? get model;/// serialHint
@JsonKey(name: GearVerificationView.serialHintKey_) String? get serialHint;/// sensorSize
@JsonKey(name: GearVerificationView.sensorSizeKey_) SensorSize? get sensorSize;/// apertureType
@JsonKey(name: GearVerificationView.apertureTypeKey_) ApertureType? get apertureType;/// minFocalMm
@JsonKey(name: GearVerificationView.minFocalMmKey_) String? get minFocalMm;/// maxFocalMm
@JsonKey(name: GearVerificationView.maxFocalMmKey_) String? get maxFocalMm;/// maxAperture
@JsonKey(name: GearVerificationView.maxApertureKey_) String? get maxAperture;/// reviewReason
@JsonKey(name: GearVerificationView.reviewReasonKey_) String? get reviewReason;/// verifiedAt
@JsonKey(name: GearVerificationView.verifiedAtKey_) DateTime? get verifiedAt;/// createdAt
@JsonKey(name: GearVerificationView.createdAtKey_) DateTime get createdAt;
/// Create a copy of GearVerificationView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GearVerificationViewCopyWith<GearVerificationView> get copyWith => _$GearVerificationViewCopyWithImpl<GearVerificationView>(this as GearVerificationView, _$identity);

  /// Serializes this GearVerificationView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GearVerificationView&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialHint, serialHint) || other.serialHint == serialHint)&&(identical(other.sensorSize, sensorSize) || other.sensorSize == sensorSize)&&(identical(other.apertureType, apertureType) || other.apertureType == apertureType)&&(identical(other.minFocalMm, minFocalMm) || other.minFocalMm == minFocalMm)&&(identical(other.maxFocalMm, maxFocalMm) || other.maxFocalMm == maxFocalMm)&&(identical(other.maxAperture, maxAperture) || other.maxAperture == maxAperture)&&(identical(other.reviewReason, reviewReason) || other.reviewReason == reviewReason)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,status,make,model,serialHint,sensorSize,apertureType,minFocalMm,maxFocalMm,maxAperture,reviewReason,verifiedAt,createdAt);

@override
String toString() {
  return 'GearVerificationView(id: $id, category: $category, status: $status, make: $make, model: $model, serialHint: $serialHint, sensorSize: $sensorSize, apertureType: $apertureType, minFocalMm: $minFocalMm, maxFocalMm: $maxFocalMm, maxAperture: $maxAperture, reviewReason: $reviewReason, verifiedAt: $verifiedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GearVerificationViewCopyWith<$Res>  {
  factory $GearVerificationViewCopyWith(GearVerificationView value, $Res Function(GearVerificationView) _then) = _$GearVerificationViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GearVerificationView.idKey_) String id,@JsonKey(name: GearVerificationView.categoryKey_) GearCategory category,@JsonKey(name: GearVerificationView.statusKey_) VerificationStatus status,@JsonKey(name: GearVerificationView.makeKey_) String? make,@JsonKey(name: GearVerificationView.modelKey_) String? model,@JsonKey(name: GearVerificationView.serialHintKey_) String? serialHint,@JsonKey(name: GearVerificationView.sensorSizeKey_) SensorSize? sensorSize,@JsonKey(name: GearVerificationView.apertureTypeKey_) ApertureType? apertureType,@JsonKey(name: GearVerificationView.minFocalMmKey_) String? minFocalMm,@JsonKey(name: GearVerificationView.maxFocalMmKey_) String? maxFocalMm,@JsonKey(name: GearVerificationView.maxApertureKey_) String? maxAperture,@JsonKey(name: GearVerificationView.reviewReasonKey_) String? reviewReason,@JsonKey(name: GearVerificationView.verifiedAtKey_) DateTime? verifiedAt,@JsonKey(name: GearVerificationView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$GearVerificationViewCopyWithImpl<$Res>
    implements $GearVerificationViewCopyWith<$Res> {
  _$GearVerificationViewCopyWithImpl(this._self, this._then);

  final GearVerificationView _self;
  final $Res Function(GearVerificationView) _then;

/// Create a copy of GearVerificationView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? status = null,Object? make = freezed,Object? model = freezed,Object? serialHint = freezed,Object? sensorSize = freezed,Object? apertureType = freezed,Object? minFocalMm = freezed,Object? maxFocalMm = freezed,Object? maxAperture = freezed,Object? reviewReason = freezed,Object? verifiedAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GearCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialHint: freezed == serialHint ? _self.serialHint : serialHint // ignore: cast_nullable_to_non_nullable
as String?,sensorSize: freezed == sensorSize ? _self.sensorSize : sensorSize // ignore: cast_nullable_to_non_nullable
as SensorSize?,apertureType: freezed == apertureType ? _self.apertureType : apertureType // ignore: cast_nullable_to_non_nullable
as ApertureType?,minFocalMm: freezed == minFocalMm ? _self.minFocalMm : minFocalMm // ignore: cast_nullable_to_non_nullable
as String?,maxFocalMm: freezed == maxFocalMm ? _self.maxFocalMm : maxFocalMm // ignore: cast_nullable_to_non_nullable
as String?,maxAperture: freezed == maxAperture ? _self.maxAperture : maxAperture // ignore: cast_nullable_to_non_nullable
as String?,reviewReason: freezed == reviewReason ? _self.reviewReason : reviewReason // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GearVerificationView].
extension GearVerificationViewPatterns on GearVerificationView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GearVerificationView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GearVerificationView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GearVerificationView value)  $default,){
final _that = this;
switch (_that) {
case _GearVerificationView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GearVerificationView value)?  $default,){
final _that = this;
switch (_that) {
case _GearVerificationView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GearVerificationView.idKey_)  String id, @JsonKey(name: GearVerificationView.categoryKey_)  GearCategory category, @JsonKey(name: GearVerificationView.statusKey_)  VerificationStatus status, @JsonKey(name: GearVerificationView.makeKey_)  String? make, @JsonKey(name: GearVerificationView.modelKey_)  String? model, @JsonKey(name: GearVerificationView.serialHintKey_)  String? serialHint, @JsonKey(name: GearVerificationView.sensorSizeKey_)  SensorSize? sensorSize, @JsonKey(name: GearVerificationView.apertureTypeKey_)  ApertureType? apertureType, @JsonKey(name: GearVerificationView.minFocalMmKey_)  String? minFocalMm, @JsonKey(name: GearVerificationView.maxFocalMmKey_)  String? maxFocalMm, @JsonKey(name: GearVerificationView.maxApertureKey_)  String? maxAperture, @JsonKey(name: GearVerificationView.reviewReasonKey_)  String? reviewReason, @JsonKey(name: GearVerificationView.verifiedAtKey_)  DateTime? verifiedAt, @JsonKey(name: GearVerificationView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GearVerificationView() when $default != null:
return $default(_that.id,_that.category,_that.status,_that.make,_that.model,_that.serialHint,_that.sensorSize,_that.apertureType,_that.minFocalMm,_that.maxFocalMm,_that.maxAperture,_that.reviewReason,_that.verifiedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GearVerificationView.idKey_)  String id, @JsonKey(name: GearVerificationView.categoryKey_)  GearCategory category, @JsonKey(name: GearVerificationView.statusKey_)  VerificationStatus status, @JsonKey(name: GearVerificationView.makeKey_)  String? make, @JsonKey(name: GearVerificationView.modelKey_)  String? model, @JsonKey(name: GearVerificationView.serialHintKey_)  String? serialHint, @JsonKey(name: GearVerificationView.sensorSizeKey_)  SensorSize? sensorSize, @JsonKey(name: GearVerificationView.apertureTypeKey_)  ApertureType? apertureType, @JsonKey(name: GearVerificationView.minFocalMmKey_)  String? minFocalMm, @JsonKey(name: GearVerificationView.maxFocalMmKey_)  String? maxFocalMm, @JsonKey(name: GearVerificationView.maxApertureKey_)  String? maxAperture, @JsonKey(name: GearVerificationView.reviewReasonKey_)  String? reviewReason, @JsonKey(name: GearVerificationView.verifiedAtKey_)  DateTime? verifiedAt, @JsonKey(name: GearVerificationView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GearVerificationView():
return $default(_that.id,_that.category,_that.status,_that.make,_that.model,_that.serialHint,_that.sensorSize,_that.apertureType,_that.minFocalMm,_that.maxFocalMm,_that.maxAperture,_that.reviewReason,_that.verifiedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GearVerificationView.idKey_)  String id, @JsonKey(name: GearVerificationView.categoryKey_)  GearCategory category, @JsonKey(name: GearVerificationView.statusKey_)  VerificationStatus status, @JsonKey(name: GearVerificationView.makeKey_)  String? make, @JsonKey(name: GearVerificationView.modelKey_)  String? model, @JsonKey(name: GearVerificationView.serialHintKey_)  String? serialHint, @JsonKey(name: GearVerificationView.sensorSizeKey_)  SensorSize? sensorSize, @JsonKey(name: GearVerificationView.apertureTypeKey_)  ApertureType? apertureType, @JsonKey(name: GearVerificationView.minFocalMmKey_)  String? minFocalMm, @JsonKey(name: GearVerificationView.maxFocalMmKey_)  String? maxFocalMm, @JsonKey(name: GearVerificationView.maxApertureKey_)  String? maxAperture, @JsonKey(name: GearVerificationView.reviewReasonKey_)  String? reviewReason, @JsonKey(name: GearVerificationView.verifiedAtKey_)  DateTime? verifiedAt, @JsonKey(name: GearVerificationView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GearVerificationView() when $default != null:
return $default(_that.id,_that.category,_that.status,_that.make,_that.model,_that.serialHint,_that.sensorSize,_that.apertureType,_that.minFocalMm,_that.maxFocalMm,_that.maxAperture,_that.reviewReason,_that.verifiedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GearVerificationView extends GearVerificationView {
  const _GearVerificationView({@JsonKey(name: GearVerificationView.idKey_) required this.id, @JsonKey(name: GearVerificationView.categoryKey_) required this.category, @JsonKey(name: GearVerificationView.statusKey_) required this.status, @JsonKey(name: GearVerificationView.makeKey_) this.make, @JsonKey(name: GearVerificationView.modelKey_) this.model, @JsonKey(name: GearVerificationView.serialHintKey_) this.serialHint, @JsonKey(name: GearVerificationView.sensorSizeKey_) this.sensorSize, @JsonKey(name: GearVerificationView.apertureTypeKey_) this.apertureType, @JsonKey(name: GearVerificationView.minFocalMmKey_) this.minFocalMm, @JsonKey(name: GearVerificationView.maxFocalMmKey_) this.maxFocalMm, @JsonKey(name: GearVerificationView.maxApertureKey_) this.maxAperture, @JsonKey(name: GearVerificationView.reviewReasonKey_) this.reviewReason, @JsonKey(name: GearVerificationView.verifiedAtKey_) this.verifiedAt, @JsonKey(name: GearVerificationView.createdAtKey_) required this.createdAt}): super._();
  factory _GearVerificationView.fromJson(Map<String, dynamic> json) => _$GearVerificationViewFromJson(json);

/// id
@override@JsonKey(name: GearVerificationView.idKey_) final  String id;
/// category
@override@JsonKey(name: GearVerificationView.categoryKey_) final  GearCategory category;
/// status
@override@JsonKey(name: GearVerificationView.statusKey_) final  VerificationStatus status;
/// make
@override@JsonKey(name: GearVerificationView.makeKey_) final  String? make;
/// model
@override@JsonKey(name: GearVerificationView.modelKey_) final  String? model;
/// serialHint
@override@JsonKey(name: GearVerificationView.serialHintKey_) final  String? serialHint;
/// sensorSize
@override@JsonKey(name: GearVerificationView.sensorSizeKey_) final  SensorSize? sensorSize;
/// apertureType
@override@JsonKey(name: GearVerificationView.apertureTypeKey_) final  ApertureType? apertureType;
/// minFocalMm
@override@JsonKey(name: GearVerificationView.minFocalMmKey_) final  String? minFocalMm;
/// maxFocalMm
@override@JsonKey(name: GearVerificationView.maxFocalMmKey_) final  String? maxFocalMm;
/// maxAperture
@override@JsonKey(name: GearVerificationView.maxApertureKey_) final  String? maxAperture;
/// reviewReason
@override@JsonKey(name: GearVerificationView.reviewReasonKey_) final  String? reviewReason;
/// verifiedAt
@override@JsonKey(name: GearVerificationView.verifiedAtKey_) final  DateTime? verifiedAt;
/// createdAt
@override@JsonKey(name: GearVerificationView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of GearVerificationView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GearVerificationViewCopyWith<_GearVerificationView> get copyWith => __$GearVerificationViewCopyWithImpl<_GearVerificationView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GearVerificationViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GearVerificationView&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialHint, serialHint) || other.serialHint == serialHint)&&(identical(other.sensorSize, sensorSize) || other.sensorSize == sensorSize)&&(identical(other.apertureType, apertureType) || other.apertureType == apertureType)&&(identical(other.minFocalMm, minFocalMm) || other.minFocalMm == minFocalMm)&&(identical(other.maxFocalMm, maxFocalMm) || other.maxFocalMm == maxFocalMm)&&(identical(other.maxAperture, maxAperture) || other.maxAperture == maxAperture)&&(identical(other.reviewReason, reviewReason) || other.reviewReason == reviewReason)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,status,make,model,serialHint,sensorSize,apertureType,minFocalMm,maxFocalMm,maxAperture,reviewReason,verifiedAt,createdAt);

@override
String toString() {
  return 'GearVerificationView(id: $id, category: $category, status: $status, make: $make, model: $model, serialHint: $serialHint, sensorSize: $sensorSize, apertureType: $apertureType, minFocalMm: $minFocalMm, maxFocalMm: $maxFocalMm, maxAperture: $maxAperture, reviewReason: $reviewReason, verifiedAt: $verifiedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GearVerificationViewCopyWith<$Res> implements $GearVerificationViewCopyWith<$Res> {
  factory _$GearVerificationViewCopyWith(_GearVerificationView value, $Res Function(_GearVerificationView) _then) = __$GearVerificationViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GearVerificationView.idKey_) String id,@JsonKey(name: GearVerificationView.categoryKey_) GearCategory category,@JsonKey(name: GearVerificationView.statusKey_) VerificationStatus status,@JsonKey(name: GearVerificationView.makeKey_) String? make,@JsonKey(name: GearVerificationView.modelKey_) String? model,@JsonKey(name: GearVerificationView.serialHintKey_) String? serialHint,@JsonKey(name: GearVerificationView.sensorSizeKey_) SensorSize? sensorSize,@JsonKey(name: GearVerificationView.apertureTypeKey_) ApertureType? apertureType,@JsonKey(name: GearVerificationView.minFocalMmKey_) String? minFocalMm,@JsonKey(name: GearVerificationView.maxFocalMmKey_) String? maxFocalMm,@JsonKey(name: GearVerificationView.maxApertureKey_) String? maxAperture,@JsonKey(name: GearVerificationView.reviewReasonKey_) String? reviewReason,@JsonKey(name: GearVerificationView.verifiedAtKey_) DateTime? verifiedAt,@JsonKey(name: GearVerificationView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$GearVerificationViewCopyWithImpl<$Res>
    implements _$GearVerificationViewCopyWith<$Res> {
  __$GearVerificationViewCopyWithImpl(this._self, this._then);

  final _GearVerificationView _self;
  final $Res Function(_GearVerificationView) _then;

/// Create a copy of GearVerificationView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? status = null,Object? make = freezed,Object? model = freezed,Object? serialHint = freezed,Object? sensorSize = freezed,Object? apertureType = freezed,Object? minFocalMm = freezed,Object? maxFocalMm = freezed,Object? maxAperture = freezed,Object? reviewReason = freezed,Object? verifiedAt = freezed,Object? createdAt = null,}) {
  return _then(_GearVerificationView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GearCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialHint: freezed == serialHint ? _self.serialHint : serialHint // ignore: cast_nullable_to_non_nullable
as String?,sensorSize: freezed == sensorSize ? _self.sensorSize : sensorSize // ignore: cast_nullable_to_non_nullable
as SensorSize?,apertureType: freezed == apertureType ? _self.apertureType : apertureType // ignore: cast_nullable_to_non_nullable
as ApertureType?,minFocalMm: freezed == minFocalMm ? _self.minFocalMm : minFocalMm // ignore: cast_nullable_to_non_nullable
as String?,maxFocalMm: freezed == maxFocalMm ? _self.maxFocalMm : maxFocalMm // ignore: cast_nullable_to_non_nullable
as String?,maxAperture: freezed == maxAperture ? _self.maxAperture : maxAperture // ignore: cast_nullable_to_non_nullable
as String?,reviewReason: freezed == reviewReason ? _self.reviewReason : reviewReason // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
