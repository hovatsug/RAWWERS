// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduling_policy_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulingPolicyUpdateRequest {

/// slotLengthMinutes
@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_) int get slotLengthMinutes;/// bufferBeforeMinutes
@JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_) int get bufferBeforeMinutes;/// bufferAfterMinutes
@JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_) int get bufferAfterMinutes;/// advanceNoticeHours
@JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_) int get advanceNoticeHours;/// maxBookingsPerDay
@JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_) int? get maxBookingsPerDay;
/// Create a copy of SchedulingPolicyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulingPolicyUpdateRequestCopyWith<SchedulingPolicyUpdateRequest> get copyWith => _$SchedulingPolicyUpdateRequestCopyWithImpl<SchedulingPolicyUpdateRequest>(this as SchedulingPolicyUpdateRequest, _$identity);

  /// Serializes this SchedulingPolicyUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulingPolicyUpdateRequest&&(identical(other.slotLengthMinutes, slotLengthMinutes) || other.slotLengthMinutes == slotLengthMinutes)&&(identical(other.bufferBeforeMinutes, bufferBeforeMinutes) || other.bufferBeforeMinutes == bufferBeforeMinutes)&&(identical(other.bufferAfterMinutes, bufferAfterMinutes) || other.bufferAfterMinutes == bufferAfterMinutes)&&(identical(other.advanceNoticeHours, advanceNoticeHours) || other.advanceNoticeHours == advanceNoticeHours)&&(identical(other.maxBookingsPerDay, maxBookingsPerDay) || other.maxBookingsPerDay == maxBookingsPerDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotLengthMinutes,bufferBeforeMinutes,bufferAfterMinutes,advanceNoticeHours,maxBookingsPerDay);

@override
String toString() {
  return 'SchedulingPolicyUpdateRequest(slotLengthMinutes: $slotLengthMinutes, bufferBeforeMinutes: $bufferBeforeMinutes, bufferAfterMinutes: $bufferAfterMinutes, advanceNoticeHours: $advanceNoticeHours, maxBookingsPerDay: $maxBookingsPerDay)';
}


}

/// @nodoc
abstract mixin class $SchedulingPolicyUpdateRequestCopyWith<$Res>  {
  factory $SchedulingPolicyUpdateRequestCopyWith(SchedulingPolicyUpdateRequest value, $Res Function(SchedulingPolicyUpdateRequest) _then) = _$SchedulingPolicyUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_) int slotLengthMinutes,@JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_) int bufferBeforeMinutes,@JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_) int bufferAfterMinutes,@JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_) int advanceNoticeHours,@JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_) int? maxBookingsPerDay
});




}
/// @nodoc
class _$SchedulingPolicyUpdateRequestCopyWithImpl<$Res>
    implements $SchedulingPolicyUpdateRequestCopyWith<$Res> {
  _$SchedulingPolicyUpdateRequestCopyWithImpl(this._self, this._then);

  final SchedulingPolicyUpdateRequest _self;
  final $Res Function(SchedulingPolicyUpdateRequest) _then;

/// Create a copy of SchedulingPolicyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slotLengthMinutes = null,Object? bufferBeforeMinutes = null,Object? bufferAfterMinutes = null,Object? advanceNoticeHours = null,Object? maxBookingsPerDay = freezed,}) {
  return _then(_self.copyWith(
slotLengthMinutes: null == slotLengthMinutes ? _self.slotLengthMinutes : slotLengthMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferBeforeMinutes: null == bufferBeforeMinutes ? _self.bufferBeforeMinutes : bufferBeforeMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferAfterMinutes: null == bufferAfterMinutes ? _self.bufferAfterMinutes : bufferAfterMinutes // ignore: cast_nullable_to_non_nullable
as int,advanceNoticeHours: null == advanceNoticeHours ? _self.advanceNoticeHours : advanceNoticeHours // ignore: cast_nullable_to_non_nullable
as int,maxBookingsPerDay: freezed == maxBookingsPerDay ? _self.maxBookingsPerDay : maxBookingsPerDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulingPolicyUpdateRequest].
extension SchedulingPolicyUpdateRequestPatterns on SchedulingPolicyUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulingPolicyUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulingPolicyUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulingPolicyUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _SchedulingPolicyUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulingPolicyUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulingPolicyUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_)  int slotLengthMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_)  int bufferBeforeMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_)  int bufferAfterMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_)  int advanceNoticeHours, @JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_)  int? maxBookingsPerDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulingPolicyUpdateRequest() when $default != null:
return $default(_that.slotLengthMinutes,_that.bufferBeforeMinutes,_that.bufferAfterMinutes,_that.advanceNoticeHours,_that.maxBookingsPerDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_)  int slotLengthMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_)  int bufferBeforeMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_)  int bufferAfterMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_)  int advanceNoticeHours, @JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_)  int? maxBookingsPerDay)  $default,) {final _that = this;
switch (_that) {
case _SchedulingPolicyUpdateRequest():
return $default(_that.slotLengthMinutes,_that.bufferBeforeMinutes,_that.bufferAfterMinutes,_that.advanceNoticeHours,_that.maxBookingsPerDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_)  int slotLengthMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_)  int bufferBeforeMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_)  int bufferAfterMinutes, @JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_)  int advanceNoticeHours, @JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_)  int? maxBookingsPerDay)?  $default,) {final _that = this;
switch (_that) {
case _SchedulingPolicyUpdateRequest() when $default != null:
return $default(_that.slotLengthMinutes,_that.bufferBeforeMinutes,_that.bufferAfterMinutes,_that.advanceNoticeHours,_that.maxBookingsPerDay);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SchedulingPolicyUpdateRequest extends SchedulingPolicyUpdateRequest {
  const _SchedulingPolicyUpdateRequest({@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_) this.slotLengthMinutes = 60, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_) this.bufferBeforeMinutes = 15, @JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_) this.bufferAfterMinutes = 15, @JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_) this.advanceNoticeHours = 24, @JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_) this.maxBookingsPerDay}): super._();
  factory _SchedulingPolicyUpdateRequest.fromJson(Map<String, dynamic> json) => _$SchedulingPolicyUpdateRequestFromJson(json);

