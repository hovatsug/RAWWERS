// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_time_windows_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingTimeWindowsResponse {

/// bookingRequestId
@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_) String get bookingRequestId;/// id
@JsonKey(name: BookingTimeWindowsResponse.idKey_) String get id;/// clientTimezone
@JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_) String get clientTimezone;/// windows
@JsonKey(name: BookingTimeWindowsResponse.windowsKey_) List<TimeWindowItem>? get windows;
/// Create a copy of BookingTimeWindowsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingTimeWindowsResponseCopyWith<BookingTimeWindowsResponse> get copyWith => _$BookingTimeWindowsResponseCopyWithImpl<BookingTimeWindowsResponse>(this as BookingTimeWindowsResponse, _$identity);

  /// Serializes this BookingTimeWindowsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingTimeWindowsResponse&&(identical(other.bookingRequestId, bookingRequestId) || other.bookingRequestId == bookingRequestId)&&(identical(other.id, id) || other.id == id)&&(identical(other.clientTimezone, clientTimezone) || other.clientTimezone == clientTimezone)&&const DeepCollectionEquality().equals(other.windows, windows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequestId,id,clientTimezone,const DeepCollectionEquality().hash(windows));

@override
String toString() {
  return 'BookingTimeWindowsResponse(bookingRequestId: $bookingRequestId, id: $id, clientTimezone: $clientTimezone, windows: $windows)';
}


}

/// @nodoc
abstract mixin class $BookingTimeWindowsResponseCopyWith<$Res>  {
  factory $BookingTimeWindowsResponseCopyWith(BookingTimeWindowsResponse value, $Res Function(BookingTimeWindowsResponse) _then) = _$BookingTimeWindowsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_) String bookingRequestId,@JsonKey(name: BookingTimeWindowsResponse.idKey_) String id,@JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_) String clientTimezone,@JsonKey(name: BookingTimeWindowsResponse.windowsKey_) List<TimeWindowItem>? windows
});




}
/// @nodoc
class _$BookingTimeWindowsResponseCopyWithImpl<$Res>
    implements $BookingTimeWindowsResponseCopyWith<$Res> {
  _$BookingTimeWindowsResponseCopyWithImpl(this._self, this._then);

  final BookingTimeWindowsResponse _self;
  final $Res Function(BookingTimeWindowsResponse) _then;

/// Create a copy of BookingTimeWindowsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingRequestId = null,Object? id = null,Object? clientTimezone = null,Object? windows = freezed,}) {
  return _then(_self.copyWith(
bookingRequestId: null == bookingRequestId ? _self.bookingRequestId : bookingRequestId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientTimezone: null == clientTimezone ? _self.clientTimezone : clientTimezone // ignore: cast_nullable_to_non_nullable
as String,windows: freezed == windows ? _self.windows : windows // ignore: cast_nullable_to_non_nullable
as List<TimeWindowItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingTimeWindowsResponse].
extension BookingTimeWindowsResponsePatterns on BookingTimeWindowsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingTimeWindowsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingTimeWindowsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingTimeWindowsResponse value)  $default,){
final _that = this;
switch (_that) {
case _BookingTimeWindowsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingTimeWindowsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BookingTimeWindowsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_)  String bookingRequestId, @JsonKey(name: BookingTimeWindowsResponse.idKey_)  String id, @JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: BookingTimeWindowsResponse.windowsKey_)  List<TimeWindowItem>? windows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingTimeWindowsResponse() when $default != null:
return $default(_that.bookingRequestId,_that.id,_that.clientTimezone,_that.windows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_)  String bookingRequestId, @JsonKey(name: BookingTimeWindowsResponse.idKey_)  String id, @JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: BookingTimeWindowsResponse.windowsKey_)  List<TimeWindowItem>? windows)  $default,) {final _that = this;
switch (_that) {
case _BookingTimeWindowsResponse():
return $default(_that.bookingRequestId,_that.id,_that.clientTimezone,_that.windows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_)  String bookingRequestId, @JsonKey(name: BookingTimeWindowsResponse.idKey_)  String id, @JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: BookingTimeWindowsResponse.windowsKey_)  List<TimeWindowItem>? windows)?  $default,) {final _that = this;
switch (_that) {
case _BookingTimeWindowsResponse() when $default != null:
return $default(_that.bookingRequestId,_that.id,_that.clientTimezone,_that.windows);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingTimeWindowsResponse extends BookingTimeWindowsResponse {
  const _BookingTimeWindowsResponse({@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_) required this.bookingRequestId, @JsonKey(name: BookingTimeWindowsResponse.idKey_) required this.id, @JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_) required this.clientTimezone, @JsonKey(name: BookingTimeWindowsResponse.windowsKey_) final  List<TimeWindowItem>? windows}): _windows = windows,super._();
  factory _BookingTimeWindowsResponse.fromJson(Map<String, dynamic> json) => _$BookingTimeWindowsResponseFromJson(json);

/// bookingRequestId
@override@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_) final  String bookingRequestId;
/// id
@override@JsonKey(name: BookingTimeWindowsResponse.idKey_) final  String id;
/// clientTimezone
@override@JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_) final  String clientTimezone;
/// windows
 final  List<TimeWindowItem>? _windows;
