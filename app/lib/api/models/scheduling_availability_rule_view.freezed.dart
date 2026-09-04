// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduling_availability_rule_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulingAvailabilityRuleView {

/// weekday
@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_) int get weekday;/// startLocal
@JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_) String get startLocal;/// endLocal
@JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_) String get endLocal;/// timezone
@JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_) String get timezone;/// locationMode
@JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_) AvailabilityLocationMode get locationMode;/// id
@JsonKey(name: SchedulingAvailabilityRuleView.idKey_) String get id;/// proUserId
@JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_) String get proUserId;/// createdAt
@JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of SchedulingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulingAvailabilityRuleViewCopyWith<SchedulingAvailabilityRuleView> get copyWith => _$SchedulingAvailabilityRuleViewCopyWithImpl<SchedulingAvailabilityRuleView>(this as SchedulingAvailabilityRuleView, _$identity);

  /// Serializes this SchedulingAvailabilityRuleView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulingAvailabilityRuleView&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startLocal, startLocal) || other.startLocal == startLocal)&&(identical(other.endLocal, endLocal) || other.endLocal == endLocal)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode)&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,startLocal,endLocal,timezone,locationMode,id,proUserId,createdAt,updatedAt);

@override
String toString() {
  return 'SchedulingAvailabilityRuleView(weekday: $weekday, startLocal: $startLocal, endLocal: $endLocal, timezone: $timezone, locationMode: $locationMode, id: $id, proUserId: $proUserId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SchedulingAvailabilityRuleViewCopyWith<$Res>  {
  factory $SchedulingAvailabilityRuleViewCopyWith(SchedulingAvailabilityRuleView value, $Res Function(SchedulingAvailabilityRuleView) _then) = _$SchedulingAvailabilityRuleViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_) int weekday,@JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_) String startLocal,@JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_) String endLocal,@JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_) String timezone,@JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_) AvailabilityLocationMode locationMode,@JsonKey(name: SchedulingAvailabilityRuleView.idKey_) String id,@JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_) String proUserId,@JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_) DateTime createdAt,@JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$SchedulingAvailabilityRuleViewCopyWithImpl<$Res>
    implements $SchedulingAvailabilityRuleViewCopyWith<$Res> {
  _$SchedulingAvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final SchedulingAvailabilityRuleView _self;
  final $Res Function(SchedulingAvailabilityRuleView) _then;

/// Create a copy of SchedulingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekday = null,Object? startLocal = null,Object? endLocal = null,Object? timezone = null,Object? locationMode = null,Object? id = null,Object? proUserId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as String,endLocal: null == endLocal ? _self.endLocal : endLocal // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locationMode: null == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as AvailabilityLocationMode,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulingAvailabilityRuleView].
extension SchedulingAvailabilityRuleViewPatterns on SchedulingAvailabilityRuleView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulingAvailabilityRuleView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulingAvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulingAvailabilityRuleView value)  $default,){
final _that = this;
switch (_that) {
case _SchedulingAvailabilityRuleView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulingAvailabilityRuleView value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulingAvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_)  int weekday, @JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_)  String startLocal, @JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_)  String endLocal, @JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_)  String timezone, @JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_)  AvailabilityLocationMode locationMode, @JsonKey(name: SchedulingAvailabilityRuleView.idKey_)  String id, @JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_)  String proUserId, @JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_)  DateTime createdAt, @JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulingAvailabilityRuleView() when $default != null:
return $default(_that.weekday,_that.startLocal,_that.endLocal,_that.timezone,_that.locationMode,_that.id,_that.proUserId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_)  int weekday, @JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_)  String startLocal, @JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_)  String endLocal, @JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_)  String timezone, @JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_)  AvailabilityLocationMode locationMode, @JsonKey(name: SchedulingAvailabilityRuleView.idKey_)  String id, @JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_)  String proUserId, @JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_)  DateTime createdAt, @JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SchedulingAvailabilityRuleView():
return $default(_that.weekday,_that.startLocal,_that.endLocal,_that.timezone,_that.locationMode,_that.id,_that.proUserId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_)  int weekday, @JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_)  String startLocal, @JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_)  String endLocal, @JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_)  String timezone, @JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_)  AvailabilityLocationMode locationMode, @JsonKey(name: SchedulingAvailabilityRuleView.idKey_)  String id, @JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_)  String proUserId, @JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_)  DateTime createdAt, @JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SchedulingAvailabilityRuleView() when $default != null:
return $default(_that.weekday,_that.startLocal,_that.endLocal,_that.timezone,_that.locationMode,_that.id,_that.proUserId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SchedulingAvailabilityRuleView extends SchedulingAvailabilityRuleView {
  const _SchedulingAvailabilityRuleView({@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_) required this.weekday, @JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_) required this.startLocal, @JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_) required this.endLocal, @JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_) required this.timezone, @JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_) this.locationMode = AvailabilityLocationMode.both, @JsonKey(name: SchedulingAvailabilityRuleView.idKey_) required this.id, @JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_) required this.proUserId, @JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_) required this.createdAt, @JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_) required this.updatedAt}): super._();
  factory _SchedulingAvailabilityRuleView.fromJson(Map<String, dynamic> json) => _$SchedulingAvailabilityRuleViewFromJson(json);

