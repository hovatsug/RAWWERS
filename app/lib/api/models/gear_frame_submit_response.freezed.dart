// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gear_frame_submit_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GearFrameSubmitResponse {

/// items
@JsonKey(name: GearFrameSubmitResponse.itemsKey_) List<GearVerificationView>? get items;/// notes
@JsonKey(name: GearFrameSubmitResponse.notesKey_) List<String>? get notes;/// floor
@JsonKey(name: GearFrameSubmitResponse.floorKey_) GearFloorView get floor;
/// Create a copy of GearFrameSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GearFrameSubmitResponseCopyWith<GearFrameSubmitResponse> get copyWith => _$GearFrameSubmitResponseCopyWithImpl<GearFrameSubmitResponse>(this as GearFrameSubmitResponse, _$identity);

  /// Serializes this GearFrameSubmitResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GearFrameSubmitResponse&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.notes, notes)&&(identical(other.floor, floor) || other.floor == floor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(notes),floor);

@override
String toString() {
  return 'GearFrameSubmitResponse(items: $items, notes: $notes, floor: $floor)';
}


}

/// @nodoc
abstract mixin class $GearFrameSubmitResponseCopyWith<$Res>  {
  factory $GearFrameSubmitResponseCopyWith(GearFrameSubmitResponse value, $Res Function(GearFrameSubmitResponse) _then) = _$GearFrameSubmitResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GearFrameSubmitResponse.itemsKey_) List<GearVerificationView>? items,@JsonKey(name: GearFrameSubmitResponse.notesKey_) List<String>? notes,@JsonKey(name: GearFrameSubmitResponse.floorKey_) GearFloorView floor
});


$GearFloorViewCopyWith<$Res> get floor;

}
/// @nodoc
class _$GearFrameSubmitResponseCopyWithImpl<$Res>
    implements $GearFrameSubmitResponseCopyWith<$Res> {
  _$GearFrameSubmitResponseCopyWithImpl(this._self, this._then);

  final GearFrameSubmitResponse _self;
  final $Res Function(GearFrameSubmitResponse) _then;

/// Create a copy of GearFrameSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,Object? notes = freezed,Object? floor = null,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GearVerificationView>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>?,floor: null == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as GearFloorView,
  ));
}
/// Create a copy of GearFrameSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GearFloorViewCopyWith<$Res> get floor {
  
  return $GearFloorViewCopyWith<$Res>(_self.floor, (value) {
    return _then(_self.copyWith(floor: value));
  });
}
}


/// Adds pattern-matching-related methods to [GearFrameSubmitResponse].
extension GearFrameSubmitResponsePatterns on GearFrameSubmitResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GearFrameSubmitResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GearFrameSubmitResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GearFrameSubmitResponse value)  $default,){
final _that = this;
switch (_that) {
case _GearFrameSubmitResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GearFrameSubmitResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GearFrameSubmitResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GearFrameSubmitResponse.itemsKey_)  List<GearVerificationView>? items, @JsonKey(name: GearFrameSubmitResponse.notesKey_)  List<String>? notes, @JsonKey(name: GearFrameSubmitResponse.floorKey_)  GearFloorView floor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GearFrameSubmitResponse() when $default != null:
return $default(_that.items,_that.notes,_that.floor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GearFrameSubmitResponse.itemsKey_)  List<GearVerificationView>? items, @JsonKey(name: GearFrameSubmitResponse.notesKey_)  List<String>? notes, @JsonKey(name: GearFrameSubmitResponse.floorKey_)  GearFloorView floor)  $default,) {final _that = this;
switch (_that) {
case _GearFrameSubmitResponse():
return $default(_that.items,_that.notes,_that.floor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GearFrameSubmitResponse.itemsKey_)  List<GearVerificationView>? items, @JsonKey(name: GearFrameSubmitResponse.notesKey_)  List<String>? notes, @JsonKey(name: GearFrameSubmitResponse.floorKey_)  GearFloorView floor)?  $default,) {final _that = this;
switch (_that) {
case _GearFrameSubmitResponse() when $default != null:
return $default(_that.items,_that.notes,_that.floor);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GearFrameSubmitResponse extends GearFrameSubmitResponse {
  const _GearFrameSubmitResponse({@JsonKey(name: GearFrameSubmitResponse.itemsKey_) final  List<GearVerificationView>? items, @JsonKey(name: GearFrameSubmitResponse.notesKey_) final  List<String>? notes, @JsonKey(name: GearFrameSubmitResponse.floorKey_) required this.floor}): _items = items,_notes = notes,super._();
  factory _GearFrameSubmitResponse.fromJson(Map<String, dynamic> json) => _$GearFrameSubmitResponseFromJson(json);

/// items
 final  List<GearVerificationView>? _items;
/// items
@override@JsonKey(name: GearFrameSubmitResponse.itemsKey_) List<GearVerificationView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// notes
 final  List<String>? _notes;
/// notes
@override@JsonKey(name: GearFrameSubmitResponse.notesKey_) List<String>? get notes {
  final value = _notes;
  if (value == null) return null;
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// floor
@override@JsonKey(name: GearFrameSubmitResponse.floorKey_) final  GearFloorView floor;

/// Create a copy of GearFrameSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GearFrameSubmitResponseCopyWith<_GearFrameSubmitResponse> get copyWith => __$GearFrameSubmitResponseCopyWithImpl<_GearFrameSubmitResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GearFrameSubmitResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GearFrameSubmitResponse&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.floor, floor) || other.floor == floor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_notes),floor);

@override
String toString() {
  return 'GearFrameSubmitResponse(items: $items, notes: $notes, floor: $floor)';
}


}

/// @nodoc
abstract mixin class _$GearFrameSubmitResponseCopyWith<$Res> implements $GearFrameSubmitResponseCopyWith<$Res> {
  factory _$GearFrameSubmitResponseCopyWith(_GearFrameSubmitResponse value, $Res Function(_GearFrameSubmitResponse) _then) = __$GearFrameSubmitResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GearFrameSubmitResponse.itemsKey_) List<GearVerificationView>? items,@JsonKey(name: GearFrameSubmitResponse.notesKey_) List<String>? notes,@JsonKey(name: GearFrameSubmitResponse.floorKey_) GearFloorView floor
});


@override $GearFloorViewCopyWith<$Res> get floor;

}
/// @nodoc
class __$GearFrameSubmitResponseCopyWithImpl<$Res>
    implements _$GearFrameSubmitResponseCopyWith<$Res> {
  __$GearFrameSubmitResponseCopyWithImpl(this._self, this._then);

  final _GearFrameSubmitResponse _self;
  final $Res Function(_GearFrameSubmitResponse) _then;

/// Create a copy of GearFrameSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,Object? notes = freezed,Object? floor = null,}) {
  return _then(_GearFrameSubmitResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GearVerificationView>?,notes: freezed == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>?,floor: null == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as GearFloorView,
  ));
}

/// Create a copy of GearFrameSubmitResponse
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
