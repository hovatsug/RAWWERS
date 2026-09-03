// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_exceptions_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityExceptionsResponse {

/// items
@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_) List<AvailabilityExceptionView>? get items;
/// Create a copy of AvailabilityExceptionsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityExceptionsResponseCopyWith<AvailabilityExceptionsResponse> get copyWith => _$AvailabilityExceptionsResponseCopyWithImpl<AvailabilityExceptionsResponse>(this as AvailabilityExceptionsResponse, _$identity);

  /// Serializes this AvailabilityExceptionsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityExceptionsResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'AvailabilityExceptionsResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $AvailabilityExceptionsResponseCopyWith<$Res>  {
  factory $AvailabilityExceptionsResponseCopyWith(AvailabilityExceptionsResponse value, $Res Function(AvailabilityExceptionsResponse) _then) = _$AvailabilityExceptionsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_) List<AvailabilityExceptionView>? items
});




}
/// @nodoc
class _$AvailabilityExceptionsResponseCopyWithImpl<$Res>
    implements $AvailabilityExceptionsResponseCopyWith<$Res> {
  _$AvailabilityExceptionsResponseCopyWithImpl(this._self, this._then);

  final AvailabilityExceptionsResponse _self;
  final $Res Function(AvailabilityExceptionsResponse) _then;

/// Create a copy of AvailabilityExceptionsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AvailabilityExceptionView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityExceptionsResponse].
extension AvailabilityExceptionsResponsePatterns on AvailabilityExceptionsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityExceptionsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityExceptionsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityExceptionsResponse value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityExceptionsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_)  List<AvailabilityExceptionView>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityExceptionsResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_)  List<AvailabilityExceptionView>? items)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionsResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_)  List<AvailabilityExceptionView>? items)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionsResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityExceptionsResponse extends AvailabilityExceptionsResponse {
  const _AvailabilityExceptionsResponse({@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_) final  List<AvailabilityExceptionView>? items}): _items = items,super._();
  factory _AvailabilityExceptionsResponse.fromJson(Map<String, dynamic> json) => _$AvailabilityExceptionsResponseFromJson(json);

/// items
 final  List<AvailabilityExceptionView>? _items;
/// items
@override@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_) List<AvailabilityExceptionView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of AvailabilityExceptionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityExceptionsResponseCopyWith<_AvailabilityExceptionsResponse> get copyWith => __$AvailabilityExceptionsResponseCopyWithImpl<_AvailabilityExceptionsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityExceptionsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityExceptionsResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'AvailabilityExceptionsResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityExceptionsResponseCopyWith<$Res> implements $AvailabilityExceptionsResponseCopyWith<$Res> {
  factory _$AvailabilityExceptionsResponseCopyWith(_AvailabilityExceptionsResponse value, $Res Function(_AvailabilityExceptionsResponse) _then) = __$AvailabilityExceptionsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityExceptionsResponse.itemsKey_) List<AvailabilityExceptionView>? items
});




}
/// @nodoc
class __$AvailabilityExceptionsResponseCopyWithImpl<$Res>
    implements _$AvailabilityExceptionsResponseCopyWith<$Res> {
  __$AvailabilityExceptionsResponseCopyWithImpl(this._self, this._then);

  final _AvailabilityExceptionsResponse _self;
  final $Res Function(_AvailabilityExceptionsResponse) _then;

/// Create a copy of AvailabilityExceptionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_AvailabilityExceptionsResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AvailabilityExceptionView>?,
  ));
}


}

// dart format on
