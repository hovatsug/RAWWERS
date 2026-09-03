// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduling_policy_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulingPolicyView {

/// proUserId
@JsonKey(name: SchedulingPolicyView.proUserIdKey_) String get proUserId;/// slotLengthMinutes
@JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_) int get slotLengthMinutes;/// bufferBeforeMinutes
@JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_) int get bufferBeforeMinutes;/// bufferAfterMinutes
@JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_) int get bufferAfterMinutes;/// advanceNoticeHours
@JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_) int get advanceNoticeHours;/// maxBookingsPerDay
@JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_) int? get maxBookingsPerDay;/// updatedAt
@JsonKey(name: SchedulingPolicyView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of SchedulingPolicyView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulingPolicyViewCopyWith<SchedulingPolicyView> get copyWith => _$SchedulingPolicyViewCopyWithImpl<SchedulingPolicyView>(this as SchedulingPolicyView, _$identity);

  /// Serializes this SchedulingPolicyView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulingPolicyView&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.slotLengthMinutes, slotLengthMinutes) || other.slotLengthMinutes == slotLengthMinutes)&&(identical(other.bufferBeforeMinutes, bufferBeforeMinutes) || other.bufferBeforeMinutes == bufferBeforeMinutes)&&(identical(other.bufferAfterMinutes, bufferAfterMinutes) || other.bufferAfterMinutes == bufferAfterMinutes)&&(identical(other.advanceNoticeHours, advanceNoticeHours) || other.advanceNoticeHours == advanceNoticeHours)&&(identical(other.maxBookingsPerDay, maxBookingsPerDay) || other.maxBookingsPerDay == maxBookingsPerDay)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,slotLengthMinutes,bufferBeforeMinutes,bufferAfterMinutes,advanceNoticeHours,maxBookingsPerDay,updatedAt);

@override
String toString() {
  return 'SchedulingPolicyView(proUserId: $proUserId, slotLengthMinutes: $slotLengthMinutes, bufferBeforeMinutes: $bufferBeforeMinutes, bufferAfterMinutes: $bufferAfterMinutes, advanceNoticeHours: $advanceNoticeHours, maxBookingsPerDay: $maxBookingsPerDay, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SchedulingPolicyViewCopyWith<$Res>  {
  factory $SchedulingPolicyViewCopyWith(SchedulingPolicyView value, $Res Function(SchedulingPolicyView) _then) = _$SchedulingPolicyViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SchedulingPolicyView.proUserIdKey_) String proUserId,@JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_) int slotLengthMinutes,@JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_) int bufferBeforeMinutes,@JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_) int bufferAfterMinutes,@JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_) int advanceNoticeHours,@JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_) int? maxBookingsPerDay,@JsonKey(name: SchedulingPolicyView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$SchedulingPolicyViewCopyWithImpl<$Res>
    implements $SchedulingPolicyViewCopyWith<$Res> {
  _$SchedulingPolicyViewCopyWithImpl(this._self, this._then);

  final SchedulingPolicyView _self;
  final $Res Function(SchedulingPolicyView) _then;

/// Create a copy of SchedulingPolicyView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? slotLengthMinutes = null,Object? bufferBeforeMinutes = null,Object? bufferAfterMinutes = null,Object? advanceNoticeHours = null,Object? maxBookingsPerDay = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,slotLengthMinutes: null == slotLengthMinutes ? _self.slotLengthMinutes : slotLengthMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferBeforeMinutes: null == bufferBeforeMinutes ? _self.bufferBeforeMinutes : bufferBeforeMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferAfterMinutes: null == bufferAfterMinutes ? _self.bufferAfterMinutes : bufferAfterMinutes // ignore: cast_nullable_to_non_nullable
as int,advanceNoticeHours: null == advanceNoticeHours ? _self.advanceNoticeHours : advanceNoticeHours // ignore: cast_nullable_to_non_nullable
as int,maxBookingsPerDay: freezed == maxBookingsPerDay ? _self.maxBookingsPerDay : maxBookingsPerDay // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulingPolicyView].
extension SchedulingPolicyViewPatterns on SchedulingPolicyView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulingPolicyView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulingPolicyView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulingPolicyView value)  $default,){
final _that = this;
switch (_that) {
case _SchedulingPolicyView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulingPolicyView value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulingPolicyView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingPolicyView.proUserIdKey_)  String proUserId, @JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_)  int slotLengthMinutes, @JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_)  int bufferBeforeMinutes, @JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_)  int bufferAfterMinutes, @JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_)  int advanceNoticeHours, @JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_)  int? maxBookingsPerDay, @JsonKey(name: SchedulingPolicyView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulingPolicyView() when $default != null:
return $default(_that.proUserId,_that.slotLengthMinutes,_that.bufferBeforeMinutes,_that.bufferAfterMinutes,_that.advanceNoticeHours,_that.maxBookingsPerDay,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingPolicyView.proUserIdKey_)  String proUserId, @JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_)  int slotLengthMinutes, @JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_)  int bufferBeforeMinutes, @JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_)  int bufferAfterMinutes, @JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_)  int advanceNoticeHours, @JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_)  int? maxBookingsPerDay, @JsonKey(name: SchedulingPolicyView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SchedulingPolicyView():
return $default(_that.proUserId,_that.slotLengthMinutes,_that.bufferBeforeMinutes,_that.bufferAfterMinutes,_that.advanceNoticeHours,_that.maxBookingsPerDay,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SchedulingPolicyView.proUserIdKey_)  String proUserId, @JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_)  int slotLengthMinutes, @JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_)  int bufferBeforeMinutes, @JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_)  int bufferAfterMinutes, @JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_)  int advanceNoticeHours, @JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_)  int? maxBookingsPerDay, @JsonKey(name: SchedulingPolicyView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SchedulingPolicyView() when $default != null:
return $default(_that.proUserId,_that.slotLengthMinutes,_that.bufferBeforeMinutes,_that.bufferAfterMinutes,_that.advanceNoticeHours,_that.maxBookingsPerDay,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SchedulingPolicyView extends SchedulingPolicyView {
  const _SchedulingPolicyView({@JsonKey(name: SchedulingPolicyView.proUserIdKey_) required this.proUserId, @JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_) required this.slotLengthMinutes, @JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_) required this.bufferBeforeMinutes, @JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_) required this.bufferAfterMinutes, @JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_) required this.advanceNoticeHours, @JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_) this.maxBookingsPerDay, @JsonKey(name: SchedulingPolicyView.updatedAtKey_) required this.updatedAt}): super._();
  factory _SchedulingPolicyView.fromJson(Map<String, dynamic> json) => _$SchedulingPolicyViewFromJson(json);

