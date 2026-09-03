// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancel_slot_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CancelSlotRequest {

/// reason
@JsonKey(name: CancelSlotRequest.reasonKey_) String? get reason;
/// Create a copy of CancelSlotRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelSlotRequestCopyWith<CancelSlotRequest> get copyWith => _$CancelSlotRequestCopyWithImpl<CancelSlotRequest>(this as CancelSlotRequest, _$identity);

  /// Serializes this CancelSlotRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelSlotRequest&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'CancelSlotRequest(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $CancelSlotRequestCopyWith<$Res>  {
  factory $CancelSlotRequestCopyWith(CancelSlotRequest value, $Res Function(CancelSlotRequest) _then) = _$CancelSlotRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CancelSlotRequest.reasonKey_) String? reason
});




}
/// @nodoc
class _$CancelSlotRequestCopyWithImpl<$Res>
    implements $CancelSlotRequestCopyWith<$Res> {
  _$CancelSlotRequestCopyWithImpl(this._self, this._then);

  final CancelSlotRequest _self;
  final $Res Function(CancelSlotRequest) _then;

/// Create a copy of CancelSlotRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = freezed,}) {
  return _then(_self.copyWith(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CancelSlotRequest].
extension CancelSlotRequestPatterns on CancelSlotRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelSlotRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelSlotRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelSlotRequest value)  $default,){
final _that = this;
switch (_that) {
case _CancelSlotRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelSlotRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CancelSlotRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CancelSlotRequest.reasonKey_)  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CancelSlotRequest() when $default != null:
return $default(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CancelSlotRequest.reasonKey_)  String? reason)  $default,) {final _that = this;
switch (_that) {
case _CancelSlotRequest():
return $default(_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CancelSlotRequest.reasonKey_)  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _CancelSlotRequest() when $default != null:
return $default(_that.reason);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CancelSlotRequest extends CancelSlotRequest {
  const _CancelSlotRequest({@JsonKey(name: CancelSlotRequest.reasonKey_) this.reason}): super._();
  factory _CancelSlotRequest.fromJson(Map<String, dynamic> json) => _$CancelSlotRequestFromJson(json);

/// reason
@override@JsonKey(name: CancelSlotRequest.reasonKey_) final  String? reason;

/// Create a copy of CancelSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelSlotRequestCopyWith<_CancelSlotRequest> get copyWith => __$CancelSlotRequestCopyWithImpl<_CancelSlotRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CancelSlotRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelSlotRequest&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'CancelSlotRequest(reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$CancelSlotRequestCopyWith<$Res> implements $CancelSlotRequestCopyWith<$Res> {
  factory _$CancelSlotRequestCopyWith(_CancelSlotRequest value, $Res Function(_CancelSlotRequest) _then) = __$CancelSlotRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CancelSlotRequest.reasonKey_) String? reason
});




}
/// @nodoc
class __$CancelSlotRequestCopyWithImpl<$Res>
    implements _$CancelSlotRequestCopyWith<$Res> {
  __$CancelSlotRequestCopyWithImpl(this._self, this._then);

  final _CancelSlotRequest _self;
  final $Res Function(_CancelSlotRequest) _then;

/// Create a copy of CancelSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(_CancelSlotRequest(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
