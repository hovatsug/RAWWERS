// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingStatusResponse {

/// bookingId
@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_) String get bookingId;/// bookingStatus
@JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_) String get bookingStatus;/// gigId
@JsonKey(name: ClientBookingStatusResponse.gigIdKey_) String? get gigId;/// gigStatus
@JsonKey(name: ClientBookingStatusResponse.gigStatusKey_) String? get gigStatus;/// paymentStatus
@JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_) String? get paymentStatus;/// timeline
@JsonKey(name: ClientBookingStatusResponse.timelineKey_) List<Map<String, dynamic>>? get timeline;/// nextActions
@JsonKey(name: ClientBookingStatusResponse.nextActionsKey_) List<String>? get nextActions;
/// Create a copy of ClientBookingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingStatusResponseCopyWith<ClientBookingStatusResponse> get copyWith => _$ClientBookingStatusResponseCopyWithImpl<ClientBookingStatusResponse>(this as ClientBookingStatusResponse, _$identity);

  /// Serializes this ClientBookingStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingStatusResponse&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.gigStatus, gigStatus) || other.gigStatus == gigStatus)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&const DeepCollectionEquality().equals(other.nextActions, nextActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,bookingStatus,gigId,gigStatus,paymentStatus,const DeepCollectionEquality().hash(timeline),const DeepCollectionEquality().hash(nextActions));

@override
String toString() {
  return 'ClientBookingStatusResponse(bookingId: $bookingId, bookingStatus: $bookingStatus, gigId: $gigId, gigStatus: $gigStatus, paymentStatus: $paymentStatus, timeline: $timeline, nextActions: $nextActions)';
}


}

/// @nodoc
abstract mixin class $ClientBookingStatusResponseCopyWith<$Res>  {
  factory $ClientBookingStatusResponseCopyWith(ClientBookingStatusResponse value, $Res Function(ClientBookingStatusResponse) _then) = _$ClientBookingStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_) String bookingStatus,@JsonKey(name: ClientBookingStatusResponse.gigIdKey_) String? gigId,@JsonKey(name: ClientBookingStatusResponse.gigStatusKey_) String? gigStatus,@JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_) String? paymentStatus,@JsonKey(name: ClientBookingStatusResponse.timelineKey_) List<Map<String, dynamic>>? timeline,@JsonKey(name: ClientBookingStatusResponse.nextActionsKey_) List<String>? nextActions
});




}
/// @nodoc
class _$ClientBookingStatusResponseCopyWithImpl<$Res>
    implements $ClientBookingStatusResponseCopyWith<$Res> {
  _$ClientBookingStatusResponseCopyWithImpl(this._self, this._then);

  final ClientBookingStatusResponse _self;
  final $Res Function(ClientBookingStatusResponse) _then;

/// Create a copy of ClientBookingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? bookingStatus = null,Object? gigId = freezed,Object? gigStatus = freezed,Object? paymentStatus = freezed,Object? timeline = freezed,Object? nextActions = freezed,}) {
  return _then(_self.copyWith(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,bookingStatus: null == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,gigStatus: freezed == gigStatus ? _self.gigStatus : gigStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,timeline: freezed == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,nextActions: freezed == nextActions ? _self.nextActions : nextActions // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientBookingStatusResponse].
extension ClientBookingStatusResponsePatterns on ClientBookingStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_)  String bookingStatus, @JsonKey(name: ClientBookingStatusResponse.gigIdKey_)  String? gigId, @JsonKey(name: ClientBookingStatusResponse.gigStatusKey_)  String? gigStatus, @JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_)  String? paymentStatus, @JsonKey(name: ClientBookingStatusResponse.timelineKey_)  List<Map<String, dynamic>>? timeline, @JsonKey(name: ClientBookingStatusResponse.nextActionsKey_)  List<String>? nextActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingStatusResponse() when $default != null:
return $default(_that.bookingId,_that.bookingStatus,_that.gigId,_that.gigStatus,_that.paymentStatus,_that.timeline,_that.nextActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_)  String bookingStatus, @JsonKey(name: ClientBookingStatusResponse.gigIdKey_)  String? gigId, @JsonKey(name: ClientBookingStatusResponse.gigStatusKey_)  String? gigStatus, @JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_)  String? paymentStatus, @JsonKey(name: ClientBookingStatusResponse.timelineKey_)  List<Map<String, dynamic>>? timeline, @JsonKey(name: ClientBookingStatusResponse.nextActionsKey_)  List<String>? nextActions)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingStatusResponse():
return $default(_that.bookingId,_that.bookingStatus,_that.gigId,_that.gigStatus,_that.paymentStatus,_that.timeline,_that.nextActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_)  String bookingStatus, @JsonKey(name: ClientBookingStatusResponse.gigIdKey_)  String? gigId, @JsonKey(name: ClientBookingStatusResponse.gigStatusKey_)  String? gigStatus, @JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_)  String? paymentStatus, @JsonKey(name: ClientBookingStatusResponse.timelineKey_)  List<Map<String, dynamic>>? timeline, @JsonKey(name: ClientBookingStatusResponse.nextActionsKey_)  List<String>? nextActions)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingStatusResponse() when $default != null:
return $default(_that.bookingId,_that.bookingStatus,_that.gigId,_that.gigStatus,_that.paymentStatus,_that.timeline,_that.nextActions);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingStatusResponse extends ClientBookingStatusResponse {
  const _ClientBookingStatusResponse({@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_) required this.bookingId, @JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_) required this.bookingStatus, @JsonKey(name: ClientBookingStatusResponse.gigIdKey_) this.gigId, @JsonKey(name: ClientBookingStatusResponse.gigStatusKey_) this.gigStatus, @JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_) this.paymentStatus, @JsonKey(name: ClientBookingStatusResponse.timelineKey_) final  List<Map<String, dynamic>>? timeline, @JsonKey(name: ClientBookingStatusResponse.nextActionsKey_) final  List<String>? nextActions}): _timeline = timeline,_nextActions = nextActions,super._();
  factory _ClientBookingStatusResponse.fromJson(Map<String, dynamic> json) => _$ClientBookingStatusResponseFromJson(json);

