// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_request_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingRequestListResponse {

/// items
@JsonKey(name: BookingRequestListResponse.itemsKey_) List<BookingRequestListItem>? get items;/// nextCursor
@JsonKey(name: BookingRequestListResponse.nextCursorKey_) String? get nextCursor;
/// Create a copy of BookingRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingRequestListResponseCopyWith<BookingRequestListResponse> get copyWith => _$BookingRequestListResponseCopyWithImpl<BookingRequestListResponse>(this as BookingRequestListResponse, _$identity);

  /// Serializes this BookingRequestListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingRequestListResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'BookingRequestListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $BookingRequestListResponseCopyWith<$Res>  {
  factory $BookingRequestListResponseCopyWith(BookingRequestListResponse value, $Res Function(BookingRequestListResponse) _then) = _$BookingRequestListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingRequestListResponse.itemsKey_) List<BookingRequestListItem>? items,@JsonKey(name: BookingRequestListResponse.nextCursorKey_) String? nextCursor
});




}
/// @nodoc
class _$BookingRequestListResponseCopyWithImpl<$Res>
    implements $BookingRequestListResponseCopyWith<$Res> {
  _$BookingRequestListResponseCopyWithImpl(this._self, this._then);

  final BookingRequestListResponse _self;
  final $Res Function(BookingRequestListResponse) _then;

/// Create a copy of BookingRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BookingRequestListItem>?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingRequestListResponse].
extension BookingRequestListResponsePatterns on BookingRequestListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingRequestListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingRequestListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingRequestListResponse value)  $default,){
final _that = this;
switch (_that) {
case _BookingRequestListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingRequestListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BookingRequestListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestListResponse.itemsKey_)  List<BookingRequestListItem>? items, @JsonKey(name: BookingRequestListResponse.nextCursorKey_)  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingRequestListResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestListResponse.itemsKey_)  List<BookingRequestListItem>? items, @JsonKey(name: BookingRequestListResponse.nextCursorKey_)  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _BookingRequestListResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingRequestListResponse.itemsKey_)  List<BookingRequestListItem>? items, @JsonKey(name: BookingRequestListResponse.nextCursorKey_)  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _BookingRequestListResponse() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingRequestListResponse extends BookingRequestListResponse {
  const _BookingRequestListResponse({@JsonKey(name: BookingRequestListResponse.itemsKey_) final  List<BookingRequestListItem>? items, @JsonKey(name: BookingRequestListResponse.nextCursorKey_) this.nextCursor}): _items = items,super._();
  factory _BookingRequestListResponse.fromJson(Map<String, dynamic> json) => _$BookingRequestListResponseFromJson(json);

/// items
 final  List<BookingRequestListItem>? _items;
/// items
@override@JsonKey(name: BookingRequestListResponse.itemsKey_) List<BookingRequestListItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// nextCursor
@override@JsonKey(name: BookingRequestListResponse.nextCursorKey_) final  String? nextCursor;

/// Create a copy of BookingRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingRequestListResponseCopyWith<_BookingRequestListResponse> get copyWith => __$BookingRequestListResponseCopyWithImpl<_BookingRequestListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingRequestListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingRequestListResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'BookingRequestListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$BookingRequestListResponseCopyWith<$Res> implements $BookingRequestListResponseCopyWith<$Res> {
  factory _$BookingRequestListResponseCopyWith(_BookingRequestListResponse value, $Res Function(_BookingRequestListResponse) _then) = __$BookingRequestListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingRequestListResponse.itemsKey_) List<BookingRequestListItem>? items,@JsonKey(name: BookingRequestListResponse.nextCursorKey_) String? nextCursor
});




}
/// @nodoc
class __$BookingRequestListResponseCopyWithImpl<$Res>
    implements _$BookingRequestListResponseCopyWith<$Res> {
  __$BookingRequestListResponseCopyWithImpl(this._self, this._then);

  final _BookingRequestListResponse _self;
  final $Res Function(_BookingRequestListResponse) _then;

/// Create a copy of BookingRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,Object? nextCursor = freezed,}) {
  return _then(_BookingRequestListResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BookingRequestListItem>?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
