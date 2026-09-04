// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_pricing_curve_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPricingCurvePoint {

/// photoCount
@JsonKey(name: ProPricingCurvePoint.photoCountKey_) int get photoCount;/// total
@JsonKey(name: ProPricingCurvePoint.totalKey_) String get total;/// perPhoto
@JsonKey(name: ProPricingCurvePoint.perPhotoKey_) String get perPhoto;
/// Create a copy of ProPricingCurvePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPricingCurvePointCopyWith<ProPricingCurvePoint> get copyWith => _$ProPricingCurvePointCopyWithImpl<ProPricingCurvePoint>(this as ProPricingCurvePoint, _$identity);

  /// Serializes this ProPricingCurvePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPricingCurvePoint&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.total, total) || other.total == total)&&(identical(other.perPhoto, perPhoto) || other.perPhoto == perPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,photoCount,total,perPhoto);

@override
String toString() {
  return 'ProPricingCurvePoint(photoCount: $photoCount, total: $total, perPhoto: $perPhoto)';
}


}

/// @nodoc
abstract mixin class $ProPricingCurvePointCopyWith<$Res>  {
  factory $ProPricingCurvePointCopyWith(ProPricingCurvePoint value, $Res Function(ProPricingCurvePoint) _then) = _$ProPricingCurvePointCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPricingCurvePoint.photoCountKey_) int photoCount,@JsonKey(name: ProPricingCurvePoint.totalKey_) String total,@JsonKey(name: ProPricingCurvePoint.perPhotoKey_) String perPhoto
});




}
/// @nodoc
class _$ProPricingCurvePointCopyWithImpl<$Res>
    implements $ProPricingCurvePointCopyWith<$Res> {
  _$ProPricingCurvePointCopyWithImpl(this._self, this._then);

  final ProPricingCurvePoint _self;
  final $Res Function(ProPricingCurvePoint) _then;

/// Create a copy of ProPricingCurvePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photoCount = null,Object? total = null,Object? perPhoto = null,}) {
  return _then(_self.copyWith(
photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,perPhoto: null == perPhoto ? _self.perPhoto : perPhoto // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPricingCurvePoint].
extension ProPricingCurvePointPatterns on ProPricingCurvePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPricingCurvePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPricingCurvePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPricingCurvePoint value)  $default,){
final _that = this;
switch (_that) {
case _ProPricingCurvePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPricingCurvePoint value)?  $default,){
final _that = this;
switch (_that) {
case _ProPricingCurvePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPricingCurvePoint.photoCountKey_)  int photoCount, @JsonKey(name: ProPricingCurvePoint.totalKey_)  String total, @JsonKey(name: ProPricingCurvePoint.perPhotoKey_)  String perPhoto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPricingCurvePoint() when $default != null:
return $default(_that.photoCount,_that.total,_that.perPhoto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPricingCurvePoint.photoCountKey_)  int photoCount, @JsonKey(name: ProPricingCurvePoint.totalKey_)  String total, @JsonKey(name: ProPricingCurvePoint.perPhotoKey_)  String perPhoto)  $default,) {final _that = this;
switch (_that) {
case _ProPricingCurvePoint():
return $default(_that.photoCount,_that.total,_that.perPhoto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPricingCurvePoint.photoCountKey_)  int photoCount, @JsonKey(name: ProPricingCurvePoint.totalKey_)  String total, @JsonKey(name: ProPricingCurvePoint.perPhotoKey_)  String perPhoto)?  $default,) {final _that = this;
switch (_that) {
case _ProPricingCurvePoint() when $default != null:
return $default(_that.photoCount,_that.total,_that.perPhoto);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPricingCurvePoint extends ProPricingCurvePoint {
  const _ProPricingCurvePoint({@JsonKey(name: ProPricingCurvePoint.photoCountKey_) required this.photoCount, @JsonKey(name: ProPricingCurvePoint.totalKey_) required this.total, @JsonKey(name: ProPricingCurvePoint.perPhotoKey_) required this.perPhoto}): super._();
  factory _ProPricingCurvePoint.fromJson(Map<String, dynamic> json) => _$ProPricingCurvePointFromJson(json);

/// photoCount
@override@JsonKey(name: ProPricingCurvePoint.photoCountKey_) final  int photoCount;
/// total
@override@JsonKey(name: ProPricingCurvePoint.totalKey_) final  String total;
/// perPhoto
@override@JsonKey(name: ProPricingCurvePoint.perPhotoKey_) final  String perPhoto;

/// Create a copy of ProPricingCurvePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPricingCurvePointCopyWith<_ProPricingCurvePoint> get copyWith => __$ProPricingCurvePointCopyWithImpl<_ProPricingCurvePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPricingCurvePointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPricingCurvePoint&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.total, total) || other.total == total)&&(identical(other.perPhoto, perPhoto) || other.perPhoto == perPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,photoCount,total,perPhoto);

@override
String toString() {
  return 'ProPricingCurvePoint(photoCount: $photoCount, total: $total, perPhoto: $perPhoto)';
}


}

/// @nodoc
abstract mixin class _$ProPricingCurvePointCopyWith<$Res> implements $ProPricingCurvePointCopyWith<$Res> {
  factory _$ProPricingCurvePointCopyWith(_ProPricingCurvePoint value, $Res Function(_ProPricingCurvePoint) _then) = __$ProPricingCurvePointCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPricingCurvePoint.photoCountKey_) int photoCount,@JsonKey(name: ProPricingCurvePoint.totalKey_) String total,@JsonKey(name: ProPricingCurvePoint.perPhotoKey_) String perPhoto
});




}
/// @nodoc
class __$ProPricingCurvePointCopyWithImpl<$Res>
    implements _$ProPricingCurvePointCopyWith<$Res> {
  __$ProPricingCurvePointCopyWithImpl(this._self, this._then);

  final _ProPricingCurvePoint _self;
  final $Res Function(_ProPricingCurvePoint) _then;

/// Create a copy of ProPricingCurvePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photoCount = null,Object? total = null,Object? perPhoto = null,}) {
  return _then(_ProPricingCurvePoint(
photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,perPhoto: null == perPhoto ? _self.perPhoto : perPhoto // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
