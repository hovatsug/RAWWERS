// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_shelf_order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaceShelfOrderRequest {

/// itemId
@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_) String get itemId;/// clientRequestId
@JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_) String get clientRequestId;
/// Create a copy of PlaceShelfOrderRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceShelfOrderRequestCopyWith<PlaceShelfOrderRequest> get copyWith => _$PlaceShelfOrderRequestCopyWithImpl<PlaceShelfOrderRequest>(this as PlaceShelfOrderRequest, _$identity);

  /// Serializes this PlaceShelfOrderRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceShelfOrderRequest&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.clientRequestId, clientRequestId) || other.clientRequestId == clientRequestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,clientRequestId);

@override
String toString() {
  return 'PlaceShelfOrderRequest(itemId: $itemId, clientRequestId: $clientRequestId)';
}


}

/// @nodoc
abstract mixin class $PlaceShelfOrderRequestCopyWith<$Res>  {
  factory $PlaceShelfOrderRequestCopyWith(PlaceShelfOrderRequest value, $Res Function(PlaceShelfOrderRequest) _then) = _$PlaceShelfOrderRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_) String itemId,@JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_) String clientRequestId
});




}
/// @nodoc
class _$PlaceShelfOrderRequestCopyWithImpl<$Res>
    implements $PlaceShelfOrderRequestCopyWith<$Res> {
  _$PlaceShelfOrderRequestCopyWithImpl(this._self, this._then);

  final PlaceShelfOrderRequest _self;
  final $Res Function(PlaceShelfOrderRequest) _then;

/// Create a copy of PlaceShelfOrderRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? clientRequestId = null,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,clientRequestId: null == clientRequestId ? _self.clientRequestId : clientRequestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceShelfOrderRequest].
extension PlaceShelfOrderRequestPatterns on PlaceShelfOrderRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceShelfOrderRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceShelfOrderRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceShelfOrderRequest value)  $default,){
final _that = this;
switch (_that) {
case _PlaceShelfOrderRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceShelfOrderRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceShelfOrderRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_)  String itemId, @JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_)  String clientRequestId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceShelfOrderRequest() when $default != null:
return $default(_that.itemId,_that.clientRequestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_)  String itemId, @JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_)  String clientRequestId)  $default,) {final _that = this;
switch (_that) {
case _PlaceShelfOrderRequest():
return $default(_that.itemId,_that.clientRequestId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_)  String itemId, @JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_)  String clientRequestId)?  $default,) {final _that = this;
switch (_that) {
case _PlaceShelfOrderRequest() when $default != null:
return $default(_that.itemId,_that.clientRequestId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PlaceShelfOrderRequest extends PlaceShelfOrderRequest {
  const _PlaceShelfOrderRequest({@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_) required this.itemId, @JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_) required this.clientRequestId}): super._();
  factory _PlaceShelfOrderRequest.fromJson(Map<String, dynamic> json) => _$PlaceShelfOrderRequestFromJson(json);

/// itemId
@override@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_) final  String itemId;
/// clientRequestId
@override@JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_) final  String clientRequestId;

/// Create a copy of PlaceShelfOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceShelfOrderRequestCopyWith<_PlaceShelfOrderRequest> get copyWith => __$PlaceShelfOrderRequestCopyWithImpl<_PlaceShelfOrderRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceShelfOrderRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceShelfOrderRequest&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.clientRequestId, clientRequestId) || other.clientRequestId == clientRequestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,clientRequestId);

@override
String toString() {
  return 'PlaceShelfOrderRequest(itemId: $itemId, clientRequestId: $clientRequestId)';
}


}

/// @nodoc
abstract mixin class _$PlaceShelfOrderRequestCopyWith<$Res> implements $PlaceShelfOrderRequestCopyWith<$Res> {
  factory _$PlaceShelfOrderRequestCopyWith(_PlaceShelfOrderRequest value, $Res Function(_PlaceShelfOrderRequest) _then) = __$PlaceShelfOrderRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PlaceShelfOrderRequest.itemIdKey_) String itemId,@JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_) String clientRequestId
});




}
/// @nodoc
class __$PlaceShelfOrderRequestCopyWithImpl<$Res>
    implements _$PlaceShelfOrderRequestCopyWith<$Res> {
  __$PlaceShelfOrderRequestCopyWithImpl(this._self, this._then);

  final _PlaceShelfOrderRequest _self;
  final $Res Function(_PlaceShelfOrderRequest) _then;

/// Create a copy of PlaceShelfOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? clientRequestId = null,}) {
  return _then(_PlaceShelfOrderRequest(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,clientRequestId: null == clientRequestId ? _self.clientRequestId : clientRequestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
