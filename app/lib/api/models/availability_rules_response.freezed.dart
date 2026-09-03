// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_rules_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityRulesResponse {

/// items
@JsonKey(name: AvailabilityRulesResponse.itemsKey_) List<AvailabilityRuleView>? get items;
/// Create a copy of AvailabilityRulesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityRulesResponseCopyWith<AvailabilityRulesResponse> get copyWith => _$AvailabilityRulesResponseCopyWithImpl<AvailabilityRulesResponse>(this as AvailabilityRulesResponse, _$identity);

  /// Serializes this AvailabilityRulesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityRulesResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'AvailabilityRulesResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $AvailabilityRulesResponseCopyWith<$Res>  {
  factory $AvailabilityRulesResponseCopyWith(AvailabilityRulesResponse value, $Res Function(AvailabilityRulesResponse) _then) = _$AvailabilityRulesResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityRulesResponse.itemsKey_) List<AvailabilityRuleView>? items
});




}
/// @nodoc
class _$AvailabilityRulesResponseCopyWithImpl<$Res>
    implements $AvailabilityRulesResponseCopyWith<$Res> {
  _$AvailabilityRulesResponseCopyWithImpl(this._self, this._then);

  final AvailabilityRulesResponse _self;
  final $Res Function(AvailabilityRulesResponse) _then;

/// Create a copy of AvailabilityRulesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityRulesResponse].
extension AvailabilityRulesResponsePatterns on AvailabilityRulesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityRulesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityRulesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityRulesResponse value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRulesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityRulesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRulesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRulesResponse.itemsKey_)  List<AvailabilityRuleView>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityRulesResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRulesResponse.itemsKey_)  List<AvailabilityRuleView>? items)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRulesResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityRulesResponse.itemsKey_)  List<AvailabilityRuleView>? items)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRulesResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityRulesResponse extends AvailabilityRulesResponse {
  const _AvailabilityRulesResponse({@JsonKey(name: AvailabilityRulesResponse.itemsKey_) final  List<AvailabilityRuleView>? items}): _items = items,super._();
  factory _AvailabilityRulesResponse.fromJson(Map<String, dynamic> json) => _$AvailabilityRulesResponseFromJson(json);

/// items
 final  List<AvailabilityRuleView>? _items;
/// items
@override@JsonKey(name: AvailabilityRulesResponse.itemsKey_) List<AvailabilityRuleView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of AvailabilityRulesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityRulesResponseCopyWith<_AvailabilityRulesResponse> get copyWith => __$AvailabilityRulesResponseCopyWithImpl<_AvailabilityRulesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityRulesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityRulesResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'AvailabilityRulesResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityRulesResponseCopyWith<$Res> implements $AvailabilityRulesResponseCopyWith<$Res> {
  factory _$AvailabilityRulesResponseCopyWith(_AvailabilityRulesResponse value, $Res Function(_AvailabilityRulesResponse) _then) = __$AvailabilityRulesResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityRulesResponse.itemsKey_) List<AvailabilityRuleView>? items
});




}
/// @nodoc
class __$AvailabilityRulesResponseCopyWithImpl<$Res>
    implements _$AvailabilityRulesResponseCopyWith<$Res> {
  __$AvailabilityRulesResponseCopyWithImpl(this._self, this._then);

  final _AvailabilityRulesResponse _self;
  final $Res Function(_AvailabilityRulesResponse) _then;

/// Create a copy of AvailabilityRulesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_AvailabilityRulesResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleView>?,
  ));
}


}

// dart format on