/// proUserId
@override@JsonKey(name: SchedulingPolicyView.proUserIdKey_) final  String proUserId;
/// slotLengthMinutes
@override@JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_) final  int slotLengthMinutes;
/// bufferBeforeMinutes
@override@JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_) final  int bufferBeforeMinutes;
/// bufferAfterMinutes
@override@JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_) final  int bufferAfterMinutes;
/// advanceNoticeHours
@override@JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_) final  int advanceNoticeHours;
/// maxBookingsPerDay
@override@JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_) final  int? maxBookingsPerDay;
/// updatedAt
@override@JsonKey(name: SchedulingPolicyView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of SchedulingPolicyView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulingPolicyViewCopyWith<_SchedulingPolicyView> get copyWith => __$SchedulingPolicyViewCopyWithImpl<_SchedulingPolicyView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulingPolicyViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulingPolicyView&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.slotLengthMinutes, slotLengthMinutes) || other.slotLengthMinutes == slotLengthMinutes)&&(identical(other.bufferBeforeMinutes, bufferBeforeMinutes) || other.bufferBeforeMinutes == bufferBeforeMinutes)&&(identical(other.bufferAfterMinutes, bufferAfterMinutes) || other.bufferAfterMinutes == bufferAfterMinutes)&&(identical(other.advanceNoticeHours, advanceNoticeHours) || other.advanceNoticeHours == advanceNoticeHours)&&(identical(other.maxBookingsPerDay, maxBookingsPerDay) || other.maxBookingsPerDay == maxBookingsPerDay)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,slotLengthMinutes,bufferBeforeMinutes,bufferAfterMinutes,advanceNoticeHours,maxBookingsPerDay,updatedAt);

@override
String toString() {
  return 'SchedulingPolicyView(proUserId: $proUserId, slotLengthMinutes: $slotLengthMinutes, bufferBeforeMinutes: $bufferBeforeMinutes, bufferAfterMinutes: $bufferAfterMinutes, advanceNoticeHours: $advanceNoticeHours, maxBookingsPerDay: $maxBookingsPerDay, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SchedulingPolicyViewCopyWith<$Res> implements $SchedulingPolicyViewCopyWith<$Res> {
  factory _$SchedulingPolicyViewCopyWith(_SchedulingPolicyView value, $Res Function(_SchedulingPolicyView) _then) = __$SchedulingPolicyViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SchedulingPolicyView.proUserIdKey_) String proUserId,@JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_) int slotLengthMinutes,@JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_) int bufferBeforeMinutes,@JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_) int bufferAfterMinutes,@JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_) int advanceNoticeHours,@JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_) int? maxBookingsPerDay,@JsonKey(name: SchedulingPolicyView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$SchedulingPolicyViewCopyWithImpl<$Res>
    implements _$SchedulingPolicyViewCopyWith<$Res> {
  __$SchedulingPolicyViewCopyWithImpl(this._self, this._then);

  final _SchedulingPolicyView _self;
  final $Res Function(_SchedulingPolicyView) _then;

/// Create a copy of SchedulingPolicyView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? slotLengthMinutes = null,Object? bufferBeforeMinutes = null,Object? bufferAfterMinutes = null,Object? advanceNoticeHours = null,Object? maxBookingsPerDay = freezed,Object? updatedAt = null,}) {
  return _then(_SchedulingPolicyView(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,slotLengthMinutes: null == slotLengthMinutes ? _self.slotLengthMinutes : slotLengthMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferBeforeMinutes: null == bufferBeforeMinutes ? _self.bufferBeforeMinutes : bufferBeforeMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferAfterMinutes: null == bufferAfterMinutes ? _self.bufferAfterMinutes : bufferAfterMinutes // ignore: cast_nullable_to_non_nullable
as int,advanceNoticeHours: null == advanceNoticeHours ? _self.advanceNoticeHours : advanceNoticeHours // ignore: cast_nullable_to_non_nullable
as int,maxBookingsPerDay: freezed == maxBookingsPerDay ? _self.maxBookingsPerDay : maxBookingsPerDay // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
