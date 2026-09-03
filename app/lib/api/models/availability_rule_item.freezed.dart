// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_rule_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityRuleItem {

/// weekday
@JsonKey(name: AvailabilityRuleItem.weekdayKey_) int get weekday;/// startLocal
@JsonKey(name: AvailabilityRuleItem.startLocalKey_) String get startLocal;/// endLocal
@JsonKey(name: AvailabilityRuleItem.endLocalKey_) String get endLocal;/// timezone
@JsonKey(name: AvailabilityRuleItem.timezoneKey_) String get timezone;/// locationMode
@JsonKey(name: AvailabilityRuleItem.locationModeKey_) AvailabilityLocationMode get locationMode;
/// Create a copy of AvailabilityRuleItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityRuleItemCopyWith<AvailabilityRuleItem> get copyWith => _$AvailabilityRuleItemCopyWithImpl<AvailabilityRuleItem>(this as AvailabilityRuleItem, _$identity);

  /// Serializes this AvailabilityRuleItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityRuleItem&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startLocal, startLocal) || other.startLocal == startLocal)&&(identical(other.endLocal, endLocal) || other.endLocal == endLocal)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,startLocal,endLocal,timezone,locationMode);

@override
String toString() {
  return 'AvailabilityRuleItem(weekday: $weekday, startLocal: $startLocal, endLocal: $endLocal, timezone: $timezone, locationMode: $locationMode)';
}


}

