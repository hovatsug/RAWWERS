// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_request_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingRequestCreateRequest {

/// proUserId
@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_) String get proUserId;/// nicheSlug
@JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_) String get nicheSlug;/// dateWindow
@JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_) BookingDateWindow get dateWindow;/// location
@JsonKey(name: ClientBookingRequestCreateRequest.locationKey_) String? get location;/// packageId
@JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_) String get packageId;/// notes
@JsonKey(name: ClientBookingRequestCreateRequest.notesKey_) String? get notes;/// consentLevel
@JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_) GigConsentLevel? get consentLevel;
/// Create a copy of ClientBookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingRequestCreateRequestCopyWith<ClientBookingRequestCreateRequest> get copyWith => _$ClientBookingRequestCreateRequestCopyWithImpl<ClientBookingRequestCreateRequest>(this as ClientBookingRequestCreateRequest, _$identity);

  /// Serializes this ClientBookingRequestCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingRequestCreateRequest&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.dateWindow, dateWindow) || other.dateWindow == dateWindow)&&(identical(other.location, location) || other.location == location)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.consentLevel, consentLevel) || other.consentLevel == consentLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,nicheSlug,dateWindow,location,packageId,notes,consentLevel);

@override
String toString() {
  return 'ClientBookingRequestCreateRequest(proUserId: $proUserId, nicheSlug: $nicheSlug, dateWindow: $dateWindow, location: $location, packageId: $packageId, notes: $notes, consentLevel: $consentLevel)';
}


}

/// @nodoc
abstract mixin class $ClientBookingRequestCreateRequestCopyWith<$Res>  {
  factory $ClientBookingRequestCreateRequestCopyWith(ClientBookingRequestCreateRequest value, $Res Function(ClientBookingRequestCreateRequest) _then) = _$ClientBookingRequestCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_) String proUserId,@JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_) String nicheSlug,@JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_) BookingDateWindow dateWindow,@JsonKey(name: ClientBookingRequestCreateRequest.locationKey_) String? location,@JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_) String packageId,@JsonKey(name: ClientBookingRequestCreateRequest.notesKey_) String? notes,@JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_) GigConsentLevel? consentLevel
});


$BookingDateWindowCopyWith<$Res> get dateWindow;

}
/// @nodoc
class _$ClientBookingRequestCreateRequestCopyWithImpl<$Res>
    implements $ClientBookingRequestCreateRequestCopyWith<$Res> {
  _$ClientBookingRequestCreateRequestCopyWithImpl(this._self, this._then);

  final ClientBookingRequestCreateRequest _self;
  final $Res Function(ClientBookingRequestCreateRequest) _then;

/// Create a copy of ClientBookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? nicheSlug = null,Object? dateWindow = null,Object? location = freezed,Object? packageId = null,Object? notes = freezed,Object? consentLevel = freezed,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,dateWindow: null == dateWindow ? _self.dateWindow : dateWindow // ignore: cast_nullable_to_non_nullable
as BookingDateWindow,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,consentLevel: freezed == consentLevel ? _self.consentLevel : consentLevel // ignore: cast_nullable_to_non_nullable
as GigConsentLevel?,
  ));
}
/// Create a copy of ClientBookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingDateWindowCopyWith<$Res> get dateWindow {
  
  return $BookingDateWindowCopyWith<$Res>(_self.dateWindow, (value) {
    return _then(_self.copyWith(dateWindow: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientBookingRequestCreateRequest].
extension ClientBookingRequestCreateRequestPatterns on ClientBookingRequestCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingRequestCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingRequestCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingRequestCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingRequestCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingRequestCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingRequestCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_)  String proUserId, @JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_)  BookingDateWindow dateWindow, @JsonKey(name: ClientBookingRequestCreateRequest.locationKey_)  String? location, @JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_)  String packageId, @JsonKey(name: ClientBookingRequestCreateRequest.notesKey_)  String? notes, @JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_)  GigConsentLevel? consentLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingRequestCreateRequest() when $default != null:
return $default(_that.proUserId,_that.nicheSlug,_that.dateWindow,_that.location,_that.packageId,_that.notes,_that.consentLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_)  String proUserId, @JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_)  BookingDateWindow dateWindow, @JsonKey(name: ClientBookingRequestCreateRequest.locationKey_)  String? location, @JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_)  String packageId, @JsonKey(name: ClientBookingRequestCreateRequest.notesKey_)  String? notes, @JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_)  GigConsentLevel? consentLevel)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingRequestCreateRequest():
return $default(_that.proUserId,_that.nicheSlug,_that.dateWindow,_that.location,_that.packageId,_that.notes,_that.consentLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_)  String proUserId, @JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_)  BookingDateWindow dateWindow, @JsonKey(name: ClientBookingRequestCreateRequest.locationKey_)  String? location, @JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_)  String packageId, @JsonKey(name: ClientBookingRequestCreateRequest.notesKey_)  String? notes, @JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_)  GigConsentLevel? consentLevel)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingRequestCreateRequest() when $default != null:
return $default(_that.proUserId,_that.nicheSlug,_that.dateWindow,_that.location,_that.packageId,_that.notes,_that.consentLevel);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingRequestCreateRequest extends ClientBookingRequestCreateRequest {
  const _ClientBookingRequestCreateRequest({@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_) required this.proUserId, @JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_) required this.nicheSlug, @JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_) required this.dateWindow, @JsonKey(name: ClientBookingRequestCreateRequest.locationKey_) this.location, @JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_) required this.packageId, @JsonKey(name: ClientBookingRequestCreateRequest.notesKey_) this.notes, @JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_) this.consentLevel}): super._();
  factory _ClientBookingRequestCreateRequest.fromJson(Map<String, dynamic> json) => _$ClientBookingRequestCreateRequestFromJson(json);

