// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_availability_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientAvailabilityResponse {

/// timezone
@JsonKey(name: ClientAvailabilityResponse.timezoneKey_) String get timezone;/// hasSchedule
@JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_) bool get hasSchedule;/// noticeHours
@JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_) int get noticeHours;/// schedulingPreset
@JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_) String get schedulingPreset;/// days
@JsonKey(name: ClientAvailabilityResponse.daysKey_) List<ClientAvailabilityDay>? get days;
/// Create a copy of ClientAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientAvailabilityResponseCopyWith<ClientAvailabilityResponse> get copyWith => _$ClientAvailabilityResponseCopyWithImpl<ClientAvailabilityResponse>(this as ClientAvailabilityResponse, _$identity);

  /// Serializes this ClientAvailabilityResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientAvailabilityResponse&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.hasSchedule, hasSchedule) || other.hasSchedule == hasSchedule)&&(identical(other.noticeHours, noticeHours) || other.noticeHours == noticeHours)&&(identical(other.schedulingPreset, schedulingPreset) || other.schedulingPreset == schedulingPreset)&&const DeepCollectionEquality().equals(other.days, days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timezone,hasSchedule,noticeHours,schedulingPreset,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'ClientAvailabilityResponse(timezone: $timezone, hasSchedule: $hasSchedule, noticeHours: $noticeHours, schedulingPreset: $schedulingPreset, days: $days)';
}


}

/// @nodoc
abstract mixin class $ClientAvailabilityResponseCopyWith<$Res>  {
  factory $ClientAvailabilityResponseCopyWith(ClientAvailabilityResponse value, $Res Function(ClientAvailabilityResponse) _then) = _$ClientAvailabilityResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientAvailabilityResponse.timezoneKey_) String timezone,@JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_) bool hasSchedule,@JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_) int noticeHours,@JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_) String schedulingPreset,@JsonKey(name: ClientAvailabilityResponse.daysKey_) List<ClientAvailabilityDay>? days
});




}
/// @nodoc
class _$ClientAvailabilityResponseCopyWithImpl<$Res>
    implements $ClientAvailabilityResponseCopyWith<$Res> {
  _$ClientAvailabilityResponseCopyWithImpl(this._self, this._then);

  final ClientAvailabilityResponse _self;
  final $Res Function(ClientAvailabilityResponse) _then;

/// Create a copy of ClientAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timezone = null,Object? hasSchedule = null,Object? noticeHours = null,Object? schedulingPreset = null,Object? days = freezed,}) {
  return _then(_self.copyWith(
timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,hasSchedule: null == hasSchedule ? _self.hasSchedule : hasSchedule // ignore: cast_nullable_to_non_nullable
as bool,noticeHours: null == noticeHours ? _self.noticeHours : noticeHours // ignore: cast_nullable_to_non_nullable
as int,schedulingPreset: null == schedulingPreset ? _self.schedulingPreset : schedulingPreset // ignore: cast_nullable_to_non_nullable
as String,days: freezed == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<ClientAvailabilityDay>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientAvailabilityResponse].
extension ClientAvailabilityResponsePatterns on ClientAvailabilityResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientAvailabilityResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientAvailabilityResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientAvailabilityResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientAvailabilityResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientAvailabilityResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientAvailabilityResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAvailabilityResponse.timezoneKey_)  String timezone, @JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_)  bool hasSchedule, @JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_)  int noticeHours, @JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_)  String schedulingPreset, @JsonKey(name: ClientAvailabilityResponse.daysKey_)  List<ClientAvailabilityDay>? days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientAvailabilityResponse() when $default != null:
return $default(_that.timezone,_that.hasSchedule,_that.noticeHours,_that.schedulingPreset,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAvailabilityResponse.timezoneKey_)  String timezone, @JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_)  bool hasSchedule, @JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_)  int noticeHours, @JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_)  String schedulingPreset, @JsonKey(name: ClientAvailabilityResponse.daysKey_)  List<ClientAvailabilityDay>? days)  $default,) {final _that = this;
switch (_that) {
case _ClientAvailabilityResponse():
return $default(_that.timezone,_that.hasSchedule,_that.noticeHours,_that.schedulingPreset,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientAvailabilityResponse.timezoneKey_)  String timezone, @JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_)  bool hasSchedule, @JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_)  int noticeHours, @JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_)  String schedulingPreset, @JsonKey(name: ClientAvailabilityResponse.daysKey_)  List<ClientAvailabilityDay>? days)?  $default,) {final _that = this;
switch (_that) {
case _ClientAvailabilityResponse() when $default != null:
return $default(_that.timezone,_that.hasSchedule,_that.noticeHours,_that.schedulingPreset,_that.days);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientAvailabilityResponse extends ClientAvailabilityResponse {
  const _ClientAvailabilityResponse({@JsonKey(name: ClientAvailabilityResponse.timezoneKey_) required this.timezone, @JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_) required this.hasSchedule, @JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_) required this.noticeHours, @JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_) this.schedulingPreset = 'interval', @JsonKey(name: ClientAvailabilityResponse.daysKey_) final  List<ClientAvailabilityDay>? days}): _days = days,super._();
  factory _ClientAvailabilityResponse.fromJson(Map<String, dynamic> json) => _$ClientAvailabilityResponseFromJson(json);

