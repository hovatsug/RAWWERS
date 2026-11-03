// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_browse_level.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfBrowseLevel {

/// level
@JsonKey(name: ShelfBrowseLevel.levelKey_) int get level;/// bandRaww
@JsonKey(name: ShelfBrowseLevel.bandRawwKey_) int get bandRaww;/// locked
@JsonKey(name: ShelfBrowseLevel.lockedKey_) bool get locked;/// unlocksAtTier
@JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_) String? get unlocksAtTier;/// items
@JsonKey(name: ShelfBrowseLevel.itemsKey_) List<ShelfBrowseItem> get items;
/// Create a copy of ShelfBrowseLevel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfBrowseLevelCopyWith<ShelfBrowseLevel> get copyWith => _$ShelfBrowseLevelCopyWithImpl<ShelfBrowseLevel>(this as ShelfBrowseLevel, _$identity);

  /// Serializes this ShelfBrowseLevel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfBrowseLevel&&(identical(other.level, level) || other.level == level)&&(identical(other.bandRaww, bandRaww) || other.bandRaww == bandRaww)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.unlocksAtTier, unlocksAtTier) || other.unlocksAtTier == unlocksAtTier)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,bandRaww,locked,unlocksAtTier,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ShelfBrowseLevel(level: $level, bandRaww: $bandRaww, locked: $locked, unlocksAtTier: $unlocksAtTier, items: $items)';
}


}