/// bookingId
@override@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_) final  String bookingId;
/// bookingStatus
@override@JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_) final  String bookingStatus;
/// gigId
@override@JsonKey(name: ClientBookingStatusResponse.gigIdKey_) final  String? gigId;
/// gigStatus
@override@JsonKey(name: ClientBookingStatusResponse.gigStatusKey_) final  String? gigStatus;
/// paymentStatus
@override@JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_) final  String? paymentStatus;
/// timeline
 final  List<Map<String, dynamic>>? _timeline;
/// timeline
@override@JsonKey(name: ClientBookingStatusResponse.timelineKey_) List<Map<String, dynamic>>? get timeline {
  final value = _timeline;
  if (value == null) return null;
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// nextActions
 final  List<String>? _nextActions;
/// nextActions
@override@JsonKey(name: ClientBookingStatusResponse.nextActionsKey_) List<String>? get nextActions {
  final value = _nextActions;
  if (value == null) return null;
  if (_nextActions is EqualUnmodifiableListView) return _nextActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClientBookingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingStatusResponseCopyWith<_ClientBookingStatusResponse> get copyWith => __$ClientBookingStatusResponseCopyWithImpl<_ClientBookingStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingStatusResponse&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.gigStatus, gigStatus) || other.gigStatus == gigStatus)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&const DeepCollectionEquality().equals(other._nextActions, _nextActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,bookingStatus,gigId,gigStatus,paymentStatus,const DeepCollectionEquality().hash(_timeline),const DeepCollectionEquality().hash(_nextActions));

@override
String toString() {
  return 'ClientBookingStatusResponse(bookingId: $bookingId, bookingStatus: $bookingStatus, gigId: $gigId, gigStatus: $gigStatus, paymentStatus: $paymentStatus, timeline: $timeline, nextActions: $nextActions)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingStatusResponseCopyWith<$Res> implements $ClientBookingStatusResponseCopyWith<$Res> {
  factory _$ClientBookingStatusResponseCopyWith(_ClientBookingStatusResponse value, $Res Function(_ClientBookingStatusResponse) _then) = __$ClientBookingStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingStatusResponse.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_) String bookingStatus,@JsonKey(name: ClientBookingStatusResponse.gigIdKey_) String? gigId,@JsonKey(name: ClientBookingStatusResponse.gigStatusKey_) String? gigStatus,@JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_) String? paymentStatus,@JsonKey(name: ClientBookingStatusResponse.timelineKey_) List<Map<String, dynamic>>? timeline,@JsonKey(name: ClientBookingStatusResponse.nextActionsKey_) List<String>? nextActions
});




}
/// @nodoc
class __$ClientBookingStatusResponseCopyWithImpl<$Res>
    implements _$ClientBookingStatusResponseCopyWith<$Res> {
  __$ClientBookingStatusResponseCopyWithImpl(this._self, this._then);

  final _ClientBookingStatusResponse _self;
  final $Res Function(_ClientBookingStatusResponse) _then;

/// Create a copy of ClientBookingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? bookingStatus = null,Object? gigId = freezed,Object? gigStatus = freezed,Object? paymentStatus = freezed,Object? timeline = freezed,Object? nextActions = freezed,}) {
  return _then(_ClientBookingStatusResponse(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,bookingStatus: null == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,gigStatus: freezed == gigStatus ? _self.gigStatus : gigStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,timeline: freezed == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,nextActions: freezed == nextActions ? _self._nextActions : nextActions // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
