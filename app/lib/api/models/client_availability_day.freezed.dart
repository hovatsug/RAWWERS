// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_availability_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientAvailabilityDay {

/// date
@JsonKey(name: ClientAvailabilityDay.dateKey_) DateTime get date;/// open
@JsonKey(name: ClientAvailabilityDay.openKey_) bool get open;/// startTimes
@JsonKey(name: ClientAvailabilityDay.startTimesKey_) List<ClientAvailabilityStart>? get startTimes;
/// Create a copy of ClientAvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientAvailabilityDayCopyWith<ClientAvailabilityDay> get copyWith => _$ClientAvailabilityDayCopyWithImpl<ClientAvailabilityDay>(this as ClientAvailabilityDay, _$identity);

  /// Serializes this ClientAvailabilityDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientAvailabilityDay&&(identical(other.date, date) || other.date == date)&&(identical(other.open, open) || other.open == open)&&const DeepCollectionEquality().equals(other.startTimes, startTimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,open,const DeepCollectionEquality().hash(startTimes));

@override
String toString() {
  return 'ClientAvailabilityDay(date: $date, open: $open, startTimes: $startTimes)';
}


}

/// @nodoc
abstract mixin class $ClientAvailabilityDayCopyWith<$Res>  {
  factory $ClientAvailabilityDayCopyWith(ClientAvailabilityDay value, $Res Function(ClientAvailabilityDay) _then) = _$ClientAvailabilityDayCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientAvailabilityDay.dateKey_) DateTime date,@JsonKey(name: ClientAvailabilityDay.openKey_) bool open,@JsonKey(name: ClientAvailabilityDay.startTimesKey_) List<ClientAvailabilityStart>? startTimes
});




}
/// @nodoc
class _$ClientAvailabilityDayCopyWithImpl<$Res>
    implements $ClientAvailabilityDayCopyWith<$Res> {
  _$ClientAvailabilityDayCopyWithImpl(this._self, this._then);

  final ClientAvailabilityDay _self;
  final $Res Function(ClientAvailabilityDay) _then;

/// Create a copy of ClientAvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? open = null,Object? startTimes = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as bool,startTimes: freezed == startTimes ? _self.startTimes : startTimes // ignore: cast_nullable_to_non_nullable
as List<ClientAvailabilityStart>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientAvailabilityDay].
extension ClientAvailabilityDayPatterns on ClientAvailabilityDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientAvailabilityDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientAvailabilityDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientAvailabilityDay value)  $default,){
final _that = this;
switch (_that) {
case _ClientAvailabilityDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientAvailabilityDay value)?  $default,){
final _that = this;
switch (_that) {
case _ClientAvailabilityDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAvailabilityDay.dateKey_)  DateTime date, @JsonKey(name: ClientAvailabilityDay.openKey_)  bool open, @JsonKey(name: ClientAvailabilityDay.startTimesKey_)  List<ClientAvailabilityStart>? startTimes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientAvailabilityDay() when $default != null:
return $default(_that.date,_that.open,_that.startTimes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAvailabilityDay.dateKey_)  DateTime date, @JsonKey(name: ClientAvailabilityDay.openKey_)  bool open, @JsonKey(name: ClientAvailabilityDay.startTimesKey_)  List<ClientAvailabilityStart>? startTimes)  $default,) {final _that = this;
switch (_that) {
case _ClientAvailabilityDay():
return $default(_that.date,_that.open,_that.startTimes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientAvailabilityDay.dateKey_)  DateTime date, @JsonKey(name: ClientAvailabilityDay.openKey_)  bool open, @JsonKey(name: ClientAvailabilityDay.startTimesKey_)  List<ClientAvailabilityStart>? startTimes)?  $default,) {final _that = this;
switch (_that) {
case _ClientAvailabilityDay() when $default != null:
return $default(_that.date,_that.open,_that.startTimes);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientAvailabilityDay extends ClientAvailabilityDay {
  const _ClientAvailabilityDay({@JsonKey(name: ClientAvailabilityDay.dateKey_) required this.date, @JsonKey(name: ClientAvailabilityDay.openKey_) required this.open, @JsonKey(name: ClientAvailabilityDay.startTimesKey_) final  List<ClientAvailabilityStart>? startTimes}): _startTimes = startTimes,super._();
  factory _ClientAvailabilityDay.fromJson(Map<String, dynamic> json) => _$ClientAvailabilityDayFromJson(json);

/// date
@override@JsonKey(name: ClientAvailabilityDay.dateKey_) final  DateTime date;
/// open
@override@JsonKey(name: ClientAvailabilityDay.openKey_) final  bool open;
/// startTimes
 final  List<ClientAvailabilityStart>? _startTimes;
/// startTimes
@override@JsonKey(name: ClientAvailabilityDay.startTimesKey_) List<ClientAvailabilityStart>? get startTimes {
  final value = _startTimes;
  if (value == null) return null;
  if (_startTimes is EqualUnmodifiableListView) return _startTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClientAvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientAvailabilityDayCopyWith<_ClientAvailabilityDay> get copyWith => __$ClientAvailabilityDayCopyWithImpl<_ClientAvailabilityDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientAvailabilityDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientAvailabilityDay&&(identical(other.date, date) || other.date == date)&&(identical(other.open, open) || other.open == open)&&const DeepCollectionEquality().equals(other._startTimes, _startTimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,open,const DeepCollectionEquality().hash(_startTimes));

@override
String toString() {
  return 'ClientAvailabilityDay(date: $date, open: $open, startTimes: $startTimes)';
}


}

/// @nodoc
abstract mixin class _$ClientAvailabilityDayCopyWith<$Res> implements $ClientAvailabilityDayCopyWith<$Res> {
  factory _$ClientAvailabilityDayCopyWith(_ClientAvailabilityDay value, $Res Function(_ClientAvailabilityDay) _then) = __$ClientAvailabilityDayCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientAvailabilityDay.dateKey_) DateTime date,@JsonKey(name: ClientAvailabilityDay.openKey_) bool open,@JsonKey(name: ClientAvailabilityDay.startTimesKey_) List<ClientAvailabilityStart>? startTimes
});




}
/// @nodoc
class __$ClientAvailabilityDayCopyWithImpl<$Res>
    implements _$ClientAvailabilityDayCopyWith<$Res> {
  __$ClientAvailabilityDayCopyWithImpl(this._self, this._then);

  final _ClientAvailabilityDay _self;
  final $Res Function(_ClientAvailabilityDay) _then;

/// Create a copy of ClientAvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? open = null,Object? startTimes = freezed,}) {
  return _then(_ClientAvailabilityDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as bool,startTimes: freezed == startTimes ? _self._startTimes : startTimes // ignore: cast_nullable_to_non_nullable
as List<ClientAvailabilityStart>?,
  ));
}


}

// dart format on
