// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationListResponse {

/// items
@JsonKey(name: NotificationListResponse.itemsKey_) List<NotificationView> get items;/// nextCursor
@JsonKey(name: NotificationListResponse.nextCursorKey_) String? get nextCursor;
/// Create a copy of NotificationListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationListResponseCopyWith<NotificationListResponse> get copyWith => _$NotificationListResponseCopyWithImpl<NotificationListResponse>(this as NotificationListResponse, _$identity);

  /// Serializes this NotificationListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationListResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'NotificationListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $NotificationListResponseCopyWith<$Res>  {
  factory $NotificationListResponseCopyWith(NotificationListResponse value, $Res Function(NotificationListResponse) _then) = _$NotificationListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NotificationListResponse.itemsKey_) List<NotificationView> items,@JsonKey(name: NotificationListResponse.nextCursorKey_) String? nextCursor
});




}
/// @nodoc
class _$NotificationListResponseCopyWithImpl<$Res>
    implements $NotificationListResponseCopyWith<$Res> {
  _$NotificationListResponseCopyWithImpl(this._self, this._then);

  final NotificationListResponse _self;
  final $Res Function(NotificationListResponse) _then;

/// Create a copy of NotificationListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationView>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationListResponse].
extension NotificationListResponsePatterns on NotificationListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationListResponse value)  $default,){
final _that = this;
switch (_that) {
case _NotificationListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationListResponse.itemsKey_)  List<NotificationView> items, @JsonKey(name: NotificationListResponse.nextCursorKey_)  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationListResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationListResponse.itemsKey_)  List<NotificationView> items, @JsonKey(name: NotificationListResponse.nextCursorKey_)  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _NotificationListResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NotificationListResponse.itemsKey_)  List<NotificationView> items, @JsonKey(name: NotificationListResponse.nextCursorKey_)  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _NotificationListResponse() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NotificationListResponse extends NotificationListResponse {
  const _NotificationListResponse({@JsonKey(name: NotificationListResponse.itemsKey_) required final  List<NotificationView> items, @JsonKey(name: NotificationListResponse.nextCursorKey_) this.nextCursor}): _items = items,super._();
  factory _NotificationListResponse.fromJson(Map<String, dynamic> json) => _$NotificationListResponseFromJson(json);

/// items
 final  List<NotificationView> _items;
/// items
@override@JsonKey(name: NotificationListResponse.itemsKey_) List<NotificationView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// nextCursor
@override@JsonKey(name: NotificationListResponse.nextCursorKey_) final  String? nextCursor;

/// Create a copy of NotificationListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationListResponseCopyWith<_NotificationListResponse> get copyWith => __$NotificationListResponseCopyWithImpl<_NotificationListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationListResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'NotificationListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$NotificationListResponseCopyWith<$Res> implements $NotificationListResponseCopyWith<$Res> {
  factory _$NotificationListResponseCopyWith(_NotificationListResponse value, $Res Function(_NotificationListResponse) _then) = __$NotificationListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NotificationListResponse.itemsKey_) List<NotificationView> items,@JsonKey(name: NotificationListResponse.nextCursorKey_) String? nextCursor
});




}
/// @nodoc
class __$NotificationListResponseCopyWithImpl<$Res>
    implements _$NotificationListResponseCopyWith<$Res> {
  __$NotificationListResponseCopyWithImpl(this._self, this._then);

  final _NotificationListResponse _self;
  final $Res Function(_NotificationListResponse) _then;

/// Create a copy of NotificationListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_NotificationListResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationView>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
