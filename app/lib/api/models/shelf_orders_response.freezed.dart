// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_orders_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfOrdersResponse {

/// items
@JsonKey(name: ShelfOrdersResponse.itemsKey_) List<ShelfOrderView> get items;
/// Create a copy of ShelfOrdersResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfOrdersResponseCopyWith<ShelfOrdersResponse> get copyWith => _$ShelfOrdersResponseCopyWithImpl<ShelfOrdersResponse>(this as ShelfOrdersResponse, _$identity);

  /// Serializes this ShelfOrdersResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfOrdersResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ShelfOrdersResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $ShelfOrdersResponseCopyWith<$Res>  {
  factory $ShelfOrdersResponseCopyWith(ShelfOrdersResponse value, $Res Function(ShelfOrdersResponse) _then) = _$ShelfOrdersResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfOrdersResponse.itemsKey_) List<ShelfOrderView> items
});




}
/// @nodoc
class _$ShelfOrdersResponseCopyWithImpl<$Res>
    implements $ShelfOrdersResponseCopyWith<$Res> {
  _$ShelfOrdersResponseCopyWithImpl(this._self, this._then);

  final ShelfOrdersResponse _self;
  final $Res Function(ShelfOrdersResponse) _then;

/// Create a copy of ShelfOrdersResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ShelfOrderView>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfOrdersResponse].
extension ShelfOrdersResponsePatterns on ShelfOrdersResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfOrdersResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfOrdersResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfOrdersResponse value)  $default,){
final _that = this;
switch (_that) {
case _ShelfOrdersResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfOrdersResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfOrdersResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfOrdersResponse.itemsKey_)  List<ShelfOrderView> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfOrdersResponse() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfOrdersResponse.itemsKey_)  List<ShelfOrderView> items)  $default,) {final _that = this;
switch (_that) {
case _ShelfOrdersResponse():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfOrdersResponse.itemsKey_)  List<ShelfOrderView> items)?  $default,) {final _that = this;
switch (_that) {
case _ShelfOrdersResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfOrdersResponse extends ShelfOrdersResponse {
  const _ShelfOrdersResponse({@JsonKey(name: ShelfOrdersResponse.itemsKey_) required final  List<ShelfOrderView> items}): _items = items,super._();
  factory _ShelfOrdersResponse.fromJson(Map<String, dynamic> json) => _$ShelfOrdersResponseFromJson(json);

/// items
 final  List<ShelfOrderView> _items;
/// items
@override@JsonKey(name: ShelfOrdersResponse.itemsKey_) List<ShelfOrderView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ShelfOrdersResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfOrdersResponseCopyWith<_ShelfOrdersResponse> get copyWith => __$ShelfOrdersResponseCopyWithImpl<_ShelfOrdersResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfOrdersResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfOrdersResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ShelfOrdersResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ShelfOrdersResponseCopyWith<$Res> implements $ShelfOrdersResponseCopyWith<$Res> {
  factory _$ShelfOrdersResponseCopyWith(_ShelfOrdersResponse value, $Res Function(_ShelfOrdersResponse) _then) = __$ShelfOrdersResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfOrdersResponse.itemsKey_) List<ShelfOrderView> items
});




}
/// @nodoc
class __$ShelfOrdersResponseCopyWithImpl<$Res>
    implements _$ShelfOrdersResponseCopyWith<$Res> {
  __$ShelfOrdersResponseCopyWithImpl(this._self, this._then);

  final _ShelfOrdersResponse _self;
  final $Res Function(_ShelfOrdersResponse) _then;

/// Create a copy of ShelfOrdersResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_ShelfOrdersResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ShelfOrderView>,
  ));
}


}

// dart format on
