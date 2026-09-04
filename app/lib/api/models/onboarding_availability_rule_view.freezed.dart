// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_availability_rule_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingAvailabilityRuleView {

/// id
@JsonKey(name: OnboardingAvailabilityRuleView.idKey_) String get id;/// dayOfWeek
@JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_) int get dayOfWeek;/// startTime
@JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_) String get startTime;/// endTime
@JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_) String get endTime;
/// Create a copy of OnboardingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingAvailabilityRuleViewCopyWith<OnboardingAvailabilityRuleView> get copyWith => _$OnboardingAvailabilityRuleViewCopyWithImpl<OnboardingAvailabilityRuleView>(this as OnboardingAvailabilityRuleView, _$identity);

  /// Serializes this OnboardingAvailabilityRuleView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingAvailabilityRuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'OnboardingAvailabilityRuleView(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $OnboardingAvailabilityRuleViewCopyWith<$Res>  {
  factory $OnboardingAvailabilityRuleViewCopyWith(OnboardingAvailabilityRuleView value, $Res Function(OnboardingAvailabilityRuleView) _then) = _$OnboardingAvailabilityRuleViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: OnboardingAvailabilityRuleView.idKey_) String id,@JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_) String startTime,@JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_) String endTime
});




}
/// @nodoc
class _$OnboardingAvailabilityRuleViewCopyWithImpl<$Res>
    implements $OnboardingAvailabilityRuleViewCopyWith<$Res> {
  _$OnboardingAvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final OnboardingAvailabilityRuleView _self;
  final $Res Function(OnboardingAvailabilityRuleView) _then;

/// Create a copy of OnboardingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingAvailabilityRuleView].
extension OnboardingAvailabilityRuleViewPatterns on OnboardingAvailabilityRuleView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingAvailabilityRuleView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingAvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingAvailabilityRuleView value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingAvailabilityRuleView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingAvailabilityRuleView value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingAvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: OnboardingAvailabilityRuleView.idKey_)  String id, @JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_)  String endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingAvailabilityRuleView() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: OnboardingAvailabilityRuleView.idKey_)  String id, @JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_)  String endTime)  $default,) {final _that = this;
switch (_that) {
case _OnboardingAvailabilityRuleView():
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: OnboardingAvailabilityRuleView.idKey_)  String id, @JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_)  String endTime)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingAvailabilityRuleView() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _OnboardingAvailabilityRuleView extends OnboardingAvailabilityRuleView {
  const _OnboardingAvailabilityRuleView({@JsonKey(name: OnboardingAvailabilityRuleView.idKey_) required this.id, @JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_) required this.dayOfWeek, @JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_) required this.startTime, @JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_) required this.endTime}): super._();
  factory _OnboardingAvailabilityRuleView.fromJson(Map<String, dynamic> json) => _$OnboardingAvailabilityRuleViewFromJson(json);

/// id
@override@JsonKey(name: OnboardingAvailabilityRuleView.idKey_) final  String id;
/// dayOfWeek
@override@JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_) final  int dayOfWeek;
/// startTime
@override@JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_) final  String startTime;
/// endTime
@override@JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_) final  String endTime;

/// Create a copy of OnboardingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingAvailabilityRuleViewCopyWith<_OnboardingAvailabilityRuleView> get copyWith => __$OnboardingAvailabilityRuleViewCopyWithImpl<_OnboardingAvailabilityRuleView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingAvailabilityRuleViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingAvailabilityRuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'OnboardingAvailabilityRuleView(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$OnboardingAvailabilityRuleViewCopyWith<$Res> implements $OnboardingAvailabilityRuleViewCopyWith<$Res> {
  factory _$OnboardingAvailabilityRuleViewCopyWith(_OnboardingAvailabilityRuleView value, $Res Function(_OnboardingAvailabilityRuleView) _then) = __$OnboardingAvailabilityRuleViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: OnboardingAvailabilityRuleView.idKey_) String id,@JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_) String startTime,@JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_) String endTime
});




}
/// @nodoc
class __$OnboardingAvailabilityRuleViewCopyWithImpl<$Res>
    implements _$OnboardingAvailabilityRuleViewCopyWith<$Res> {
  __$OnboardingAvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final _OnboardingAvailabilityRuleView _self;
  final $Res Function(_OnboardingAvailabilityRuleView) _then;

/// Create a copy of OnboardingAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_OnboardingAvailabilityRuleView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
