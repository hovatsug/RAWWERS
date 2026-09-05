// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduling_slots_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulingSlotsResponse {

/// slots
@JsonKey(name: SchedulingSlotsResponse.slotsKey_) List<SchedulingSlotView>? get slots;
/// Create a copy of SchedulingSlotsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulingSlotsResponseCopyWith<SchedulingSlotsResponse> get copyWith => _$SchedulingSlotsResponseCopyWithImpl<SchedulingSlotsResponse>(this as SchedulingSlotsResponse, _$identity);

  /// Serializes this SchedulingSlotsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulingSlotsResponse&&const DeepCollectionEquality().equals(other.slots, slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(slots));

@override
String toString() {
  return 'SchedulingSlotsResponse(slots: $slots)';
}


}

/// @nodoc
abstract mixin class $SchedulingSlotsResponseCopyWith<$Res>  {
  factory $SchedulingSlotsResponseCopyWith(SchedulingSlotsResponse value, $Res Function(SchedulingSlotsResponse) _then) = _$SchedulingSlotsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SchedulingSlotsResponse.slotsKey_) List<SchedulingSlotView>? slots
});




}
/// @nodoc
class _$SchedulingSlotsResponseCopyWithImpl<$Res>
    implements $SchedulingSlotsResponseCopyWith<$Res> {
  _$SchedulingSlotsResponseCopyWithImpl(this._self, this._then);

  final SchedulingSlotsResponse _self;
  final $Res Function(SchedulingSlotsResponse) _then;

/// Create a copy of SchedulingSlotsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slots = freezed,}) {
  return _then(_self.copyWith(
slots: freezed == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<SchedulingSlotView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulingSlotsResponse].
extension SchedulingSlotsResponsePatterns on SchedulingSlotsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulingSlotsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulingSlotsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulingSlotsResponse value)  $default,){
final _that = this;
switch (_that) {
case _SchedulingSlotsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulingSlotsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulingSlotsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingSlotsResponse.slotsKey_)  List<SchedulingSlotView>? slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulingSlotsResponse() when $default != null:
return $default(_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingSlotsResponse.slotsKey_)  List<SchedulingSlotView>? slots)  $default,) {final _that = this;
switch (_that) {
case _SchedulingSlotsResponse():
return $default(_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SchedulingSlotsResponse.slotsKey_)  List<SchedulingSlotView>? slots)?  $default,) {final _that = this;
switch (_that) {
case _SchedulingSlotsResponse() when $default != null:
return $default(_that.slots);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SchedulingSlotsResponse extends SchedulingSlotsResponse {
  const _SchedulingSlotsResponse({@JsonKey(name: SchedulingSlotsResponse.slotsKey_) final  List<SchedulingSlotView>? slots}): _slots = slots,super._();
  factory _SchedulingSlotsResponse.fromJson(Map<String, dynamic> json) => _$SchedulingSlotsResponseFromJson(json);

/// slots
 final  List<SchedulingSlotView>? _slots;
/// slots
@override@JsonKey(name: SchedulingSlotsResponse.slotsKey_) List<SchedulingSlotView>? get slots {
  final value = _slots;
  if (value == null) return null;
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SchedulingSlotsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulingSlotsResponseCopyWith<_SchedulingSlotsResponse> get copyWith => __$SchedulingSlotsResponseCopyWithImpl<_SchedulingSlotsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulingSlotsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulingSlotsResponse&&const DeepCollectionEquality().equals(other._slots, _slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_slots));

@override
String toString() {
  return 'SchedulingSlotsResponse(slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$SchedulingSlotsResponseCopyWith<$Res> implements $SchedulingSlotsResponseCopyWith<$Res> {
  factory _$SchedulingSlotsResponseCopyWith(_SchedulingSlotsResponse value, $Res Function(_SchedulingSlotsResponse) _then) = __$SchedulingSlotsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SchedulingSlotsResponse.slotsKey_) List<SchedulingSlotView>? slots
});




}
/// @nodoc
class __$SchedulingSlotsResponseCopyWithImpl<$Res>
    implements _$SchedulingSlotsResponseCopyWith<$Res> {
  __$SchedulingSlotsResponseCopyWithImpl(this._self, this._then);

  final _SchedulingSlotsResponse _self;
  final $Res Function(_SchedulingSlotsResponse) _then;

/// Create a copy of SchedulingSlotsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slots = freezed,}) {
  return _then(_SchedulingSlotsResponse(
slots: freezed == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<SchedulingSlotView>?,
  ));
}


}

// dart format on