/// slotLengthMinutes
@override@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_) final  int slotLengthMinutes;
/// bufferBeforeMinutes
@override@JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_) final  int bufferBeforeMinutes;
/// bufferAfterMinutes
@override@JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_) final  int bufferAfterMinutes;
/// advanceNoticeHours
@override@JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_) final  int advanceNoticeHours;
/// maxBookingsPerDay
@override@JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_) final  int? maxBookingsPerDay;

/// Create a copy of SchedulingPolicyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulingPolicyUpdateRequestCopyWith<_SchedulingPolicyUpdateRequest> get copyWith => __$SchedulingPolicyUpdateRequestCopyWithImpl<_SchedulingPolicyUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulingPolicyUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulingPolicyUpdateRequest&&(identical(other.slotLengthMinutes, slotLengthMinutes) || other.slotLengthMinutes == slotLengthMinutes)&&(identical(other.bufferBeforeMinutes, bufferBeforeMinutes) || other.bufferBeforeMinutes == bufferBeforeMinutes)&&(identical(other.bufferAfterMinutes, bufferAfterMinutes) || other.bufferAfterMinutes == bufferAfterMinutes)&&(identical(other.advanceNoticeHours, advanceNoticeHours) || other.advanceNoticeHours == advanceNoticeHours)&&(identical(other.maxBookingsPerDay, maxBookingsPerDay) || other.maxBookingsPerDay == maxBookingsPerDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotLengthMinutes,bufferBeforeMinutes,bufferAfterMinutes,advanceNoticeHours,maxBookingsPerDay);

@override
String toString() {
  return 'SchedulingPolicyUpdateRequest(slotLengthMinutes: $slotLengthMinutes, bufferBeforeMinutes: $bufferBeforeMinutes, bufferAfterMinutes: $bufferAfterMinutes, advanceNoticeHours: $advanceNoticeHours, maxBookingsPerDay: $maxBookingsPerDay)';
}


}

/// @nodoc
abstract mixin class _$SchedulingPolicyUpdateRequestCopyWith<$Res> implements $SchedulingPolicyUpdateRequestCopyWith<$Res> {
  factory _$SchedulingPolicyUpdateRequestCopyWith(_SchedulingPolicyUpdateRequest value, $Res Function(_SchedulingPolicyUpdateRequest) _then) = __$SchedulingPolicyUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_) int slotLengthMinutes,@JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_) int bufferBeforeMinutes,@JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_) int bufferAfterMinutes,@JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_) int advanceNoticeHours,@JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_) int? maxBookingsPerDay
});




}
/// @nodoc
class __$SchedulingPolicyUpdateRequestCopyWithImpl<$Res>
    implements _$SchedulingPolicyUpdateRequestCopyWith<$Res> {
  __$SchedulingPolicyUpdateRequestCopyWithImpl(this._self, this._then);

  final _SchedulingPolicyUpdateRequest _self;
  final $Res Function(_SchedulingPolicyUpdateRequest) _then;

/// Create a copy of SchedulingPolicyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slotLengthMinutes = null,Object? bufferBeforeMinutes = null,Object? bufferAfterMinutes = null,Object? advanceNoticeHours = null,Object? maxBookingsPerDay = freezed,}) {
  return _then(_SchedulingPolicyUpdateRequest(
slotLengthMinutes: null == slotLengthMinutes ? _self.slotLengthMinutes : slotLengthMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferBeforeMinutes: null == bufferBeforeMinutes ? _self.bufferBeforeMinutes : bufferBeforeMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferAfterMinutes: null == bufferAfterMinutes ? _self.bufferAfterMinutes : bufferAfterMinutes // ignore: cast_nullable_to_non_nullable
as int,advanceNoticeHours: null == advanceNoticeHours ? _self.advanceNoticeHours : advanceNoticeHours // ignore: cast_nullable_to_non_nullable
as int,maxBookingsPerDay: freezed == maxBookingsPerDay ? _self.maxBookingsPerDay : maxBookingsPerDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
