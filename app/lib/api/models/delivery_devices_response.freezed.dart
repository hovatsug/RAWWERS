// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_devices_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryDevicesResponse {

/// items
@JsonKey(name: DeliveryDevicesResponse.itemsKey_) List<DeliveryDeviceView> get items;/// maxDevices
@JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_) int get maxDevices;
/// Create a copy of DeliveryDevicesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryDevicesResponseCopyWith<DeliveryDevicesResponse> get copyWith => _$DeliveryDevicesResponseCopyWithImpl<DeliveryDevicesResponse>(this as DeliveryDevicesResponse, _$identity);

  /// Serializes this DeliveryDevicesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryDevicesResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.maxDevices, maxDevices) || other.maxDevices == maxDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),maxDevices);

@override
String toString() {
  return 'DeliveryDevicesResponse(items: $items, maxDevices: $maxDevices)';
}


}

/// @nodoc
abstract mixin class $DeliveryDevicesResponseCopyWith<$Res>  {
  factory $DeliveryDevicesResponseCopyWith(DeliveryDevicesResponse value, $Res Function(DeliveryDevicesResponse) _then) = _$DeliveryDevicesResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DeliveryDevicesResponse.itemsKey_) List<DeliveryDeviceView> items,@JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_) int maxDevices
});




}
/// @nodoc
class _$DeliveryDevicesResponseCopyWithImpl<$Res>
    implements $DeliveryDevicesResponseCopyWith<$Res> {
  _$DeliveryDevicesResponseCopyWithImpl(this._self, this._then);

  final DeliveryDevicesResponse _self;
  final $Res Function(DeliveryDevicesResponse) _then;

/// Create a copy of DeliveryDevicesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? maxDevices = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<DeliveryDeviceView>,maxDevices: null == maxDevices ? _self.maxDevices : maxDevices // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryDevicesResponse].
extension DeliveryDevicesResponsePatterns on DeliveryDevicesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryDevicesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryDevicesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryDevicesResponse value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryDevicesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryDevicesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryDevicesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DeliveryDevicesResponse.itemsKey_)  List<DeliveryDeviceView> items, @JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_)  int maxDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryDevicesResponse() when $default != null:
return $default(_that.items,_that.maxDevices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DeliveryDevicesResponse.itemsKey_)  List<DeliveryDeviceView> items, @JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_)  int maxDevices)  $default,) {final _that = this;
switch (_that) {
case _DeliveryDevicesResponse():
return $default(_that.items,_that.maxDevices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DeliveryDevicesResponse.itemsKey_)  List<DeliveryDeviceView> items, @JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_)  int maxDevices)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryDevicesResponse() when $default != null:
return $default(_that.items,_that.maxDevices);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DeliveryDevicesResponse extends DeliveryDevicesResponse {
  const _DeliveryDevicesResponse({@JsonKey(name: DeliveryDevicesResponse.itemsKey_) required final  List<DeliveryDeviceView> items, @JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_) required this.maxDevices}): _items = items,super._();
  factory _DeliveryDevicesResponse.fromJson(Map<String, dynamic> json) => _$DeliveryDevicesResponseFromJson(json);

/// items
 final  List<DeliveryDeviceView> _items;
/// items
@override@JsonKey(name: DeliveryDevicesResponse.itemsKey_) List<DeliveryDeviceView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// maxDevices
@override@JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_) final  int maxDevices;

/// Create a copy of DeliveryDevicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryDevicesResponseCopyWith<_DeliveryDevicesResponse> get copyWith => __$DeliveryDevicesResponseCopyWithImpl<_DeliveryDevicesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryDevicesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryDevicesResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.maxDevices, maxDevices) || other.maxDevices == maxDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),maxDevices);

@override
String toString() {
  return 'DeliveryDevicesResponse(items: $items, maxDevices: $maxDevices)';
}


}

/// @nodoc
abstract mixin class _$DeliveryDevicesResponseCopyWith<$Res> implements $DeliveryDevicesResponseCopyWith<$Res> {
  factory _$DeliveryDevicesResponseCopyWith(_DeliveryDevicesResponse value, $Res Function(_DeliveryDevicesResponse) _then) = __$DeliveryDevicesResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DeliveryDevicesResponse.itemsKey_) List<DeliveryDeviceView> items,@JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_) int maxDevices
});




}
/// @nodoc
class __$DeliveryDevicesResponseCopyWithImpl<$Res>
    implements _$DeliveryDevicesResponseCopyWith<$Res> {
  __$DeliveryDevicesResponseCopyWithImpl(this._self, this._then);

  final _DeliveryDevicesResponse _self;
  final $Res Function(_DeliveryDevicesResponse) _then;

/// Create a copy of DeliveryDevicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? maxDevices = null,}) {
  return _then(_DeliveryDevicesResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<DeliveryDeviceView>,maxDevices: null == maxDevices ? _self.maxDevices : maxDevices // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