/// @nodoc
abstract mixin class $ShelfBrowseLevelCopyWith<$Res>  {
  factory $ShelfBrowseLevelCopyWith(ShelfBrowseLevel value, $Res Function(ShelfBrowseLevel) _then) = _$ShelfBrowseLevelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfBrowseLevel.levelKey_) int level,@JsonKey(name: ShelfBrowseLevel.bandRawwKey_) int bandRaww,@JsonKey(name: ShelfBrowseLevel.lockedKey_) bool locked,@JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_) String? unlocksAtTier,@JsonKey(name: ShelfBrowseLevel.itemsKey_) List<ShelfBrowseItem> items
});




}
/// @nodoc
class _$ShelfBrowseLevelCopyWithImpl<$Res>
    implements $ShelfBrowseLevelCopyWith<$Res> {
  _$ShelfBrowseLevelCopyWithImpl(this._self, this._then);

  final ShelfBrowseLevel _self;
  final $Res Function(ShelfBrowseLevel) _then;

/// Create a copy of ShelfBrowseLevel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? bandRaww = null,Object? locked = null,Object? unlocksAtTier = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,bandRaww: null == bandRaww ? _self.bandRaww : bandRaww // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,unlocksAtTier: freezed == unlocksAtTier ? _self.unlocksAtTier : unlocksAtTier // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ShelfBrowseItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfBrowseLevel].
extension ShelfBrowseLevelPatterns on ShelfBrowseLevel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfBrowseLevel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfBrowseLevel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfBrowseLevel value)  $default,){
final _that = this;
switch (_that) {
case _ShelfBrowseLevel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfBrowseLevel value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfBrowseLevel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfBrowseLevel.levelKey_)  int level, @JsonKey(name: ShelfBrowseLevel.bandRawwKey_)  int bandRaww, @JsonKey(name: ShelfBrowseLevel.lockedKey_)  bool locked, @JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_)  String? unlocksAtTier, @JsonKey(name: ShelfBrowseLevel.itemsKey_)  List<ShelfBrowseItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfBrowseLevel() when $default != null:
return $default(_that.level,_that.bandRaww,_that.locked,_that.unlocksAtTier,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfBrowseLevel.levelKey_)  int level, @JsonKey(name: ShelfBrowseLevel.bandRawwKey_)  int bandRaww, @JsonKey(name: ShelfBrowseLevel.lockedKey_)  bool locked, @JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_)  String? unlocksAtTier, @JsonKey(name: ShelfBrowseLevel.itemsKey_)  List<ShelfBrowseItem> items)  $default,) {final _that = this;
switch (_that) {
case _ShelfBrowseLevel():
return $default(_that.level,_that.bandRaww,_that.locked,_that.unlocksAtTier,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfBrowseLevel.levelKey_)  int level, @JsonKey(name: ShelfBrowseLevel.bandRawwKey_)  int bandRaww, @JsonKey(name: ShelfBrowseLevel.lockedKey_)  bool locked, @JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_)  String? unlocksAtTier, @JsonKey(name: ShelfBrowseLevel.itemsKey_)  List<ShelfBrowseItem> items)?  $default,) {final _that = this;
switch (_that) {
case _ShelfBrowseLevel() when $default != null:
return $default(_that.level,_that.bandRaww,_that.locked,_that.unlocksAtTier,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfBrowseLevel extends ShelfBrowseLevel {
  const _ShelfBrowseLevel({@JsonKey(name: ShelfBrowseLevel.levelKey_) required this.level, @JsonKey(name: ShelfBrowseLevel.bandRawwKey_) required this.bandRaww, @JsonKey(name: ShelfBrowseLevel.lockedKey_) required this.locked, @JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_) this.unlocksAtTier, @JsonKey(name: ShelfBrowseLevel.itemsKey_) required final  List<ShelfBrowseItem> items}): _items = items,super._();
  factory _ShelfBrowseLevel.fromJson(Map<String, dynamic> json) => _$ShelfBrowseLevelFromJson(json);

/// level
@override@JsonKey(name: ShelfBrowseLevel.levelKey_) final  int level;
/// bandRaww
@override@JsonKey(name: ShelfBrowseLevel.bandRawwKey_) final  int bandRaww;
/// locked
@override@JsonKey(name: ShelfBrowseLevel.lockedKey_) final  bool locked;
/// unlocksAtTier
@override@JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_) final  String? unlocksAtTier;
/// items
 final  List<ShelfBrowseItem> _items;
/// items
@override@JsonKey(name: ShelfBrowseLevel.itemsKey_) List<ShelfBrowseItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ShelfBrowseLevel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfBrowseLevelCopyWith<_ShelfBrowseLevel> get copyWith => __$ShelfBrowseLevelCopyWithImpl<_ShelfBrowseLevel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfBrowseLevelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfBrowseLevel&&(identical(other.level, level) || other.level == level)&&(identical(other.bandRaww, bandRaww) || other.bandRaww == bandRaww)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.unlocksAtTier, unlocksAtTier) || other.unlocksAtTier == unlocksAtTier)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,bandRaww,locked,unlocksAtTier,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ShelfBrowseLevel(level: $level, bandRaww: $bandRaww, locked: $locked, unlocksAtTier: $unlocksAtTier, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ShelfBrowseLevelCopyWith<$Res> implements $ShelfBrowseLevelCopyWith<$Res> {
  factory _$ShelfBrowseLevelCopyWith(_ShelfBrowseLevel value, $Res Function(_ShelfBrowseLevel) _then) = __$ShelfBrowseLevelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfBrowseLevel.levelKey_) int level,@JsonKey(name: ShelfBrowseLevel.bandRawwKey_) int bandRaww,@JsonKey(name: ShelfBrowseLevel.lockedKey_) bool locked,@JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_) String? unlocksAtTier,@JsonKey(name: ShelfBrowseLevel.itemsKey_) List<ShelfBrowseItem> items
});




}
/// @nodoc
class __$ShelfBrowseLevelCopyWithImpl<$Res>
    implements _$ShelfBrowseLevelCopyWith<$Res> {
  __$ShelfBrowseLevelCopyWithImpl(this._self, this._then);

  final _ShelfBrowseLevel _self;
  final $Res Function(_ShelfBrowseLevel) _then;

/// Create a copy of ShelfBrowseLevel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? bandRaww = null,Object? locked = null,Object? unlocksAtTier = freezed,Object? items = null,}) {
  return _then(_ShelfBrowseLevel(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,bandRaww: null == bandRaww ? _self.bandRaww : bandRaww // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,unlocksAtTier: freezed == unlocksAtTier ? _self.unlocksAtTier : unlocksAtTier // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ShelfBrowseItem>,
  ));
}


}

// dart format on
