// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingListResponse {

/// items
@JsonKey(name: ClientBookingListResponse.itemsKey_) List<ClientBookingListItem>? get items;/// nextCursor
@JsonKey(name: ClientBookingListResponse.nextCursorKey_) String? get nextCursor;
/// Create a copy of ClientBookingListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingListResponseCopyWith<ClientBookingListResponse> get copyWith => _$ClientBookingListResponseCopyWithImpl<ClientBookingListResponse>(this as ClientBookingListResponse, _$identity);

  /// Serializes this ClientBookingListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingListResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'ClientBookingListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $ClientBookingListResponseCopyWith<$Res>  {
  factory $ClientBookingListResponseCopyWith(ClientBookingListResponse value, $Res Function(ClientBookingListResponse) _then) = _$ClientBookingListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingListResponse.itemsKey_) List<ClientBookingListItem>? items,@JsonKey(name: ClientBookingListResponse.nextCursorKey_) String? nextCursor
});




}
/// @nodoc
class _$ClientBookingListResponseCopyWithImpl<$Res>
    implements $ClientBookingListResponseCopyWith<$Res> {
  _$ClientBookingListResponseCopyWithImpl(this._self, this._then);

  final ClientBookingListResponse _self;
  final $Res Function(ClientBookingListResponse) _then;

/// Create a copy of ClientBookingListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ClientBookingListItem>?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientBookingListResponse].
extension ClientBookingListResponsePatterns on ClientBookingListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingListResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingListResponse.itemsKey_)  List<ClientBookingListItem>? items, @JsonKey(name: ClientBookingListResponse.nextCursorKey_)  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingListResponse() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingListResponse.itemsKey_)  List<ClientBookingListItem>? items, @JsonKey(name: ClientBookingListResponse.nextCursorKey_)  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingListResponse():
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingListResponse.itemsKey_)  List<ClientBookingListItem>? items, @JsonKey(name: ClientBookingListResponse.nextCursorKey_)  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingListResponse() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingListResponse extends ClientBookingListResponse {
  const _ClientBookingListResponse({@JsonKey(name: ClientBookingListResponse.itemsKey_) final  List<ClientBookingListItem>? items, @JsonKey(name: ClientBookingListResponse.nextCursorKey_) this.nextCursor}): _items = items,super._();
  factory _ClientBookingListResponse.fromJson(Map<String, dynamic> json) => _$ClientBookingListResponseFromJson(json);

/// items
 final  List<ClientBookingListItem>? _items;
/// items
@override@JsonKey(name: ClientBookingListResponse.itemsKey_) List<ClientBookingListItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// nextCursor
@override@JsonKey(name: ClientBookingListResponse.nextCursorKey_) final  String? nextCursor;

/// Create a copy of ClientBookingListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingListResponseCopyWith<_ClientBookingListResponse> get copyWith => __$ClientBookingListResponseCopyWithImpl<_ClientBookingListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingListResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'ClientBookingListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingListResponseCopyWith<$Res> implements $ClientBookingListResponseCopyWith<$Res> {
  factory _$ClientBookingListResponseCopyWith(_ClientBookingListResponse value, $Res Function(_ClientBookingListResponse) _then) = __$ClientBookingListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingListResponse.itemsKey_) List<ClientBookingListItem>? items,@JsonKey(name: ClientBookingListResponse.nextCursorKey_) String? nextCursor
});




}
/// @nodoc
class __$ClientBookingListResponseCopyWithImpl<$Res>
    implements _$ClientBookingListResponseCopyWith<$Res> {
  __$ClientBookingListResponseCopyWithImpl(this._self, this._then);

  final _ClientBookingListResponse _self;
  final $Res Function(_ClientBookingListResponse) _then;

/// Create a copy of ClientBookingListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,Object? nextCursor = freezed,}) {
  return _then(_ClientBookingListResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ClientBookingListItem>?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