/// @nodoc
abstract mixin class $AvailabilityRuleItemCopyWith<$Res>  {
  factory $AvailabilityRuleItemCopyWith(AvailabilityRuleItem value, $Res Function(AvailabilityRuleItem) _then) = _$AvailabilityRuleItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityRuleItem.weekdayKey_) int weekday,@JsonKey(name: AvailabilityRuleItem.startLocalKey_) String startLocal,@JsonKey(name: AvailabilityRuleItem.endLocalKey_) String endLocal,@JsonKey(name: AvailabilityRuleItem.timezoneKey_) String timezone,@JsonKey(name: AvailabilityRuleItem.locationModeKey_) AvailabilityLocationMode locationMode
});




}
/// @nodoc
class _$AvailabilityRuleItemCopyWithImpl<$Res>
    implements $AvailabilityRuleItemCopyWith<$Res> {
  _$AvailabilityRuleItemCopyWithImpl(this._self, this._then);

  final AvailabilityRuleItem _self;
  final $Res Function(AvailabilityRuleItem) _then;

/// Create a copy of AvailabilityRuleItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekday = null,Object? startLocal = null,Object? endLocal = null,Object? timezone = null,Object? locationMode = null,}) {
  return _then(_self.copyWith(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as String,endLocal: null == endLocal ? _self.endLocal : endLocal // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locationMode: null == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as AvailabilityLocationMode,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityRuleItem].
extension AvailabilityRuleItemPatterns on AvailabilityRuleItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityRuleItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityRuleItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityRuleItem value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityRuleItem value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRuleItem.weekdayKey_)  int weekday, @JsonKey(name: AvailabilityRuleItem.startLocalKey_)  String startLocal, @JsonKey(name: AvailabilityRuleItem.endLocalKey_)  String endLocal, @JsonKey(name: AvailabilityRuleItem.timezoneKey_)  String timezone, @JsonKey(name: AvailabilityRuleItem.locationModeKey_)  AvailabilityLocationMode locationMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityRuleItem() when $default != null:
return $default(_that.weekday,_that.startLocal,_that.endLocal,_that.timezone,_that.locationMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRuleItem.weekdayKey_)  int weekday, @JsonKey(name: AvailabilityRuleItem.startLocalKey_)  String startLocal, @JsonKey(name: AvailabilityRuleItem.endLocalKey_)  String endLocal, @JsonKey(name: AvailabilityRuleItem.timezoneKey_)  String timezone, @JsonKey(name: AvailabilityRuleItem.locationModeKey_)  AvailabilityLocationMode locationMode)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleItem():
return $default(_that.weekday,_that.startLocal,_that.endLocal,_that.timezone,_that.locationMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityRuleItem.weekdayKey_)  int weekday, @JsonKey(name: AvailabilityRuleItem.startLocalKey_)  String startLocal, @JsonKey(name: AvailabilityRuleItem.endLocalKey_)  String endLocal, @JsonKey(name: AvailabilityRuleItem.timezoneKey_)  String timezone, @JsonKey(name: AvailabilityRuleItem.locationModeKey_)  AvailabilityLocationMode locationMode)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleItem() when $default != null:
return $default(_that.weekday,_that.startLocal,_that.endLocal,_that.timezone,_that.locationMode);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityRuleItem extends AvailabilityRuleItem {
  const _AvailabilityRuleItem({@JsonKey(name: AvailabilityRuleItem.weekdayKey_) required this.weekday, @JsonKey(name: AvailabilityRuleItem.startLocalKey_) required this.startLocal, @JsonKey(name: AvailabilityRuleItem.endLocalKey_) required this.endLocal, @JsonKey(name: AvailabilityRuleItem.timezoneKey_) required this.timezone, @JsonKey(name: AvailabilityRuleItem.locationModeKey_) this.locationMode = AvailabilityLocationMode.both}): super._();
  factory _AvailabilityRuleItem.fromJson(Map<String, dynamic> json) => _$AvailabilityRuleItemFromJson(json);

/// weekday
@override@JsonKey(name: AvailabilityRuleItem.weekdayKey_) final  int weekday;
/// startLocal
@override@JsonKey(name: AvailabilityRuleItem.startLocalKey_) final  String startLocal;
/// endLocal
@override@JsonKey(name: AvailabilityRuleItem.endLocalKey_) final  String endLocal;
/// timezone
@override@JsonKey(name: AvailabilityRuleItem.timezoneKey_) final  String timezone;
/// locationMode
@override@JsonKey(name: AvailabilityRuleItem.locationModeKey_) final  AvailabilityLocationMode locationMode;

/// Create a copy of AvailabilityRuleItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityRuleItemCopyWith<_AvailabilityRuleItem> get copyWith => __$AvailabilityRuleItemCopyWithImpl<_AvailabilityRuleItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityRuleItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityRuleItem&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startLocal, startLocal) || other.startLocal == startLocal)&&(identical(other.endLocal, endLocal) || other.endLocal == endLocal)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,startLocal,endLocal,timezone,locationMode);

@override
String toString() {
  return 'AvailabilityRuleItem(weekday: $weekday, startLocal: $startLocal, endLocal: $endLocal, timezone: $timezone, locationMode: $locationMode)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityRuleItemCopyWith<$Res> implements $AvailabilityRuleItemCopyWith<$Res> {
  factory _$AvailabilityRuleItemCopyWith(_AvailabilityRuleItem value, $Res Function(_AvailabilityRuleItem) _then) = __$AvailabilityRuleItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityRuleItem.weekdayKey_) int weekday,@JsonKey(name: AvailabilityRuleItem.startLocalKey_) String startLocal,@JsonKey(name: AvailabilityRuleItem.endLocalKey_) String endLocal,@JsonKey(name: AvailabilityRuleItem.timezoneKey_) String timezone,@JsonKey(name: AvailabilityRuleItem.locationModeKey_) AvailabilityLocationMode locationMode
});




}
/// @nodoc
class __$AvailabilityRuleItemCopyWithImpl<$Res>
    implements _$AvailabilityRuleItemCopyWith<$Res> {
  __$AvailabilityRuleItemCopyWithImpl(this._self, this._then);

  final _AvailabilityRuleItem _self;
  final $Res Function(_AvailabilityRuleItem) _then;

/// Create a copy of AvailabilityRuleItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekday = null,Object? startLocal = null,Object? endLocal = null,Object? timezone = null,Object? locationMode = null,}) {
  return _then(_AvailabilityRuleItem(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as String,endLocal: null == endLocal ? _self.endLocal : endLocal // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locationMode: null == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as AvailabilityLocationMode,
  ));
}


}

// dart format on