/// proUserId
@override@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_) final  String proUserId;
/// nicheSlug
@override@JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_) final  String nicheSlug;
/// dateWindow
@override@JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_) final  BookingDateWindow dateWindow;
/// location
@override@JsonKey(name: ClientBookingRequestCreateRequest.locationKey_) final  String? location;
/// packageId
@override@JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_) final  String packageId;
/// notes
@override@JsonKey(name: ClientBookingRequestCreateRequest.notesKey_) final  String? notes;
/// consentLevel
@override@JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_) final  GigConsentLevel? consentLevel;

/// Create a copy of ClientBookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingRequestCreateRequestCopyWith<_ClientBookingRequestCreateRequest> get copyWith => __$ClientBookingRequestCreateRequestCopyWithImpl<_ClientBookingRequestCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingRequestCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingRequestCreateRequest&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.dateWindow, dateWindow) || other.dateWindow == dateWindow)&&(identical(other.location, location) || other.location == location)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.consentLevel, consentLevel) || other.consentLevel == consentLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,nicheSlug,dateWindow,location,packageId,notes,consentLevel);

@override
String toString() {
  return 'ClientBookingRequestCreateRequest(proUserId: $proUserId, nicheSlug: $nicheSlug, dateWindow: $dateWindow, location: $location, packageId: $packageId, notes: $notes, consentLevel: $consentLevel)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingRequestCreateRequestCopyWith<$Res> implements $ClientBookingRequestCreateRequestCopyWith<$Res> {
  factory _$ClientBookingRequestCreateRequestCopyWith(_ClientBookingRequestCreateRequest value, $Res Function(_ClientBookingRequestCreateRequest) _then) = __$ClientBookingRequestCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_) String proUserId,@JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_) String nicheSlug,@JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_) BookingDateWindow dateWindow,@JsonKey(name: ClientBookingRequestCreateRequest.locationKey_) String? location,@JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_) String packageId,@JsonKey(name: ClientBookingRequestCreateRequest.notesKey_) String? notes,@JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_) GigConsentLevel? consentLevel
});


@override $BookingDateWindowCopyWith<$Res> get dateWindow;

}
/// @nodoc
class __$ClientBookingRequestCreateRequestCopyWithImpl<$Res>
    implements _$ClientBookingRequestCreateRequestCopyWith<$Res> {
  __$ClientBookingRequestCreateRequestCopyWithImpl(this._self, this._then);

  final _ClientBookingRequestCreateRequest _self;
  final $Res Function(_ClientBookingRequestCreateRequest) _then;

/// Create a copy of ClientBookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? nicheSlug = null,Object? dateWindow = null,Object? location = freezed,Object? packageId = null,Object? notes = freezed,Object? consentLevel = freezed,}) {
  return _then(_ClientBookingRequestCreateRequest(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,dateWindow: null == dateWindow ? _self.dateWindow : dateWindow // ignore: cast_nullable_to_non_nullable
as BookingDateWindow,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,consentLevel: freezed == consentLevel ? _self.consentLevel : consentLevel // ignore: cast_nullable_to_non_nullable
as GigConsentLevel?,
  ));
}

/// Create a copy of ClientBookingRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingDateWindowCopyWith<$Res> get dateWindow {
  
  return $BookingDateWindowCopyWith<$Res>(_self.dateWindow, (value) {
    return _then(_self.copyWith(dateWindow: value));
  });
}
}

// dart format on
