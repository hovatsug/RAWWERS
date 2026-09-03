// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upsell_create_intent_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpsellCreateIntentRequest {

/// pointsToSpend
@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_) int? get pointsToSpend;/// shareLinkId
@JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_) String? get shareLinkId;
/// Create a copy of UpsellCreateIntentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpsellCreateIntentRequestCopyWith<UpsellCreateIntentRequest> get copyWith => _$UpsellCreateIntentRequestCopyWithImpl<UpsellCreateIntentRequest>(this as UpsellCreateIntentRequest, _$identity);

  /// Serializes this UpsellCreateIntentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpsellCreateIntentRequest&&(identical(other.pointsToSpend, pointsToSpend) || other.pointsToSpend == pointsToSpend)&&(identical(other.shareLinkId, shareLinkId) || other.shareLinkId == shareLinkId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pointsToSpend,shareLinkId);

@override
String toString() {
  return 'UpsellCreateIntentRequest(pointsToSpend: $pointsToSpend, shareLinkId: $shareLinkId)';
}


}

/// @nodoc
abstract mixin class $UpsellCreateIntentRequestCopyWith<$Res>  {
  factory $UpsellCreateIntentRequestCopyWith(UpsellCreateIntentRequest value, $Res Function(UpsellCreateIntentRequest) _then) = _$UpsellCreateIntentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_) int? pointsToSpend,@JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_) String? shareLinkId
});




}
/// @nodoc
class _$UpsellCreateIntentRequestCopyWithImpl<$Res>
    implements $UpsellCreateIntentRequestCopyWith<$Res> {
  _$UpsellCreateIntentRequestCopyWithImpl(this._self, this._then);

  final UpsellCreateIntentRequest _self;
  final $Res Function(UpsellCreateIntentRequest) _then;

/// Create a copy of UpsellCreateIntentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pointsToSpend = freezed,Object? shareLinkId = freezed,}) {
  return _then(_self.copyWith(
pointsToSpend: freezed == pointsToSpend ? _self.pointsToSpend : pointsToSpend // ignore: cast_nullable_to_non_nullable
as int?,shareLinkId: freezed == shareLinkId ? _self.shareLinkId : shareLinkId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpsellCreateIntentRequest].
extension UpsellCreateIntentRequestPatterns on UpsellCreateIntentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpsellCreateIntentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpsellCreateIntentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpsellCreateIntentRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpsellCreateIntentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpsellCreateIntentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpsellCreateIntentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_)  int? pointsToSpend, @JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_)  String? shareLinkId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpsellCreateIntentRequest() when $default != null:
return $default(_that.pointsToSpend,_that.shareLinkId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_)  int? pointsToSpend, @JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_)  String? shareLinkId)  $default,) {final _that = this;
switch (_that) {
case _UpsellCreateIntentRequest():
return $default(_that.pointsToSpend,_that.shareLinkId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_)  int? pointsToSpend, @JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_)  String? shareLinkId)?  $default,) {final _that = this;
switch (_that) {
case _UpsellCreateIntentRequest() when $default != null:
return $default(_that.pointsToSpend,_that.shareLinkId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpsellCreateIntentRequest extends UpsellCreateIntentRequest {
  const _UpsellCreateIntentRequest({@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_) this.pointsToSpend, @JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_) this.shareLinkId}): super._();
  factory _UpsellCreateIntentRequest.fromJson(Map<String, dynamic> json) => _$UpsellCreateIntentRequestFromJson(json);

/// pointsToSpend
@override@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_) final  int? pointsToSpend;
/// shareLinkId
@override@JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_) final  String? shareLinkId;

/// Create a copy of UpsellCreateIntentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpsellCreateIntentRequestCopyWith<_UpsellCreateIntentRequest> get copyWith => __$UpsellCreateIntentRequestCopyWithImpl<_UpsellCreateIntentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpsellCreateIntentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpsellCreateIntentRequest&&(identical(other.pointsToSpend, pointsToSpend) || other.pointsToSpend == pointsToSpend)&&(identical(other.shareLinkId, shareLinkId) || other.shareLinkId == shareLinkId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pointsToSpend,shareLinkId);

@override
String toString() {
  return 'UpsellCreateIntentRequest(pointsToSpend: $pointsToSpend, shareLinkId: $shareLinkId)';
}


}

/// @nodoc
abstract mixin class _$UpsellCreateIntentRequestCopyWith<$Res> implements $UpsellCreateIntentRequestCopyWith<$Res> {
  factory _$UpsellCreateIntentRequestCopyWith(_UpsellCreateIntentRequest value, $Res Function(_UpsellCreateIntentRequest) _then) = __$UpsellCreateIntentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_) int? pointsToSpend,@JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_) String? shareLinkId
});




}
/// @nodoc
class __$UpsellCreateIntentRequestCopyWithImpl<$Res>
    implements _$UpsellCreateIntentRequestCopyWith<$Res> {
  __$UpsellCreateIntentRequestCopyWithImpl(this._self, this._then);

  final _UpsellCreateIntentRequest _self;
  final $Res Function(_UpsellCreateIntentRequest) _then;

/// Create a copy of UpsellCreateIntentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pointsToSpend = freezed,Object? shareLinkId = freezed,}) {
  return _then(_UpsellCreateIntentRequest(
pointsToSpend: freezed == pointsToSpend ? _self.pointsToSpend : pointsToSpend // ignore: cast_nullable_to_non_nullable
as int?,shareLinkId: freezed == shareLinkId ? _self.shareLinkId : shareLinkId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
