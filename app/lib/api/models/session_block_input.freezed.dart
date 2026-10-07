// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_block_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionBlockInput {

/// label
@JsonKey(name: SessionBlockInput.labelKey_) SessionBlockLabel get label;/// startTime
@JsonKey(name: SessionBlockInput.startTimeKey_) String get startTime;/// endTime
@JsonKey(name: SessionBlockInput.endTimeKey_) String get endTime;
/// Create a copy of SessionBlockInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionBlockInputCopyWith<SessionBlockInput> get copyWith => _$SessionBlockInputCopyWithImpl<SessionBlockInput>(this as SessionBlockInput, _$identity);

  /// Serializes this SessionBlockInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionBlockInput&&(identical(other.label, label) || other.label == label)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,startTime,endTime);

@override
String toString() {
  return 'SessionBlockInput(label: $label, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $SessionBlockInputCopyWith<$Res>  {
  factory $SessionBlockInputCopyWith(SessionBlockInput value, $Res Function(SessionBlockInput) _then) = _$SessionBlockInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SessionBlockInput.labelKey_) SessionBlockLabel label,@JsonKey(name: SessionBlockInput.startTimeKey_) String startTime,@JsonKey(name: SessionBlockInput.endTimeKey_) String endTime
});




}
/// @nodoc
class _$SessionBlockInputCopyWithImpl<$Res>
    implements $SessionBlockInputCopyWith<$Res> {
  _$SessionBlockInputCopyWithImpl(this._self, this._then);

  final SessionBlockInput _self;
  final $Res Function(SessionBlockInput) _then;

/// Create a copy of SessionBlockInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SessionBlockLabel,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionBlockInput].
extension SessionBlockInputPatterns on SessionBlockInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionBlockInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionBlockInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionBlockInput value)  $default,){
final _that = this;
switch (_that) {
case _SessionBlockInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionBlockInput value)?  $default,){
final _that = this;
switch (_that) {
case _SessionBlockInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SessionBlockInput.labelKey_)  SessionBlockLabel label, @JsonKey(name: SessionBlockInput.startTimeKey_)  String startTime, @JsonKey(name: SessionBlockInput.endTimeKey_)  String endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionBlockInput() when $default != null:
return $default(_that.label,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SessionBlockInput.labelKey_)  SessionBlockLabel label, @JsonKey(name: SessionBlockInput.startTimeKey_)  String startTime, @JsonKey(name: SessionBlockInput.endTimeKey_)  String endTime)  $default,) {final _that = this;
switch (_that) {
case _SessionBlockInput():
return $default(_that.label,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SessionBlockInput.labelKey_)  SessionBlockLabel label, @JsonKey(name: SessionBlockInput.startTimeKey_)  String startTime, @JsonKey(name: SessionBlockInput.endTimeKey_)  String endTime)?  $default,) {final _that = this;
switch (_that) {
case _SessionBlockInput() when $default != null:
return $default(_that.label,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SessionBlockInput extends SessionBlockInput {
  const _SessionBlockInput({@JsonKey(name: SessionBlockInput.labelKey_) required this.label, @JsonKey(name: SessionBlockInput.startTimeKey_) required this.startTime, @JsonKey(name: SessionBlockInput.endTimeKey_) required this.endTime}): super._();
  factory _SessionBlockInput.fromJson(Map<String, dynamic> json) => _$SessionBlockInputFromJson(json);

/// label
@override@JsonKey(name: SessionBlockInput.labelKey_) final  SessionBlockLabel label;
/// startTime
@override@JsonKey(name: SessionBlockInput.startTimeKey_) final  String startTime;
/// endTime
@override@JsonKey(name: SessionBlockInput.endTimeKey_) final  String endTime;

/// Create a copy of SessionBlockInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionBlockInputCopyWith<_SessionBlockInput> get copyWith => __$SessionBlockInputCopyWithImpl<_SessionBlockInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionBlockInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionBlockInput&&(identical(other.label, label) || other.label == label)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,startTime,endTime);

@override
String toString() {
  return 'SessionBlockInput(label: $label, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$SessionBlockInputCopyWith<$Res> implements $SessionBlockInputCopyWith<$Res> {
  factory _$SessionBlockInputCopyWith(_SessionBlockInput value, $Res Function(_SessionBlockInput) _then) = __$SessionBlockInputCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SessionBlockInput.labelKey_) SessionBlockLabel label,@JsonKey(name: SessionBlockInput.startTimeKey_) String startTime,@JsonKey(name: SessionBlockInput.endTimeKey_) String endTime
});




}
/// @nodoc
class __$SessionBlockInputCopyWithImpl<$Res>
    implements _$SessionBlockInputCopyWith<$Res> {
  __$SessionBlockInputCopyWithImpl(this._self, this._then);

  final _SessionBlockInput _self;
  final $Res Function(_SessionBlockInput) _then;

/// Create a copy of SessionBlockInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_SessionBlockInput(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SessionBlockLabel,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
