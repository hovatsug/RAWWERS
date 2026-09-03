// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_booking_from_chat_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateBookingFromChatRequest {

/// packageId
@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_) String get packageId;/// requestedStart
@JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_) DateTime get requestedStart;/// requestedEnd
@JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_) DateTime get requestedEnd;/// locationText
@JsonKey(name: CreateBookingFromChatRequest.locationTextKey_) String? get locationText;/// notes
@JsonKey(name: CreateBookingFromChatRequest.notesKey_) String? get notes;
/// Create a copy of CreateBookingFromChatRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateBookingFromChatRequestCopyWith<CreateBookingFromChatRequest> get copyWith => _$CreateBookingFromChatRequestCopyWithImpl<CreateBookingFromChatRequest>(this as CreateBookingFromChatRequest, _$identity);

  /// Serializes this CreateBookingFromChatRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateBookingFromChatRequest&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,requestedStart,requestedEnd,locationText,notes);

@override
String toString() {
  return 'CreateBookingFromChatRequest(packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateBookingFromChatRequestCopyWith<$Res>  {
  factory $CreateBookingFromChatRequestCopyWith(CreateBookingFromChatRequest value, $Res Function(CreateBookingFromChatRequest) _then) = _$CreateBookingFromChatRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_) String packageId,@JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_) DateTime requestedStart,@JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: CreateBookingFromChatRequest.locationTextKey_) String? locationText,@JsonKey(name: CreateBookingFromChatRequest.notesKey_) String? notes
});




}
/// @nodoc
class _$CreateBookingFromChatRequestCopyWithImpl<$Res>
    implements $CreateBookingFromChatRequestCopyWith<$Res> {
  _$CreateBookingFromChatRequestCopyWithImpl(this._self, this._then);

  final CreateBookingFromChatRequest _self;
  final $Res Function(CreateBookingFromChatRequest) _then;

/// Create a copy of CreateBookingFromChatRequest
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


/// Adds pattern-matching-related methods to [CreateBookingFromChatRequest].
extension CreateBookingFromChatRequestPatterns on CreateBookingFromChatRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateBookingFromChatRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateBookingFromChatRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateBookingFromChatRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateBookingFromChatRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateBookingFromChatRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateBookingFromChatRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_)  String packageId, @JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: CreateBookingFromChatRequest.locationTextKey_)  String? locationText, @JsonKey(name: CreateBookingFromChatRequest.notesKey_)  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateBookingFromChatRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_)  String packageId, @JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: CreateBookingFromChatRequest.locationTextKey_)  String? locationText, @JsonKey(name: CreateBookingFromChatRequest.notesKey_)  String? notes)  $default,) {final _that = this;
switch (_that) {
case _CreateBookingFromChatRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_)  String packageId, @JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: CreateBookingFromChatRequest.locationTextKey_)  String? locationText, @JsonKey(name: CreateBookingFromChatRequest.notesKey_)  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _CreateBookingFromChatRequest() when $default != null:
return $default(_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateBookingFromChatRequest extends CreateBookingFromChatRequest {
  const _CreateBookingFromChatRequest({@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_) required this.packageId, @JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_) required this.requestedStart, @JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_) required this.requestedEnd, @JsonKey(name: CreateBookingFromChatRequest.locationTextKey_) this.locationText, @JsonKey(name: CreateBookingFromChatRequest.notesKey_) this.notes}): super._();
  factory _CreateBookingFromChatRequest.fromJson(Map<String, dynamic> json) => _$CreateBookingFromChatRequestFromJson(json);

/// packageId
@override@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_) final  String packageId;
/// requestedStart
@override@JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_) final  DateTime requestedStart;
/// requestedEnd
@override@JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_) final  DateTime requestedEnd;
/// locationText
@override@JsonKey(name: CreateBookingFromChatRequest.locationTextKey_) final  String? locationText;
/// notes
@override@JsonKey(name: CreateBookingFromChatRequest.notesKey_) final  String? notes;

/// Create a copy of CreateBookingFromChatRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateBookingFromChatRequestCopyWith<_CreateBookingFromChatRequest> get copyWith => __$CreateBookingFromChatRequestCopyWithImpl<_CreateBookingFromChatRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateBookingFromChatRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateBookingFromChatRequest&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,requestedStart,requestedEnd,locationText,notes);

@override
String toString() {
  return 'CreateBookingFromChatRequest(packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CreateBookingFromChatRequestCopyWith<$Res> implements $CreateBookingFromChatRequestCopyWith<$Res> {
  factory _$CreateBookingFromChatRequestCopyWith(_CreateBookingFromChatRequest value, $Res Function(_CreateBookingFromChatRequest) _then) = __$CreateBookingFromChatRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateBookingFromChatRequest.packageIdKey_) String packageId,@JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_) DateTime requestedStart,@JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: CreateBookingFromChatRequest.locationTextKey_) String? locationText,@JsonKey(name: CreateBookingFromChatRequest.notesKey_) String? notes
});




}
/// @nodoc
class __$CreateBookingFromChatRequestCopyWithImpl<$Res>
    implements _$CreateBookingFromChatRequestCopyWith<$Res> {
  __$CreateBookingFromChatRequestCopyWithImpl(this._self, this._then);

  final _CreateBookingFromChatRequest _self;
  final $Res Function(_CreateBookingFromChatRequest) _then;

/// Create a copy of CreateBookingFromChatRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageId = null,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? notes = freezed,}) {
  return _then(_CreateBookingFromChatRequest(
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
