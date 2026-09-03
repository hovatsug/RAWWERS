// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reschedule_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RescheduleRequest {

/// clientTimezone
@JsonKey(name: RescheduleRequest.clientTimezoneKey_) String get clientTimezone;/// proposedWindows
@JsonKey(name: RescheduleRequest.proposedWindowsKey_) List<TimeWindowItem>? get proposedWindows;
/// Create a copy of RescheduleRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RescheduleRequestCopyWith<RescheduleRequest> get copyWith => _$RescheduleRequestCopyWithImpl<RescheduleRequest>(this as RescheduleRequest, _$identity);

  /// Serializes this RescheduleRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RescheduleRequest&&(identical(other.clientTimezone, clientTimezone) || other.clientTimezone == clientTimezone)&&const DeepCollectionEquality().equals(other.proposedWindows, proposedWindows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientTimezone,const DeepCollectionEquality().hash(proposedWindows));

@override
String toString() {
  return 'RescheduleRequest(clientTimezone: $clientTimezone, proposedWindows: $proposedWindows)';
}


}

/// @nodoc
abstract mixin class $RescheduleRequestCopyWith<$Res>  {
  factory $RescheduleRequestCopyWith(RescheduleRequest value, $Res Function(RescheduleRequest) _then) = _$RescheduleRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: RescheduleRequest.clientTimezoneKey_) String clientTimezone,@JsonKey(name: RescheduleRequest.proposedWindowsKey_) List<TimeWindowItem>? proposedWindows
});




}
/// @nodoc
class _$RescheduleRequestCopyWithImpl<$Res>
    implements $RescheduleRequestCopyWith<$Res> {
  _$RescheduleRequestCopyWithImpl(this._self, this._then);

  final RescheduleRequest _self;
  final $Res Function(RescheduleRequest) _then;

/// Create a copy of RescheduleRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientTimezone = null,Object? proposedWindows = freezed,}) {
  return _then(_self.copyWith(
clientTimezone: null == clientTimezone ? _self.clientTimezone : clientTimezone // ignore: cast_nullable_to_non_nullable
as String,proposedWindows: freezed == proposedWindows ? _self.proposedWindows : proposedWindows // ignore: cast_nullable_to_non_nullable
as List<TimeWindowItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RescheduleRequest].
extension RescheduleRequestPatterns on RescheduleRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RescheduleRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RescheduleRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RescheduleRequest value)  $default,){
final _that = this;
switch (_that) {
case _RescheduleRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RescheduleRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RescheduleRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: RescheduleRequest.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: RescheduleRequest.proposedWindowsKey_)  List<TimeWindowItem>? proposedWindows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RescheduleRequest() when $default != null:
return $default(_that.clientTimezone,_that.proposedWindows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: RescheduleRequest.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: RescheduleRequest.proposedWindowsKey_)  List<TimeWindowItem>? proposedWindows)  $default,) {final _that = this;
switch (_that) {
case _RescheduleRequest():
return $default(_that.clientTimezone,_that.proposedWindows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: RescheduleRequest.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: RescheduleRequest.proposedWindowsKey_)  List<TimeWindowItem>? proposedWindows)?  $default,) {final _that = this;
switch (_that) {
case _RescheduleRequest() when $default != null:
return $default(_that.clientTimezone,_that.proposedWindows);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _RescheduleRequest extends RescheduleRequest {
  const _RescheduleRequest({@JsonKey(name: RescheduleRequest.clientTimezoneKey_) required this.clientTimezone, @JsonKey(name: RescheduleRequest.proposedWindowsKey_) final  List<TimeWindowItem>? proposedWindows}): _proposedWindows = proposedWindows,super._();
  factory _RescheduleRequest.fromJson(Map<String, dynamic> json) => _$RescheduleRequestFromJson(json);

/// clientTimezone
@override@JsonKey(name: RescheduleRequest.clientTimezoneKey_) final  String clientTimezone;
/// proposedWindows
 final  List<TimeWindowItem>? _proposedWindows;
/// proposedWindows
@override@JsonKey(name: RescheduleRequest.proposedWindowsKey_) List<TimeWindowItem>? get proposedWindows {
  final value = _proposedWindows;
  if (value == null) return null;
  if (_proposedWindows is EqualUnmodifiableListView) return _proposedWindows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RescheduleRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RescheduleRequestCopyWith<_RescheduleRequest> get copyWith => __$RescheduleRequestCopyWithImpl<_RescheduleRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RescheduleRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RescheduleRequest&&(identical(other.clientTimezone, clientTimezone) || other.clientTimezone == clientTimezone)&&const DeepCollectionEquality().equals(other._proposedWindows, _proposedWindows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientTimezone,const DeepCollectionEquality().hash(_proposedWindows));

@override
String toString() {
  return 'RescheduleRequest(clientTimezone: $clientTimezone, proposedWindows: $proposedWindows)';
}


}

/// @nodoc
abstract mixin class _$RescheduleRequestCopyWith<$Res> implements $RescheduleRequestCopyWith<$Res> {
  factory _$RescheduleRequestCopyWith(_RescheduleRequest value, $Res Function(_RescheduleRequest) _then) = __$RescheduleRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: RescheduleRequest.clientTimezoneKey_) String clientTimezone,@JsonKey(name: RescheduleRequest.proposedWindowsKey_) List<TimeWindowItem>? proposedWindows
});




}
/// @nodoc
class __$RescheduleRequestCopyWithImpl<$Res>
    implements _$RescheduleRequestCopyWith<$Res> {
  __$RescheduleRequestCopyWithImpl(this._self, this._then);

  final _RescheduleRequest _self;
  final $Res Function(_RescheduleRequest) _then;

/// Create a copy of RescheduleRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientTimezone = null,Object? proposedWindows = freezed,}) {
  return _then(_RescheduleRequest(
clientTimezone: null == clientTimezone ? _self.clientTimezone : clientTimezone // ignore: cast_nullable_to_non_nullable
as String,proposedWindows: freezed == proposedWindows ? _self._proposedWindows : proposedWindows // ignore: cast_nullable_to_non_nullable
as List<TimeWindowItem>?,
  ));
}


}

// dart format on
