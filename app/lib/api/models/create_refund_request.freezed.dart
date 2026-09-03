// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_refund_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateRefundRequest {

/// reason
@JsonKey(name: CreateRefundRequest.reasonKey_) String? get reason;
/// Create a copy of CreateRefundRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRefundRequestCopyWith<CreateRefundRequest> get copyWith => _$CreateRefundRequestCopyWithImpl<CreateRefundRequest>(this as CreateRefundRequest, _$identity);

  /// Serializes this CreateRefundRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRefundRequest&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'CreateRefundRequest(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $CreateRefundRequestCopyWith<$Res>  {
  factory $CreateRefundRequestCopyWith(CreateRefundRequest value, $Res Function(CreateRefundRequest) _then) = _$CreateRefundRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateRefundRequest.reasonKey_) String? reason
});




}
/// @nodoc
class _$CreateRefundRequestCopyWithImpl<$Res>
    implements $CreateRefundRequestCopyWith<$Res> {
  _$CreateRefundRequestCopyWithImpl(this._self, this._then);

  final CreateRefundRequest _self;
  final $Res Function(CreateRefundRequest) _then;

/// Create a copy of CreateRefundRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = freezed,}) {
  return _then(_self.copyWith(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRefundRequest].
extension CreateRefundRequestPatterns on CreateRefundRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRefundRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRefundRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRefundRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateRefundRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRefundRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRefundRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateRefundRequest.reasonKey_)  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRefundRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateRefundRequest.reasonKey_)  String? reason)  $default,) {final _that = this;
switch (_that) {
case _CreateRefundRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateRefundRequest.reasonKey_)  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _CreateRefundRequest() when $default != null:
return $default(_that.reason);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateRefundRequest extends CreateRefundRequest {
  const _CreateRefundRequest({@JsonKey(name: CreateRefundRequest.reasonKey_) this.reason}): super._();
  factory _CreateRefundRequest.fromJson(Map<String, dynamic> json) => _$CreateRefundRequestFromJson(json);

/// reason
@override@JsonKey(name: CreateRefundRequest.reasonKey_) final  String? reason;

/// Create a copy of CreateRefundRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRefundRequestCopyWith<_CreateRefundRequest> get copyWith => __$CreateRefundRequestCopyWithImpl<_CreateRefundRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRefundRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRefundRequest&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'CreateRefundRequest(reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$CreateRefundRequestCopyWith<$Res> implements $CreateRefundRequestCopyWith<$Res> {
  factory _$CreateRefundRequestCopyWith(_CreateRefundRequest value, $Res Function(_CreateRefundRequest) _then) = __$CreateRefundRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateRefundRequest.reasonKey_) String? reason
});




}
/// @nodoc
class __$CreateRefundRequestCopyWithImpl<$Res>
    implements _$CreateRefundRequestCopyWith<$Res> {
  __$CreateRefundRequestCopyWithImpl(this._self, this._then);

  final _CreateRefundRequest _self;
  final $Res Function(_CreateRefundRequest) _then;

/// Create a copy of CreateRefundRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(_CreateRefundRequest(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
