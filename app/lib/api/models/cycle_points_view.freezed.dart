// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_points_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CyclePointsView {

/// cycleId
@JsonKey(name: CyclePointsView.cycleIdKey_) String get cycleId;/// userId
@JsonKey(name: CyclePointsView.userIdKey_) String get userId;/// points
@JsonKey(name: CyclePointsView.pointsKey_) int get points;/// updatedAt
@JsonKey(name: CyclePointsView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of CyclePointsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CyclePointsViewCopyWith<CyclePointsView> get copyWith => _$CyclePointsViewCopyWithImpl<CyclePointsView>(this as CyclePointsView, _$identity);

  /// Serializes this CyclePointsView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CyclePointsView&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.points, points) || other.points == points)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cycleId,userId,points,updatedAt);

@override
String toString() {
  return 'CyclePointsView(cycleId: $cycleId, userId: $userId, points: $points, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CyclePointsViewCopyWith<$Res>  {
  factory $CyclePointsViewCopyWith(CyclePointsView value, $Res Function(CyclePointsView) _then) = _$CyclePointsViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CyclePointsView.cycleIdKey_) String cycleId,@JsonKey(name: CyclePointsView.userIdKey_) String userId,@JsonKey(name: CyclePointsView.pointsKey_) int points,@JsonKey(name: CyclePointsView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$CyclePointsViewCopyWithImpl<$Res>
    implements $CyclePointsViewCopyWith<$Res> {
  _$CyclePointsViewCopyWithImpl(this._self, this._then);

  final CyclePointsView _self;
  final $Res Function(CyclePointsView) _then;

/// Create a copy of CyclePointsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cycleId = null,Object? userId = null,Object? points = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CyclePointsView].
extension CyclePointsViewPatterns on CyclePointsView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CyclePointsView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CyclePointsView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CyclePointsView value)  $default,){
final _that = this;
switch (_that) {
case _CyclePointsView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CyclePointsView value)?  $default,){
final _that = this;
switch (_that) {
case _CyclePointsView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CyclePointsView.cycleIdKey_)  String cycleId, @JsonKey(name: CyclePointsView.userIdKey_)  String userId, @JsonKey(name: CyclePointsView.pointsKey_)  int points, @JsonKey(name: CyclePointsView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CyclePointsView() when $default != null:
return $default(_that.cycleId,_that.userId,_that.points,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CyclePointsView.cycleIdKey_)  String cycleId, @JsonKey(name: CyclePointsView.userIdKey_)  String userId, @JsonKey(name: CyclePointsView.pointsKey_)  int points, @JsonKey(name: CyclePointsView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CyclePointsView():
return $default(_that.cycleId,_that.userId,_that.points,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CyclePointsView.cycleIdKey_)  String cycleId, @JsonKey(name: CyclePointsView.userIdKey_)  String userId, @JsonKey(name: CyclePointsView.pointsKey_)  int points, @JsonKey(name: CyclePointsView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CyclePointsView() when $default != null:
return $default(_that.cycleId,_that.userId,_that.points,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CyclePointsView extends CyclePointsView {
  const _CyclePointsView({@JsonKey(name: CyclePointsView.cycleIdKey_) required this.cycleId, @JsonKey(name: CyclePointsView.userIdKey_) required this.userId, @JsonKey(name: CyclePointsView.pointsKey_) required this.points, @JsonKey(name: CyclePointsView.updatedAtKey_) required this.updatedAt}): super._();
  factory _CyclePointsView.fromJson(Map<String, dynamic> json) => _$CyclePointsViewFromJson(json);

/// cycleId
@override@JsonKey(name: CyclePointsView.cycleIdKey_) final  String cycleId;
/// userId
@override@JsonKey(name: CyclePointsView.userIdKey_) final  String userId;
/// points
@override@JsonKey(name: CyclePointsView.pointsKey_) final  int points;
/// updatedAt
@override@JsonKey(name: CyclePointsView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of CyclePointsView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CyclePointsViewCopyWith<_CyclePointsView> get copyWith => __$CyclePointsViewCopyWithImpl<_CyclePointsView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CyclePointsViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CyclePointsView&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.points, points) || other.points == points)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cycleId,userId,points,updatedAt);

@override
String toString() {
  return 'CyclePointsView(cycleId: $cycleId, userId: $userId, points: $points, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CyclePointsViewCopyWith<$Res> implements $CyclePointsViewCopyWith<$Res> {
  factory _$CyclePointsViewCopyWith(_CyclePointsView value, $Res Function(_CyclePointsView) _then) = __$CyclePointsViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CyclePointsView.cycleIdKey_) String cycleId,@JsonKey(name: CyclePointsView.userIdKey_) String userId,@JsonKey(name: CyclePointsView.pointsKey_) int points,@JsonKey(name: CyclePointsView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$CyclePointsViewCopyWithImpl<$Res>
    implements _$CyclePointsViewCopyWith<$Res> {
  __$CyclePointsViewCopyWithImpl(this._self, this._then);

  final _CyclePointsView _self;
  final $Res Function(_CyclePointsView) _then;

/// Create a copy of CyclePointsView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cycleId = null,Object? userId = null,Object? points = null,Object? updatedAt = null,}) {
  return _then(_CyclePointsView(
cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
