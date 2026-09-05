// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_request_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingRequestCreateRequest {

/// packageId
@JsonKey(name: BookingRequestCreateRequest.packageIdKey_) String get packageId;/// requestedStart
@JsonKey(name: BookingRequestCreateRequest.requestedStartKey_) DateTime get requestedStart;/// requestedEnd
@JsonKey(name: BookingRequestCreateRequest.requestedEndKey_) DateTime get requestedEnd;/// locationText
@JsonKey(name: BookingRequestCreateRequest.locationTextKey_) String? get locationText;/// notes
@JsonKey(name: BookingRequestCreateRequest.notesKey_) String? get notes;
/// Create a copy of BookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingRequestCreateRequestCopyWith<BookingRequestCreateRequest> get copyWith => _$BookingRequestCreateRequestCopyWithImpl<BookingRequestCreateRequest>(this as BookingRequestCreateRequest, _$identity);

  /// Serializes this BookingRequestCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingRequestCreateRequest&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,requestedStart,requestedEnd,locationText,notes);

@override
String toString() {
  return 'BookingRequestCreateRequest(packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $BookingRequestCreateRequestCopyWith<$Res>  {
  factory $BookingRequestCreateRequestCopyWith(BookingRequestCreateRequest value, $Res Function(BookingRequestCreateRequest) _then) = _$BookingRequestCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingRequestCreateRequest.packageIdKey_) String packageId,@JsonKey(name: BookingRequestCreateRequest.requestedStartKey_) DateTime requestedStart,@JsonKey(name: BookingRequestCreateRequest.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: BookingRequestCreateRequest.locationTextKey_) String? locationText,@JsonKey(name: BookingRequestCreateRequest.notesKey_) String? notes
});




}
/// @nodoc
class _$BookingRequestCreateRequestCopyWithImpl<$Res>
    implements $BookingRequestCreateRequestCopyWith<$Res> {
  _$BookingRequestCreateRequestCopyWithImpl(this._self, this._then);

  final BookingRequestCreateRequest _self;
  final $Res Function(BookingRequestCreateRequest) _then;

/// Create a copy of BookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageId = null,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,requestedStart: null == requestedStart ? _self.requestedStart : requestedStart // ignore: cast_nullable_to_non_nullable
as DateTime,requestedEnd: null == requestedEnd ? _self.requestedEnd : requestedEnd // ignore: cast_nullable_to_non_nullable
as DateTime,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingRequestCreateRequest].
extension BookingRequestCreateRequestPatterns on BookingRequestCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingRequestCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingRequestCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingRequestCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _BookingRequestCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingRequestCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BookingRequestCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestCreateRequest.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestCreateRequest.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestCreateRequest.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestCreateRequest.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestCreateRequest.notesKey_)  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingRequestCreateRequest() when $default != null:
return $default(_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestCreateRequest.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestCreateRequest.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestCreateRequest.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestCreateRequest.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestCreateRequest.notesKey_)  String? notes)  $default,) {final _that = this;
switch (_that) {
case _BookingRequestCreateRequest():
return $default(_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingRequestCreateRequest.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestCreateRequest.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestCreateRequest.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestCreateRequest.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestCreateRequest.notesKey_)  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _BookingRequestCreateRequest() when $default != null:
return $default(_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingRequestCreateRequest extends BookingRequestCreateRequest {
  const _BookingRequestCreateRequest({@JsonKey(name: BookingRequestCreateRequest.packageIdKey_) required this.packageId, @JsonKey(name: BookingRequestCreateRequest.requestedStartKey_) required this.requestedStart, @JsonKey(name: BookingRequestCreateRequest.requestedEndKey_) required this.requestedEnd, @JsonKey(name: BookingRequestCreateRequest.locationTextKey_) this.locationText, @JsonKey(name: BookingRequestCreateRequest.notesKey_) this.notes}): super._();
  factory _BookingRequestCreateRequest.fromJson(Map<String, dynamic> json) => _$BookingRequestCreateRequestFromJson(json);

/// packageId
@override@JsonKey(name: BookingRequestCreateRequest.packageIdKey_) final  String packageId;
/// requestedStart
@override@JsonKey(name: BookingRequestCreateRequest.requestedStartKey_) final  DateTime requestedStart;
/// requestedEnd
@override@JsonKey(name: BookingRequestCreateRequest.requestedEndKey_) final  DateTime requestedEnd;
/// locationText
@override@JsonKey(name: BookingRequestCreateRequest.locationTextKey_) final  String? locationText;
/// notes
@override@JsonKey(name: BookingRequestCreateRequest.notesKey_) final  String? notes;

/// Create a copy of BookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingRequestCreateRequestCopyWith<_BookingRequestCreateRequest> get copyWith => __$BookingRequestCreateRequestCopyWithImpl<_BookingRequestCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingRequestCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingRequestCreateRequest&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,requestedStart,requestedEnd,locationText,notes);

@override
String toString() {
  return 'BookingRequestCreateRequest(packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$BookingRequestCreateRequestCopyWith<$Res> implements $BookingRequestCreateRequestCopyWith<$Res> {
  factory _$BookingRequestCreateRequestCopyWith(_BookingRequestCreateRequest value, $Res Function(_BookingRequestCreateRequest) _then) = __$BookingRequestCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingRequestCreateRequest.packageIdKey_) String packageId,@JsonKey(name: BookingRequestCreateRequest.requestedStartKey_) DateTime requestedStart,@JsonKey(name: BookingRequestCreateRequest.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: BookingRequestCreateRequest.locationTextKey_) String? locationText,@JsonKey(name: BookingRequestCreateRequest.notesKey_) String? notes
});




}
/// @nodoc
class __$BookingRequestCreateRequestCopyWithImpl<$Res>
    implements _$BookingRequestCreateRequestCopyWith<$Res> {
  __$BookingRequestCreateRequestCopyWithImpl(this._self, this._then);

  final _BookingRequestCreateRequest _self;
  final $Res Function(_BookingRequestCreateRequest) _then;

/// Create a copy of BookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageId = null,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? notes = freezed,}) {
  return _then(_BookingRequestCreateRequest(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,requestedStart: null == requestedStart ? _self.requestedStart : requestedStart // ignore: cast_nullable_to_non_nullable
as DateTime,requestedEnd: null == requestedEnd ? _self.requestedEnd : requestedEnd // ignore: cast_nullable_to_non_nullable
as DateTime,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
