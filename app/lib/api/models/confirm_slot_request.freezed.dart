// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirm_slot_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfirmSlotRequest {

/// startAtUtc
@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_) DateTime get startAtUtc;/// endAtUtc
@JsonKey(name: ConfirmSlotRequest.endAtUtcKey_) DateTime get endAtUtc;
/// Create a copy of ConfirmSlotRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmSlotRequestCopyWith<ConfirmSlotRequest> get copyWith => _$ConfirmSlotRequestCopyWithImpl<ConfirmSlotRequest>(this as ConfirmSlotRequest, _$identity);

  /// Serializes this ConfirmSlotRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmSlotRequest&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc);

@override
String toString() {
  return 'ConfirmSlotRequest(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc)';
}


}

/// @nodoc
abstract mixin class $ConfirmSlotRequestCopyWith<$Res>  {
  factory $ConfirmSlotRequestCopyWith(ConfirmSlotRequest value, $Res Function(ConfirmSlotRequest) _then) = _$ConfirmSlotRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: ConfirmSlotRequest.endAtUtcKey_) DateTime endAtUtc
});




}
/// @nodoc
class _$ConfirmSlotRequestCopyWithImpl<$Res>
    implements $ConfirmSlotRequestCopyWith<$Res> {
  _$ConfirmSlotRequestCopyWithImpl(this._self, this._then);

  final ConfirmSlotRequest _self;
  final $Res Function(ConfirmSlotRequest) _then;

/// Create a copy of ConfirmSlotRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAtUtc = null,Object? endAtUtc = null,}) {
  return _then(_self.copyWith(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmSlotRequest].
extension ConfirmSlotRequestPatterns on ConfirmSlotRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmSlotRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmSlotRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmSlotRequest value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmSlotRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmSlotRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmSlotRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: ConfirmSlotRequest.endAtUtcKey_)  DateTime endAtUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmSlotRequest() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: ConfirmSlotRequest.endAtUtcKey_)  DateTime endAtUtc)  $default,) {final _that = this;
switch (_that) {
case _ConfirmSlotRequest():
return $default(_that.startAtUtc,_that.endAtUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: ConfirmSlotRequest.endAtUtcKey_)  DateTime endAtUtc)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmSlotRequest() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ConfirmSlotRequest extends ConfirmSlotRequest {
  const _ConfirmSlotRequest({@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_) required this.startAtUtc, @JsonKey(name: ConfirmSlotRequest.endAtUtcKey_) required this.endAtUtc}): super._();
  factory _ConfirmSlotRequest.fromJson(Map<String, dynamic> json) => _$ConfirmSlotRequestFromJson(json);

/// startAtUtc
@override@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_) final  DateTime startAtUtc;
/// endAtUtc
@override@JsonKey(name: ConfirmSlotRequest.endAtUtcKey_) final  DateTime endAtUtc;

/// Create a copy of ConfirmSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmSlotRequestCopyWith<_ConfirmSlotRequest> get copyWith => __$ConfirmSlotRequestCopyWithImpl<_ConfirmSlotRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmSlotRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmSlotRequest&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc);

@override
String toString() {
  return 'ConfirmSlotRequest(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc)';
}


}

/// @nodoc
abstract mixin class _$ConfirmSlotRequestCopyWith<$Res> implements $ConfirmSlotRequestCopyWith<$Res> {
  factory _$ConfirmSlotRequestCopyWith(_ConfirmSlotRequest value, $Res Function(_ConfirmSlotRequest) _then) = __$ConfirmSlotRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ConfirmSlotRequest.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: ConfirmSlotRequest.endAtUtcKey_) DateTime endAtUtc
});




}
/// @nodoc
class __$ConfirmSlotRequestCopyWithImpl<$Res>
    implements _$ConfirmSlotRequestCopyWith<$Res> {
  __$ConfirmSlotRequestCopyWithImpl(this._self, this._then);

  final _ConfirmSlotRequest _self;
  final $Res Function(_ConfirmSlotRequest) _then;

/// Create a copy of ConfirmSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAtUtc = null,Object? endAtUtc = null,}) {
  return _then(_ConfirmSlotRequest(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