/// timezone
@override@JsonKey(name: ClientAvailabilityResponse.timezoneKey_) final  String timezone;
/// hasSchedule
@override@JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_) final  bool hasSchedule;
/// noticeHours
@override@JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_) final  int noticeHours;
/// schedulingPreset
@override@JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_) final  String schedulingPreset;
/// days
 final  List<ClientAvailabilityDay>? _days;
/// days
@override@JsonKey(name: ClientAvailabilityResponse.daysKey_) List<ClientAvailabilityDay>? get days {
  final value = _days;
  if (value == null) return null;
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClientAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientAvailabilityResponseCopyWith<_ClientAvailabilityResponse> get copyWith => __$ClientAvailabilityResponseCopyWithImpl<_ClientAvailabilityResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientAvailabilityResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientAvailabilityResponse&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.hasSchedule, hasSchedule) || other.hasSchedule == hasSchedule)&&(identical(other.noticeHours, noticeHours) || other.noticeHours == noticeHours)&&(identical(other.schedulingPreset, schedulingPreset) || other.schedulingPreset == schedulingPreset)&&const DeepCollectionEquality().equals(other._days, _days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timezone,hasSchedule,noticeHours,schedulingPreset,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'ClientAvailabilityResponse(timezone: $timezone, hasSchedule: $hasSchedule, noticeHours: $noticeHours, schedulingPreset: $schedulingPreset, days: $days)';
}


}

/// @nodoc
abstract mixin class _$ClientAvailabilityResponseCopyWith<$Res> implements $ClientAvailabilityResponseCopyWith<$Res> {
  factory _$ClientAvailabilityResponseCopyWith(_ClientAvailabilityResponse value, $Res Function(_ClientAvailabilityResponse) _then) = __$ClientAvailabilityResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientAvailabilityResponse.timezoneKey_) String timezone,@JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_) bool hasSchedule,@JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_) int noticeHours,@JsonKey(name: ClientAvailabilityResponse.schedulingPresetKey_) String schedulingPreset,@JsonKey(name: ClientAvailabilityResponse.daysKey_) List<ClientAvailabilityDay>? days
});




}
/// @nodoc
class __$ClientAvailabilityResponseCopyWithImpl<$Res>
    implements _$ClientAvailabilityResponseCopyWith<$Res> {
  __$ClientAvailabilityResponseCopyWithImpl(this._self, this._then);

  final _ClientAvailabilityResponse _self;
  final $Res Function(_ClientAvailabilityResponse) _then;

/// Create a copy of ClientAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timezone = null,Object? hasSchedule = null,Object? noticeHours = null,Object? schedulingPreset = null,Object? days = freezed,}) {
  return _then(_ClientAvailabilityResponse(
timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,hasSchedule: null == hasSchedule ? _self.hasSchedule : hasSchedule // ignore: cast_nullable_to_non_nullable
as bool,noticeHours: null == noticeHours ? _self.noticeHours : noticeHours // ignore: cast_nullable_to_non_nullable
as int,schedulingPreset: null == schedulingPreset ? _self.schedulingPreset : schedulingPreset // ignore: cast_nullable_to_non_nullable
as String,days: freezed == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<ClientAvailabilityDay>?,
  ));
}


}

// dart format on
