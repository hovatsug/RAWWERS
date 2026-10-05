// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gear_verification_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GearVerificationListResponse {

/// items
@JsonKey(name: GearVerificationListResponse.itemsKey_) List<GearVerificationView>? get items;/// floor
@JsonKey(name: GearVerificationListResponse.floorKey_) GearFloorView get floor;
/// Create a copy of GearVerificationListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GearVerificationListResponseCopyWith<GearVerificationListResponse> get copyWith => _$GearVerificationListResponseCopyWithImpl<GearVerificationListResponse>(this as GearVerificationListResponse, _$identity);

  /// Serializes this GearVerificationListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GearVerificationListResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.floor, floor) || other.floor == floor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),floor);

@override
String toString() {
  return 'GearVerificationListResponse(items: $items, floor: $floor)';
}


}

/// @nodoc
abstract mixin class $GearVerificationListResponseCopyWith<$Res>  {
  factory $GearVerificationListResponseCopyWith(GearVerificationListResponse value, $Res Function(GearVerificationListResponse) _then) = _$GearVerificationListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GearVerificationListResponse.itemsKey_) List<GearVerificationView>? items,@JsonKey(name: GearVerificationListResponse.floorKey_) GearFloorView floor
});


$GearFloorViewCopyWith<$Res> get floor;

}
/// @nodoc
class _$GearVerificationListResponseCopyWithImpl<$Res>
    implements $GearVerificationListResponseCopyWith<$Res> {
  _$GearVerificationListResponseCopyWithImpl(this._self, this._then);

  final GearVerificationListResponse _self;
  final $Res Function(GearVerificationListResponse) _then;

/// Create a copy of GearVerificationListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,Object? floor = null,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GearVerificationView>?,floor: null == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as GearFloorView,
  ));
}
/// Create a copy of GearVerificationListResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GearFloorViewCopyWith<$Res> get floor {
  
  return $GearFloorViewCopyWith<$Res>(_self.floor, (value) {
    return _then(_self.copyWith(floor: value));
  });
}
}


/// Adds pattern-matching-related methods to [GearVerificationListResponse].
extension GearVerificationListResponsePatterns on GearVerificationListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GearVerificationListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GearVerificationListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GearVerificationListResponse value)  $default,){
final _that = this;
switch (_that) {
case _GearVerificationListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GearVerificationListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GearVerificationListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GearVerificationListResponse.itemsKey_)  List<GearVerificationView>? items, @JsonKey(name: GearVerificationListResponse.floorKey_)  GearFloorView floor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GearVerificationListResponse() when $default != null:
return $default(_that.items,_that.floor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GearVerificationListResponse.itemsKey_)  List<GearVerificationView>? items, @JsonKey(name: GearVerificationListResponse.floorKey_)  GearFloorView floor)  $default,) {final _that = this;
switch (_that) {
case _GearVerificationListResponse():
return $default(_that.items,_that.floor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GearVerificationListResponse.itemsKey_)  List<GearVerificationView>? items, @JsonKey(name: GearVerificationListResponse.floorKey_)  GearFloorView floor)?  $default,) {final _that = this;
switch (_that) {
case _GearVerificationListResponse() when $default != null:
return $default(_that.items,_that.floor);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GearVerificationListResponse extends GearVerificationListResponse {
  const _GearVerificationListResponse({@JsonKey(name: GearVerificationListResponse.itemsKey_) final  List<GearVerificationView>? items, @JsonKey(name: GearVerificationListResponse.floorKey_) required this.floor}): _items = items,super._();
  factory _GearVerificationListResponse.fromJson(Map<String, dynamic> json) => _$GearVerificationListResponseFromJson(json);

/// items
 final  List<GearVerificationView>? _items;
/// items
@override@JsonKey(name: GearVerificationListResponse.itemsKey_) List<GearVerificationView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// floor
@override@JsonKey(name: GearVerificationListResponse.floorKey_) final  GearFloorView floor;

/// Create a copy of GearVerificationListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GearVerificationListResponseCopyWith<_GearVerificationListResponse> get copyWith => __$GearVerificationListResponseCopyWithImpl<_GearVerificationListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GearVerificationListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GearVerificationListResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.floor, floor) || other.floor == floor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),floor);

@override
String toString() {
  return 'GearVerificationListResponse(items: $items, floor: $floor)';
}


}

/// @nodoc
abstract mixin class _$GearVerificationListResponseCopyWith<$Res> implements $GearVerificationListResponseCopyWith<$Res> {
  factory _$GearVerificationListResponseCopyWith(_GearVerificationListResponse value, $Res Function(_GearVerificationListResponse) _then) = __$GearVerificationListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GearVerificationListResponse.itemsKey_) List<GearVerificationView>? items,@JsonKey(name: GearVerificationListResponse.floorKey_) GearFloorView floor
});


@override $GearFloorViewCopyWith<$Res> get floor;

}
/// @nodoc
class __$GearVerificationListResponseCopyWithImpl<$Res>
    implements _$GearVerificationListResponseCopyWith<$Res> {
  __$GearVerificationListResponseCopyWithImpl(this._self, this._then);

  final _GearVerificationListResponse _self;
  final $Res Function(_GearVerificationListResponse) _then;

/// Create a copy of GearVerificationListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,Object? floor = null,}) {
  return _then(_GearVerificationListResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GearVerificationView>?,floor: null == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as GearFloorView,
  ));
}

/// Create a copy of GearVerificationListResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GearFloorViewCopyWith<$Res> get floor {
  
  return $GearFloorViewCopyWith<$Res>(_self.floor, (value) {
    return _then(_self.copyWith(floor: value));
  });
}
}

// dart format on
