// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blackout_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlackoutCreateRequest {

/// startAt
@JsonKey(name: BlackoutCreateRequest.startAtKey_) DateTime get startAt;/// endAt
@JsonKey(name: BlackoutCreateRequest.endAtKey_) DateTime get endAt;/// reason
@JsonKey(name: BlackoutCreateRequest.reasonKey_) String? get reason;
/// Create a copy of BlackoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlackoutCreateRequestCopyWith<BlackoutCreateRequest> get copyWith => _$BlackoutCreateRequestCopyWithImpl<BlackoutCreateRequest>(this as BlackoutCreateRequest, _$identity);

  /// Serializes this BlackoutCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlackoutCreateRequest&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAt,endAt,reason);

@override
String toString() {
  return 'BlackoutCreateRequest(startAt: $startAt, endAt: $endAt, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $BlackoutCreateRequestCopyWith<$Res>  {
  factory $BlackoutCreateRequestCopyWith(BlackoutCreateRequest value, $Res Function(BlackoutCreateRequest) _then) = _$BlackoutCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BlackoutCreateRequest.startAtKey_) DateTime startAt,@JsonKey(name: BlackoutCreateRequest.endAtKey_) DateTime endAt,@JsonKey(name: BlackoutCreateRequest.reasonKey_) String? reason
});




}
/// @nodoc
class _$BlackoutCreateRequestCopyWithImpl<$Res>
    implements $BlackoutCreateRequestCopyWith<$Res> {
  _$BlackoutCreateRequestCopyWithImpl(this._self, this._then);

  final BlackoutCreateRequest _self;
  final $Res Function(BlackoutCreateRequest) _then;

/// Create a copy of BlackoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAt = null,Object? endAt = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlackoutCreateRequest].
extension BlackoutCreateRequestPatterns on BlackoutCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlackoutCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlackoutCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlackoutCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _BlackoutCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlackoutCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BlackoutCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BlackoutCreateRequest.startAtKey_)  DateTime startAt, @JsonKey(name: BlackoutCreateRequest.endAtKey_)  DateTime endAt, @JsonKey(name: BlackoutCreateRequest.reasonKey_)  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlackoutCreateRequest() when $default != null:
return $default(_that.startAt,_that.endAt,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BlackoutCreateRequest.startAtKey_)  DateTime startAt, @JsonKey(name: BlackoutCreateRequest.endAtKey_)  DateTime endAt, @JsonKey(name: BlackoutCreateRequest.reasonKey_)  String? reason)  $default,) {final _that = this;
switch (_that) {
case _BlackoutCreateRequest():
return $default(_that.startAt,_that.endAt,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BlackoutCreateRequest.startAtKey_)  DateTime startAt, @JsonKey(name: BlackoutCreateRequest.endAtKey_)  DateTime endAt, @JsonKey(name: BlackoutCreateRequest.reasonKey_)  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _BlackoutCreateRequest() when $default != null:
return $default(_that.startAt,_that.endAt,_that.reason);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BlackoutCreateRequest extends BlackoutCreateRequest {
  const _BlackoutCreateRequest({@JsonKey(name: BlackoutCreateRequest.startAtKey_) required this.startAt, @JsonKey(name: BlackoutCreateRequest.endAtKey_) required this.endAt, @JsonKey(name: BlackoutCreateRequest.reasonKey_) this.reason}): super._();
  factory _BlackoutCreateRequest.fromJson(Map<String, dynamic> json) => _$BlackoutCreateRequestFromJson(json);

/// startAt
@override@JsonKey(name: BlackoutCreateRequest.startAtKey_) final  DateTime startAt;
/// endAt
@override@JsonKey(name: BlackoutCreateRequest.endAtKey_) final  DateTime endAt;
/// reason
@override@JsonKey(name: BlackoutCreateRequest.reasonKey_) final  String? reason;

/// Create a copy of BlackoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlackoutCreateRequestCopyWith<_BlackoutCreateRequest> get copyWith => __$BlackoutCreateRequestCopyWithImpl<_BlackoutCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlackoutCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlackoutCreateRequest&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAt,endAt,reason);

@override
String toString() {
  return 'BlackoutCreateRequest(startAt: $startAt, endAt: $endAt, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$BlackoutCreateRequestCopyWith<$Res> implements $BlackoutCreateRequestCopyWith<$Res> {
  factory _$BlackoutCreateRequestCopyWith(_BlackoutCreateRequest value, $Res Function(_BlackoutCreateRequest) _then) = __$BlackoutCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BlackoutCreateRequest.startAtKey_) DateTime startAt,@JsonKey(name: BlackoutCreateRequest.endAtKey_) DateTime endAt,@JsonKey(name: BlackoutCreateRequest.reasonKey_) String? reason
});




}
/// @nodoc
class __$BlackoutCreateRequestCopyWithImpl<$Res>
    implements _$BlackoutCreateRequestCopyWith<$Res> {
  __$BlackoutCreateRequestCopyWithImpl(this._self, this._then);

  final _BlackoutCreateRequest _self;
  final $Res Function(_BlackoutCreateRequest) _then;

/// Create a copy of BlackoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAt = null,Object? endAt = null,Object? reason = freezed,}) {
  return _then(_BlackoutCreateRequest(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
