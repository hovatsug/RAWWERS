// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_ledger_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EarningsLedgerResponse {

/// items
@JsonKey(name: EarningsLedgerResponse.itemsKey_) List<EarningsLedgerItemView>? get items;
/// Create a copy of EarningsLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsLedgerResponseCopyWith<EarningsLedgerResponse> get copyWith => _$EarningsLedgerResponseCopyWithImpl<EarningsLedgerResponse>(this as EarningsLedgerResponse, _$identity);

  /// Serializes this EarningsLedgerResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsLedgerResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'EarningsLedgerResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $EarningsLedgerResponseCopyWith<$Res>  {
  factory $EarningsLedgerResponseCopyWith(EarningsLedgerResponse value, $Res Function(EarningsLedgerResponse) _then) = _$EarningsLedgerResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: EarningsLedgerResponse.itemsKey_) List<EarningsLedgerItemView>? items
});




}
/// @nodoc
class _$EarningsLedgerResponseCopyWithImpl<$Res>
    implements $EarningsLedgerResponseCopyWith<$Res> {
  _$EarningsLedgerResponseCopyWithImpl(this._self, this._then);

  final EarningsLedgerResponse _self;
  final $Res Function(EarningsLedgerResponse) _then;

/// Create a copy of EarningsLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<EarningsLedgerItemView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsLedgerResponse].
extension EarningsLedgerResponsePatterns on EarningsLedgerResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsLedgerResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsLedgerResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsLedgerResponse value)  $default,){
final _that = this;
switch (_that) {
case _EarningsLedgerResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsLedgerResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsLedgerResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsLedgerResponse.itemsKey_)  List<EarningsLedgerItemView>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsLedgerResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsLedgerResponse.itemsKey_)  List<EarningsLedgerItemView>? items)  $default,) {final _that = this;
switch (_that) {
case _EarningsLedgerResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: EarningsLedgerResponse.itemsKey_)  List<EarningsLedgerItemView>? items)?  $default,) {final _that = this;
switch (_that) {
case _EarningsLedgerResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _EarningsLedgerResponse extends EarningsLedgerResponse {
  const _EarningsLedgerResponse({@JsonKey(name: EarningsLedgerResponse.itemsKey_) final  List<EarningsLedgerItemView>? items}): _items = items,super._();
  factory _EarningsLedgerResponse.fromJson(Map<String, dynamic> json) => _$EarningsLedgerResponseFromJson(json);

/// items
 final  List<EarningsLedgerItemView>? _items;
/// items
@override@JsonKey(name: EarningsLedgerResponse.itemsKey_) List<EarningsLedgerItemView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of EarningsLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsLedgerResponseCopyWith<_EarningsLedgerResponse> get copyWith => __$EarningsLedgerResponseCopyWithImpl<_EarningsLedgerResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsLedgerResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsLedgerResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'EarningsLedgerResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$EarningsLedgerResponseCopyWith<$Res> implements $EarningsLedgerResponseCopyWith<$Res> {
  factory _$EarningsLedgerResponseCopyWith(_EarningsLedgerResponse value, $Res Function(_EarningsLedgerResponse) _then) = __$EarningsLedgerResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: EarningsLedgerResponse.itemsKey_) List<EarningsLedgerItemView>? items
});




}
/// @nodoc
class __$EarningsLedgerResponseCopyWithImpl<$Res>
    implements _$EarningsLedgerResponseCopyWith<$Res> {
  __$EarningsLedgerResponseCopyWithImpl(this._self, this._then);

  final _EarningsLedgerResponse _self;
  final $Res Function(_EarningsLedgerResponse) _then;

/// Create a copy of EarningsLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_EarningsLedgerResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<EarningsLedgerItemView>?,
  ));
}


}

// dart format on
