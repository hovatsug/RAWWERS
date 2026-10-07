// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_availability_start.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientAvailabilityStart {

/// startAt
@JsonKey(name: ClientAvailabilityStart.startAtKey_) DateTime get startAt;/// localTime
@JsonKey(name: ClientAvailabilityStart.localTimeKey_) String get localTime;/// endAt
@JsonKey(name: ClientAvailabilityStart.endAtKey_) DateTime get endAt;/// localEndTime
@JsonKey(name: ClientAvailabilityStart.localEndTimeKey_) String get localEndTime;/// label
@JsonKey(name: ClientAvailabilityStart.labelKey_) String? get label;
/// Create a copy of ClientAvailabilityStart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientAvailabilityStartCopyWith<ClientAvailabilityStart> get copyWith => _$ClientAvailabilityStartCopyWithImpl<ClientAvailabilityStart>(this as ClientAvailabilityStart, _$identity);

  /// Serializes this ClientAvailabilityStart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientAvailabilityStart&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.localTime, localTime) || other.localTime == localTime)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.localEndTime, localEndTime) || other.localEndTime == localEndTime)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAt,localTime,endAt,localEndTime,label);

@override
String toString() {
  return 'ClientAvailabilityStart(startAt: $startAt, localTime: $localTime, endAt: $endAt, localEndTime: $localEndTime, label: $label)';
}


}

