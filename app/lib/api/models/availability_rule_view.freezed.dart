// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_rule_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityRuleView {

/// id
@JsonKey(name: AvailabilityRuleView.idKey_) String get id;/// dayOfWeek
@JsonKey(name: AvailabilityRuleView.dayOfWeekKey_) int get dayOfWeek;/// startTime
@JsonKey(name: AvailabilityRuleView.startTimeKey_) String get startTime;/// endTime
@JsonKey(name: AvailabilityRuleView.endTimeKey_) String get endTime;
/// Create a copy of AvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityRuleViewCopyWith<AvailabilityRuleView> get copyWith => _$AvailabilityRuleViewCopyWithImpl<AvailabilityRuleView>(this as AvailabilityRuleView, _$identity);

  /// Serializes this AvailabilityRuleView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityRuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'AvailabilityRuleView(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $AvailabilityRuleViewCopyWith<$Res>  {
  factory $AvailabilityRuleViewCopyWith(AvailabilityRuleView value, $Res Function(AvailabilityRuleView) _then) = _$AvailabilityRuleViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityRuleView.idKey_) String id,@JsonKey(name: AvailabilityRuleView.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: AvailabilityRuleView.startTimeKey_) String startTime,@JsonKey(name: AvailabilityRuleView.endTimeKey_) String endTime
});




}
/// @nodoc
class _$AvailabilityRuleViewCopyWithImpl<$Res>
    implements $AvailabilityRuleViewCopyWith<$Res> {
  _$AvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final AvailabilityRuleView _self;
  final $Res Function(AvailabilityRuleView) _then;

/// Create a copy of AvailabilityRuleView
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


/// Adds pattern-matching-related methods to [AvailabilityRuleView].
extension AvailabilityRuleViewPatterns on AvailabilityRuleView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityRuleView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityRuleView value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityRuleView value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRuleView.idKey_)  String id, @JsonKey(name: AvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: AvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: AvailabilityRuleView.endTimeKey_)  String endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRuleView.idKey_)  String id, @JsonKey(name: AvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: AvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: AvailabilityRuleView.endTimeKey_)  String endTime)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleView():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityRuleView.idKey_)  String id, @JsonKey(name: AvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: AvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: AvailabilityRuleView.endTimeKey_)  String endTime)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleView() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityRuleView extends AvailabilityRuleView {
  const _AvailabilityRuleView({@JsonKey(name: AvailabilityRuleView.idKey_) required this.id, @JsonKey(name: AvailabilityRuleView.dayOfWeekKey_) required this.dayOfWeek, @JsonKey(name: AvailabilityRuleView.startTimeKey_) required this.startTime, @JsonKey(name: AvailabilityRuleView.endTimeKey_) required this.endTime}): super._();
  factory _AvailabilityRuleView.fromJson(Map<String, dynamic> json) => _$AvailabilityRuleViewFromJson(json);

/// id
@override@JsonKey(name: AvailabilityRuleView.idKey_) final  String id;
/// dayOfWeek
@override@JsonKey(name: AvailabilityRuleView.dayOfWeekKey_) final  int dayOfWeek;
/// startTime
@override@JsonKey(name: AvailabilityRuleView.startTimeKey_) final  String startTime;
/// endTime
@override@JsonKey(name: AvailabilityRuleView.endTimeKey_) final  String endTime;

/// Create a copy of AvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityRuleViewCopyWith<_AvailabilityRuleView> get copyWith => __$AvailabilityRuleViewCopyWithImpl<_AvailabilityRuleView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityRuleViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityRuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'AvailabilityRuleView(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityRuleViewCopyWith<$Res> implements $AvailabilityRuleViewCopyWith<$Res> {
  factory _$AvailabilityRuleViewCopyWith(_AvailabilityRuleView value, $Res Function(_AvailabilityRuleView) _then) = __$AvailabilityRuleViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityRuleView.idKey_) String id,@JsonKey(name: AvailabilityRuleView.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: AvailabilityRuleView.startTimeKey_) String startTime,@JsonKey(name: AvailabilityRuleView.endTimeKey_) String endTime
});




}
/// @nodoc
class __$AvailabilityRuleViewCopyWithImpl<$Res>
    implements _$AvailabilityRuleViewCopyWith<$Res> {
  __$AvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final _AvailabilityRuleView _self;
  final $Res Function(_AvailabilityRuleView) _then;

/// Create a copy of AvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_AvailabilityRuleView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
