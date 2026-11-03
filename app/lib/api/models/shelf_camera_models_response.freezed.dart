// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_camera_models_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfCameraModelsResponse {

/// items
@JsonKey(name: ShelfCameraModelsResponse.itemsKey_) List<ShelfCameraModelView> get items;
/// Create a copy of ShelfCameraModelsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfCameraModelsResponseCopyWith<ShelfCameraModelsResponse> get copyWith => _$ShelfCameraModelsResponseCopyWithImpl<ShelfCameraModelsResponse>(this as ShelfCameraModelsResponse, _$identity);

  /// Serializes this ShelfCameraModelsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfCameraModelsResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ShelfCameraModelsResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $ShelfCameraModelsResponseCopyWith<$Res>  {
  factory $ShelfCameraModelsResponseCopyWith(ShelfCameraModelsResponse value, $Res Function(ShelfCameraModelsResponse) _then) = _$ShelfCameraModelsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfCameraModelsResponse.itemsKey_) List<ShelfCameraModelView> items
});




}
/// @nodoc
class _$ShelfCameraModelsResponseCopyWithImpl<$Res>
    implements $ShelfCameraModelsResponseCopyWith<$Res> {
  _$ShelfCameraModelsResponseCopyWithImpl(this._self, this._then);

  final ShelfCameraModelsResponse _self;
  final $Res Function(ShelfCameraModelsResponse) _then;

/// Create a copy of ShelfCameraModelsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ShelfCameraModelView>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfCameraModelsResponse].
extension ShelfCameraModelsResponsePatterns on ShelfCameraModelsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfCameraModelsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfCameraModelsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfCameraModelsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ShelfCameraModelsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfCameraModelsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfCameraModelsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfCameraModelsResponse.itemsKey_)  List<ShelfCameraModelView> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfCameraModelsResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfCameraModelsResponse.itemsKey_)  List<ShelfCameraModelView> items)  $default,) {final _that = this;
switch (_that) {
case _ShelfCameraModelsResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfCameraModelsResponse.itemsKey_)  List<ShelfCameraModelView> items)?  $default,) {final _that = this;
switch (_that) {
case _ShelfCameraModelsResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfCameraModelsResponse extends ShelfCameraModelsResponse {
  const _ShelfCameraModelsResponse({@JsonKey(name: ShelfCameraModelsResponse.itemsKey_) required final  List<ShelfCameraModelView> items}): _items = items,super._();
  factory _ShelfCameraModelsResponse.fromJson(Map<String, dynamic> json) => _$ShelfCameraModelsResponseFromJson(json);

/// items
 final  List<ShelfCameraModelView> _items;
/// items
@override@JsonKey(name: ShelfCameraModelsResponse.itemsKey_) List<ShelfCameraModelView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ShelfCameraModelsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfCameraModelsResponseCopyWith<_ShelfCameraModelsResponse> get copyWith => __$ShelfCameraModelsResponseCopyWithImpl<_ShelfCameraModelsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfCameraModelsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfCameraModelsResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ShelfCameraModelsResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ShelfCameraModelsResponseCopyWith<$Res> implements $ShelfCameraModelsResponseCopyWith<$Res> {
  factory _$ShelfCameraModelsResponseCopyWith(_ShelfCameraModelsResponse value, $Res Function(_ShelfCameraModelsResponse) _then) = __$ShelfCameraModelsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfCameraModelsResponse.itemsKey_) List<ShelfCameraModelView> items
});




}
/// @nodoc
class __$ShelfCameraModelsResponseCopyWithImpl<$Res>
    implements _$ShelfCameraModelsResponseCopyWith<$Res> {
  __$ShelfCameraModelsResponseCopyWithImpl(this._self, this._then);

  final _ShelfCameraModelsResponse _self;
  final $Res Function(_ShelfCameraModelsResponse) _then;

/// Create a copy of ShelfCameraModelsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_ShelfCameraModelsResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ShelfCameraModelView>,
  ));
}


}

// dart format on