/// windows
@override@JsonKey(name: BookingTimeWindowsResponse.windowsKey_) List<TimeWindowItem>? get windows {
  final value = _windows;
  if (value == null) return null;
  if (_windows is EqualUnmodifiableListView) return _windows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of BookingTimeWindowsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingTimeWindowsResponseCopyWith<_BookingTimeWindowsResponse> get copyWith => __$BookingTimeWindowsResponseCopyWithImpl<_BookingTimeWindowsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingTimeWindowsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingTimeWindowsResponse&&(identical(other.bookingRequestId, bookingRequestId) || other.bookingRequestId == bookingRequestId)&&(identical(other.id, id) || other.id == id)&&(identical(other.clientTimezone, clientTimezone) || other.clientTimezone == clientTimezone)&&const DeepCollectionEquality().equals(other._windows, _windows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingRequestId,id,clientTimezone,const DeepCollectionEquality().hash(_windows));

@override
String toString() {
  return 'BookingTimeWindowsResponse(bookingRequestId: $bookingRequestId, id: $id, clientTimezone: $clientTimezone, windows: $windows)';
}


}

/// @nodoc
abstract mixin class _$BookingTimeWindowsResponseCopyWith<$Res> implements $BookingTimeWindowsResponseCopyWith<$Res> {
  factory _$BookingTimeWindowsResponseCopyWith(_BookingTimeWindowsResponse value, $Res Function(_BookingTimeWindowsResponse) _then) = __$BookingTimeWindowsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_) String bookingRequestId,@JsonKey(name: BookingTimeWindowsResponse.idKey_) String id,@JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_) String clientTimezone,@JsonKey(name: BookingTimeWindowsResponse.windowsKey_) List<TimeWindowItem>? windows
});




}
/// @nodoc
class __$BookingTimeWindowsResponseCopyWithImpl<$Res>
    implements _$BookingTimeWindowsResponseCopyWith<$Res> {
  __$BookingTimeWindowsResponseCopyWithImpl(this._self, this._then);

  final _BookingTimeWindowsResponse _self;
  final $Res Function(_BookingTimeWindowsResponse) _then;

/// Create a copy of BookingTimeWindowsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingRequestId = null,Object? id = null,Object? clientTimezone = null,Object? windows = freezed,}) {
  return _then(_BookingTimeWindowsResponse(
bookingRequestId: null == bookingRequestId ? _self.bookingRequestId : bookingRequestId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientTimezone: null == clientTimezone ? _self.clientTimezone : clientTimezone // ignore: cast_nullable_to_non_nullable
as String,windows: freezed == windows ? _self._windows : windows // ignore: cast_nullable_to_non_nullable
as List<TimeWindowItem>?,
  ));
}


}

// dart format on
