// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_time_windows_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingTimeWindowsRequest {

/// clientTimezone
@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_) String get clientTimezone;/// windows
@JsonKey(name: BookingTimeWindowsRequest.windowsKey_) List<TimeWindowItem>? get windows;
/// Create a copy of BookingTimeWindowsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingTimeWindowsRequestCopyWith<BookingTimeWindowsRequest> get copyWith => _$BookingTimeWindowsRequestCopyWithImpl<BookingTimeWindowsRequest>(this as BookingTimeWindowsRequest, _$identity);

  /// Serializes this BookingTimeWindowsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingTimeWindowsRequest&&(identical(other.clientTimezone, clientTimezone) || other.clientTimezone == clientTimezone)&&const DeepCollectionEquality().equals(other.windows, windows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientTimezone,const DeepCollectionEquality().hash(windows));

@override
String toString() {
  return 'BookingTimeWindowsRequest(clientTimezone: $clientTimezone, windows: $windows)';
}


}

/// @nodoc
abstract mixin class $BookingTimeWindowsRequestCopyWith<$Res>  {
  factory $BookingTimeWindowsRequestCopyWith(BookingTimeWindowsRequest value, $Res Function(BookingTimeWindowsRequest) _then) = _$BookingTimeWindowsRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_) String clientTimezone,@JsonKey(name: BookingTimeWindowsRequest.windowsKey_) List<TimeWindowItem>? windows
});




}
/// @nodoc
class _$BookingTimeWindowsRequestCopyWithImpl<$Res>
    implements $BookingTimeWindowsRequestCopyWith<$Res> {
  _$BookingTimeWindowsRequestCopyWithImpl(this._self, this._then);

  final BookingTimeWindowsRequest _self;
  final $Res Function(BookingTimeWindowsRequest) _then;

/// Create a copy of BookingTimeWindowsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientTimezone = null,Object? windows = freezed,}) {
  return _then(_self.copyWith(
clientTimezone: null == clientTimezone ? _self.clientTimezone : clientTimezone // ignore: cast_nullable_to_non_nullable
as String,windows: freezed == windows ? _self.windows : windows // ignore: cast_nullable_to_non_nullable
as List<TimeWindowItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingTimeWindowsRequest].
extension BookingTimeWindowsRequestPatterns on BookingTimeWindowsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingTimeWindowsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingTimeWindowsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingTimeWindowsRequest value)  $default,){
final _that = this;
switch (_that) {
case _BookingTimeWindowsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingTimeWindowsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BookingTimeWindowsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: BookingTimeWindowsRequest.windowsKey_)  List<TimeWindowItem>? windows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingTimeWindowsRequest() when $default != null:
return $default(_that.clientTimezone,_that.windows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: BookingTimeWindowsRequest.windowsKey_)  List<TimeWindowItem>? windows)  $default,) {final _that = this;
switch (_that) {
case _BookingTimeWindowsRequest():
return $default(_that.clientTimezone,_that.windows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_)  String clientTimezone, @JsonKey(name: BookingTimeWindowsRequest.windowsKey_)  List<TimeWindowItem>? windows)?  $default,) {final _that = this;
switch (_that) {
case _BookingTimeWindowsRequest() when $default != null:
return $default(_that.clientTimezone,_that.windows);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingTimeWindowsRequest extends BookingTimeWindowsRequest {
  const _BookingTimeWindowsRequest({@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_) required this.clientTimezone, @JsonKey(name: BookingTimeWindowsRequest.windowsKey_) final  List<TimeWindowItem>? windows}): _windows = windows,super._();
  factory _BookingTimeWindowsRequest.fromJson(Map<String, dynamic> json) => _$BookingTimeWindowsRequestFromJson(json);

/// clientTimezone
@override@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_) final  String clientTimezone;
/// windows
 final  List<TimeWindowItem>? _windows;
/// windows
@override@JsonKey(name: BookingTimeWindowsRequest.windowsKey_) List<TimeWindowItem>? get windows {
  final value = _windows;
  if (value == null) return null;
  if (_windows is EqualUnmodifiableListView) return _windows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of BookingTimeWindowsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingTimeWindowsRequestCopyWith<_BookingTimeWindowsRequest> get copyWith => __$BookingTimeWindowsRequestCopyWithImpl<_BookingTimeWindowsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingTimeWindowsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingTimeWindowsRequest&&(identical(other.clientTimezone, clientTimezone) || other.clientTimezone == clientTimezone)&&const DeepCollectionEquality().equals(other._windows, _windows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientTimezone,const DeepCollectionEquality().hash(_windows));

@override
String toString() {
  return 'BookingTimeWindowsRequest(clientTimezone: $clientTimezone, windows: $windows)';
}


}

/// @nodoc
abstract mixin class _$BookingTimeWindowsRequestCopyWith<$Res> implements $BookingTimeWindowsRequestCopyWith<$Res> {
  factory _$BookingTimeWindowsRequestCopyWith(_BookingTimeWindowsRequest value, $Res Function(_BookingTimeWindowsRequest) _then) = __$BookingTimeWindowsRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_) String clientTimezone,@JsonKey(name: BookingTimeWindowsRequest.windowsKey_) List<TimeWindowItem>? windows
});




}
/// @nodoc
class __$BookingTimeWindowsRequestCopyWithImpl<$Res>
    implements _$BookingTimeWindowsRequestCopyWith<$Res> {
  __$BookingTimeWindowsRequestCopyWithImpl(this._self, this._then);

  final _BookingTimeWindowsRequest _self;
  final $Res Function(_BookingTimeWindowsRequest) _then;

/// Create a copy of BookingTimeWindowsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientTimezone = null,Object? windows = freezed,}) {
  return _then(_BookingTimeWindowsRequest(
clientTimezone: null == clientTimezone ? _self.clientTimezone : clientTimezone // ignore: cast_nullable_to_non_nullable
as String,windows: freezed == windows ? _self._windows : windows // ignore: cast_nullable_to_non_nullable
as List<TimeWindowItem>?,
  ));
}


}

// dart format on
