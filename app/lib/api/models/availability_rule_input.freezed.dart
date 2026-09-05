// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_rule_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityRuleInput {

/// dayOfWeek
@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_) int get dayOfWeek;/// startTime
@JsonKey(name: AvailabilityRuleInput.startTimeKey_) String get startTime;/// endTime
@JsonKey(name: AvailabilityRuleInput.endTimeKey_) String get endTime;
/// Create a copy of AvailabilityRuleInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityRuleInputCopyWith<AvailabilityRuleInput> get copyWith => _$AvailabilityRuleInputCopyWithImpl<AvailabilityRuleInput>(this as AvailabilityRuleInput, _$identity);

  /// Serializes this AvailabilityRuleInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityRuleInput&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'AvailabilityRuleInput(dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $AvailabilityRuleInputCopyWith<$Res>  {
  factory $AvailabilityRuleInputCopyWith(AvailabilityRuleInput value, $Res Function(AvailabilityRuleInput) _then) = _$AvailabilityRuleInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: AvailabilityRuleInput.startTimeKey_) String startTime,@JsonKey(name: AvailabilityRuleInput.endTimeKey_) String endTime
});




}
/// @nodoc
class _$AvailabilityRuleInputCopyWithImpl<$Res>
    implements $AvailabilityRuleInputCopyWith<$Res> {
  _$AvailabilityRuleInputCopyWithImpl(this._self, this._then);

  final AvailabilityRuleInput _self;
  final $Res Function(AvailabilityRuleInput) _then;

/// Create a copy of AvailabilityRuleInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_self.copyWith(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityRuleInput].
extension AvailabilityRuleInputPatterns on AvailabilityRuleInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityRuleInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityRuleInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityRuleInput value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityRuleInput value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: AvailabilityRuleInput.startTimeKey_)  String startTime, @JsonKey(name: AvailabilityRuleInput.endTimeKey_)  String endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityRuleInput() when $default != null:
return $default(_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: AvailabilityRuleInput.startTimeKey_)  String startTime, @JsonKey(name: AvailabilityRuleInput.endTimeKey_)  String endTime)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleInput():
return $default(_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: AvailabilityRuleInput.startTimeKey_)  String startTime, @JsonKey(name: AvailabilityRuleInput.endTimeKey_)  String endTime)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleInput() when $default != null:
return $default(_that.dayOfWeek,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityRuleInput extends AvailabilityRuleInput {
  const _AvailabilityRuleInput({@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_) required this.dayOfWeek, @JsonKey(name: AvailabilityRuleInput.startTimeKey_) required this.startTime, @JsonKey(name: AvailabilityRuleInput.endTimeKey_) required this.endTime}): super._();
  factory _AvailabilityRuleInput.fromJson(Map<String, dynamic> json) => _$AvailabilityRuleInputFromJson(json);

/// dayOfWeek
@override@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_) final  int dayOfWeek;
/// startTime
@override@JsonKey(name: AvailabilityRuleInput.startTimeKey_) final  String startTime;
/// endTime
@override@JsonKey(name: AvailabilityRuleInput.endTimeKey_) final  String endTime;

/// Create a copy of AvailabilityRuleInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityRuleInputCopyWith<_AvailabilityRuleInput> get copyWith => __$AvailabilityRuleInputCopyWithImpl<_AvailabilityRuleInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityRuleInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityRuleInput&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'AvailabilityRuleInput(dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityRuleInputCopyWith<$Res> implements $AvailabilityRuleInputCopyWith<$Res> {
  factory _$AvailabilityRuleInputCopyWith(_AvailabilityRuleInput value, $Res Function(_AvailabilityRuleInput) _then) = __$AvailabilityRuleInputCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: AvailabilityRuleInput.startTimeKey_) String startTime,@JsonKey(name: AvailabilityRuleInput.endTimeKey_) String endTime
});




}
/// @nodoc
class __$AvailabilityRuleInputCopyWithImpl<$Res>
    implements _$AvailabilityRuleInputCopyWith<$Res> {
  __$AvailabilityRuleInputCopyWithImpl(this._self, this._then);

  final _AvailabilityRuleInput _self;
  final $Res Function(_AvailabilityRuleInput) _then;

/// Create a copy of AvailabilityRuleInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_AvailabilityRuleInput(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