/// @nodoc
abstract mixin class $ClientAvailabilityStartCopyWith<$Res>  {
  factory $ClientAvailabilityStartCopyWith(ClientAvailabilityStart value, $Res Function(ClientAvailabilityStart) _then) = _$ClientAvailabilityStartCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientAvailabilityStart.startAtKey_) DateTime startAt,@JsonKey(name: ClientAvailabilityStart.localTimeKey_) String localTime,@JsonKey(name: ClientAvailabilityStart.endAtKey_) DateTime endAt,@JsonKey(name: ClientAvailabilityStart.localEndTimeKey_) String localEndTime,@JsonKey(name: ClientAvailabilityStart.labelKey_) String? label
});




}
/// @nodoc
class _$ClientAvailabilityStartCopyWithImpl<$Res>
    implements $ClientAvailabilityStartCopyWith<$Res> {
  _$ClientAvailabilityStartCopyWithImpl(this._self, this._then);

  final ClientAvailabilityStart _self;
  final $Res Function(ClientAvailabilityStart) _then;

/// Create a copy of ClientAvailabilityStart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAt = null,Object? localTime = null,Object? endAt = null,Object? localEndTime = null,Object? label = freezed,}) {
  return _then(_self.copyWith(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,localTime: null == localTime ? _self.localTime : localTime // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,localEndTime: null == localEndTime ? _self.localEndTime : localEndTime // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientAvailabilityStart].
extension ClientAvailabilityStartPatterns on ClientAvailabilityStart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientAvailabilityStart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientAvailabilityStart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientAvailabilityStart value)  $default,){
final _that = this;
switch (_that) {
case _ClientAvailabilityStart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientAvailabilityStart value)?  $default,){
final _that = this;
switch (_that) {
case _ClientAvailabilityStart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAvailabilityStart.startAtKey_)  DateTime startAt, @JsonKey(name: ClientAvailabilityStart.localTimeKey_)  String localTime, @JsonKey(name: ClientAvailabilityStart.endAtKey_)  DateTime endAt, @JsonKey(name: ClientAvailabilityStart.localEndTimeKey_)  String localEndTime, @JsonKey(name: ClientAvailabilityStart.labelKey_)  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientAvailabilityStart() when $default != null:
return $default(_that.startAt,_that.localTime,_that.endAt,_that.localEndTime,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAvailabilityStart.startAtKey_)  DateTime startAt, @JsonKey(name: ClientAvailabilityStart.localTimeKey_)  String localTime, @JsonKey(name: ClientAvailabilityStart.endAtKey_)  DateTime endAt, @JsonKey(name: ClientAvailabilityStart.localEndTimeKey_)  String localEndTime, @JsonKey(name: ClientAvailabilityStart.labelKey_)  String? label)  $default,) {final _that = this;
switch (_that) {
case _ClientAvailabilityStart():
return $default(_that.startAt,_that.localTime,_that.endAt,_that.localEndTime,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientAvailabilityStart.startAtKey_)  DateTime startAt, @JsonKey(name: ClientAvailabilityStart.localTimeKey_)  String localTime, @JsonKey(name: ClientAvailabilityStart.endAtKey_)  DateTime endAt, @JsonKey(name: ClientAvailabilityStart.localEndTimeKey_)  String localEndTime, @JsonKey(name: ClientAvailabilityStart.labelKey_)  String? label)?  $default,) {final _that = this;
switch (_that) {
case _ClientAvailabilityStart() when $default != null:
return $default(_that.startAt,_that.localTime,_that.endAt,_that.localEndTime,_that.label);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientAvailabilityStart extends ClientAvailabilityStart {
  const _ClientAvailabilityStart({@JsonKey(name: ClientAvailabilityStart.startAtKey_) required this.startAt, @JsonKey(name: ClientAvailabilityStart.localTimeKey_) required this.localTime, @JsonKey(name: ClientAvailabilityStart.endAtKey_) required this.endAt, @JsonKey(name: ClientAvailabilityStart.localEndTimeKey_) required this.localEndTime, @JsonKey(name: ClientAvailabilityStart.labelKey_) this.label}): super._();
  factory _ClientAvailabilityStart.fromJson(Map<String, dynamic> json) => _$ClientAvailabilityStartFromJson(json);

/// startAt
@override@JsonKey(name: ClientAvailabilityStart.startAtKey_) final  DateTime startAt;
/// localTime
@override@JsonKey(name: ClientAvailabilityStart.localTimeKey_) final  String localTime;
/// endAt
@override@JsonKey(name: ClientAvailabilityStart.endAtKey_) final  DateTime endAt;
/// localEndTime
@override@JsonKey(name: ClientAvailabilityStart.localEndTimeKey_) final  String localEndTime;
/// label
@override@JsonKey(name: ClientAvailabilityStart.labelKey_) final  String? label;

/// Create a copy of ClientAvailabilityStart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientAvailabilityStartCopyWith<_ClientAvailabilityStart> get copyWith => __$ClientAvailabilityStartCopyWithImpl<_ClientAvailabilityStart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientAvailabilityStartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientAvailabilityStart&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.localTime, localTime) || other.localTime == localTime)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.localEndTime, localEndTime) || other.localEndTime == localEndTime)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAt,localTime,endAt,localEndTime,label);

@override
String toString() {
  return 'ClientAvailabilityStart(startAt: $startAt, localTime: $localTime, endAt: $endAt, localEndTime: $localEndTime, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ClientAvailabilityStartCopyWith<$Res> implements $ClientAvailabilityStartCopyWith<$Res> {
  factory _$ClientAvailabilityStartCopyWith(_ClientAvailabilityStart value, $Res Function(_ClientAvailabilityStart) _then) = __$ClientAvailabilityStartCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientAvailabilityStart.startAtKey_) DateTime startAt,@JsonKey(name: ClientAvailabilityStart.localTimeKey_) String localTime,@JsonKey(name: ClientAvailabilityStart.endAtKey_) DateTime endAt,@JsonKey(name: ClientAvailabilityStart.localEndTimeKey_) String localEndTime,@JsonKey(name: ClientAvailabilityStart.labelKey_) String? label
});




}
/// @nodoc
class __$ClientAvailabilityStartCopyWithImpl<$Res>
    implements _$ClientAvailabilityStartCopyWith<$Res> {
  __$ClientAvailabilityStartCopyWithImpl(this._self, this._then);

  final _ClientAvailabilityStart _self;
  final $Res Function(_ClientAvailabilityStart) _then;

/// Create a copy of ClientAvailabilityStart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAt = null,Object? localTime = null,Object? endAt = null,Object? localEndTime = null,Object? label = freezed,}) {
  return _then(_ClientAvailabilityStart(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,localTime: null == localTime ? _self.localTime : localTime // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,localEndTime: null == localEndTime ? _self.localEndTime : localEndTime // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
