// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_exceptions_replace_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityExceptionsReplaceRequest {

/// items
@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_) List<AvailabilityExceptionItem>? get items;
/// Create a copy of AvailabilityExceptionsReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityExceptionsReplaceRequestCopyWith<AvailabilityExceptionsReplaceRequest> get copyWith => _$AvailabilityExceptionsReplaceRequestCopyWithImpl<AvailabilityExceptionsReplaceRequest>(this as AvailabilityExceptionsReplaceRequest, _$identity);

  /// Serializes this AvailabilityExceptionsReplaceRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityExceptionsReplaceRequest&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'AvailabilityExceptionsReplaceRequest(items: $items)';
}


}

/// @nodoc
abstract mixin class $AvailabilityExceptionsReplaceRequestCopyWith<$Res>  {
  factory $AvailabilityExceptionsReplaceRequestCopyWith(AvailabilityExceptionsReplaceRequest value, $Res Function(AvailabilityExceptionsReplaceRequest) _then) = _$AvailabilityExceptionsReplaceRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_) List<AvailabilityExceptionItem>? items
});




}
/// @nodoc
class _$AvailabilityExceptionsReplaceRequestCopyWithImpl<$Res>
    implements $AvailabilityExceptionsReplaceRequestCopyWith<$Res> {
  _$AvailabilityExceptionsReplaceRequestCopyWithImpl(this._self, this._then);

  final AvailabilityExceptionsReplaceRequest _self;
  final $Res Function(AvailabilityExceptionsReplaceRequest) _then;

/// Create a copy of AvailabilityExceptionsReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AvailabilityExceptionItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityExceptionsReplaceRequest].
extension AvailabilityExceptionsReplaceRequestPatterns on AvailabilityExceptionsReplaceRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityExceptionsReplaceRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityExceptionsReplaceRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityExceptionsReplaceRequest value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionsReplaceRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityExceptionsReplaceRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionsReplaceRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_)  List<AvailabilityExceptionItem>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityExceptionsReplaceRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_)  List<AvailabilityExceptionItem>? items)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionsReplaceRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_)  List<AvailabilityExceptionItem>? items)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionsReplaceRequest() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityExceptionsReplaceRequest extends AvailabilityExceptionsReplaceRequest {
  const _AvailabilityExceptionsReplaceRequest({@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_) final  List<AvailabilityExceptionItem>? items}): _items = items,super._();
  factory _AvailabilityExceptionsReplaceRequest.fromJson(Map<String, dynamic> json) => _$AvailabilityExceptionsReplaceRequestFromJson(json);

/// items
 final  List<AvailabilityExceptionItem>? _items;
/// items
@override@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_) List<AvailabilityExceptionItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of AvailabilityExceptionsReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityExceptionsReplaceRequestCopyWith<_AvailabilityExceptionsReplaceRequest> get copyWith => __$AvailabilityExceptionsReplaceRequestCopyWithImpl<_AvailabilityExceptionsReplaceRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityExceptionsReplaceRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityExceptionsReplaceRequest&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'AvailabilityExceptionsReplaceRequest(items: $items)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityExceptionsReplaceRequestCopyWith<$Res> implements $AvailabilityExceptionsReplaceRequestCopyWith<$Res> {
  factory _$AvailabilityExceptionsReplaceRequestCopyWith(_AvailabilityExceptionsReplaceRequest value, $Res Function(_AvailabilityExceptionsReplaceRequest) _then) = __$AvailabilityExceptionsReplaceRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_) List<AvailabilityExceptionItem>? items
});




}
/// @nodoc
class __$AvailabilityExceptionsReplaceRequestCopyWithImpl<$Res>
    implements _$AvailabilityExceptionsReplaceRequestCopyWith<$Res> {
  __$AvailabilityExceptionsReplaceRequestCopyWithImpl(this._self, this._then);

  final _AvailabilityExceptionsReplaceRequest _self;
  final $Res Function(_AvailabilityExceptionsReplaceRequest) _then;

/// Create a copy of AvailabilityExceptionsReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_AvailabilityExceptionsReplaceRequest(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AvailabilityExceptionItem>?,
  ));
}


}

// dart format on