/// weekday
@override@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_) final  int weekday;
/// startLocal
@override@JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_) final  String startLocal;
/// endLocal
@override@JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_) final  String endLocal;
/// timezone
@override@JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_) final  String timezone;
/// locationMode
@override@JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_) final  AvailabilityLocationMode locationMode;
/// id
@override@JsonKey(name: SchedulingAvailabilityRuleView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_) final  String proUserId;
/// createdAt
@override@JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of SchedulingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulingAvailabilityRuleViewCopyWith<_SchedulingAvailabilityRuleView> get copyWith => __$SchedulingAvailabilityRuleViewCopyWithImpl<_SchedulingAvailabilityRuleView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulingAvailabilityRuleViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulingAvailabilityRuleView&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startLocal, startLocal) || other.startLocal == startLocal)&&(identical(other.endLocal, endLocal) || other.endLocal == endLocal)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode)&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,startLocal,endLocal,timezone,locationMode,id,proUserId,createdAt,updatedAt);

@override
String toString() {
  return 'SchedulingAvailabilityRuleView(weekday: $weekday, startLocal: $startLocal, endLocal: $endLocal, timezone: $timezone, locationMode: $locationMode, id: $id, proUserId: $proUserId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SchedulingAvailabilityRuleViewCopyWith<$Res> implements $SchedulingAvailabilityRuleViewCopyWith<$Res> {
  factory _$SchedulingAvailabilityRuleViewCopyWith(_SchedulingAvailabilityRuleView value, $Res Function(_SchedulingAvailabilityRuleView) _then) = __$SchedulingAvailabilityRuleViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_) int weekday,@JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_) String startLocal,@JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_) String endLocal,@JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_) String timezone,@JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_) AvailabilityLocationMode locationMode,@JsonKey(name: SchedulingAvailabilityRuleView.idKey_) String id,@JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_) String proUserId,@JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_) DateTime createdAt,@JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$SchedulingAvailabilityRuleViewCopyWithImpl<$Res>
    implements _$SchedulingAvailabilityRuleViewCopyWith<$Res> {
  __$SchedulingAvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final _SchedulingAvailabilityRuleView _self;
  final $Res Function(_SchedulingAvailabilityRuleView) _then;

/// Create a copy of SchedulingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekday = null,Object? startLocal = null,Object? endLocal = null,Object? timezone = null,Object? locationMode = null,Object? id = null,Object? proUserId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SchedulingAvailabilityRuleView(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as String,endLocal: null == endLocal ? _self.endLocal : endLocal // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locationMode: null == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as AvailabilityLocationMode,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
