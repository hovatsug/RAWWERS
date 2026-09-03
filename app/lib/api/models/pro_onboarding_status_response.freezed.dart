// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_onboarding_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProOnboardingStatusResponse {

/// proUserId
@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_) String get proUserId;/// status
@JsonKey(name: ProOnboardingStatusResponse.statusKey_) ProOnboardingStatus get status;/// currentCity
@JsonKey(name: ProOnboardingStatusResponse.currentCityKey_) Map<String, dynamic>? get currentCity;/// inviteCodeId
@JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_) String? get inviteCodeId;/// notes
@JsonKey(name: ProOnboardingStatusResponse.notesKey_) String? get notes;/// startedAt
@JsonKey(name: ProOnboardingStatusResponse.startedAtKey_) DateTime get startedAt;/// updatedAt
@JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of ProOnboardingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProOnboardingStatusResponseCopyWith<ProOnboardingStatusResponse> get copyWith => _$ProOnboardingStatusResponseCopyWithImpl<ProOnboardingStatusResponse>(this as ProOnboardingStatusResponse, _$identity);

  /// Serializes this ProOnboardingStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProOnboardingStatusResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.currentCity, currentCity)&&(identical(other.inviteCodeId, inviteCodeId) || other.inviteCodeId == inviteCodeId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,status,const DeepCollectionEquality().hash(currentCity),inviteCodeId,notes,startedAt,updatedAt);

@override
String toString() {
  return 'ProOnboardingStatusResponse(proUserId: $proUserId, status: $status, currentCity: $currentCity, inviteCodeId: $inviteCodeId, notes: $notes, startedAt: $startedAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProOnboardingStatusResponseCopyWith<$Res>  {
  factory $ProOnboardingStatusResponseCopyWith(ProOnboardingStatusResponse value, $Res Function(ProOnboardingStatusResponse) _then) = _$ProOnboardingStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProOnboardingStatusResponse.statusKey_) ProOnboardingStatus status,@JsonKey(name: ProOnboardingStatusResponse.currentCityKey_) Map<String, dynamic>? currentCity,@JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_) String? inviteCodeId,@JsonKey(name: ProOnboardingStatusResponse.notesKey_) String? notes,@JsonKey(name: ProOnboardingStatusResponse.startedAtKey_) DateTime startedAt,@JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$ProOnboardingStatusResponseCopyWithImpl<$Res>
    implements $ProOnboardingStatusResponseCopyWith<$Res> {
  _$ProOnboardingStatusResponseCopyWithImpl(this._self, this._then);

  final ProOnboardingStatusResponse _self;
  final $Res Function(ProOnboardingStatusResponse) _then;

/// Create a copy of ProOnboardingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? status = null,Object? currentCity = freezed,Object? inviteCodeId = freezed,Object? notes = freezed,Object? startedAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProOnboardingStatus,currentCity: freezed == currentCity ? _self.currentCity : currentCity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,inviteCodeId: freezed == inviteCodeId ? _self.inviteCodeId : inviteCodeId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProOnboardingStatusResponse].
extension ProOnboardingStatusResponsePatterns on ProOnboardingStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProOnboardingStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProOnboardingStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProOnboardingStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProOnboardingStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProOnboardingStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProOnboardingStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProOnboardingStatusResponse.statusKey_)  ProOnboardingStatus status, @JsonKey(name: ProOnboardingStatusResponse.currentCityKey_)  Map<String, dynamic>? currentCity, @JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_)  String? inviteCodeId, @JsonKey(name: ProOnboardingStatusResponse.notesKey_)  String? notes, @JsonKey(name: ProOnboardingStatusResponse.startedAtKey_)  DateTime startedAt, @JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProOnboardingStatusResponse() when $default != null:
return $default(_that.proUserId,_that.status,_that.currentCity,_that.inviteCodeId,_that.notes,_that.startedAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProOnboardingStatusResponse.statusKey_)  ProOnboardingStatus status, @JsonKey(name: ProOnboardingStatusResponse.currentCityKey_)  Map<String, dynamic>? currentCity, @JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_)  String? inviteCodeId, @JsonKey(name: ProOnboardingStatusResponse.notesKey_)  String? notes, @JsonKey(name: ProOnboardingStatusResponse.startedAtKey_)  DateTime startedAt, @JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProOnboardingStatusResponse():
return $default(_that.proUserId,_that.status,_that.currentCity,_that.inviteCodeId,_that.notes,_that.startedAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProOnboardingStatusResponse.statusKey_)  ProOnboardingStatus status, @JsonKey(name: ProOnboardingStatusResponse.currentCityKey_)  Map<String, dynamic>? currentCity, @JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_)  String? inviteCodeId, @JsonKey(name: ProOnboardingStatusResponse.notesKey_)  String? notes, @JsonKey(name: ProOnboardingStatusResponse.startedAtKey_)  DateTime startedAt, @JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProOnboardingStatusResponse() when $default != null:
return $default(_that.proUserId,_that.status,_that.currentCity,_that.inviteCodeId,_that.notes,_that.startedAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProOnboardingStatusResponse extends ProOnboardingStatusResponse {
  const _ProOnboardingStatusResponse({@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: ProOnboardingStatusResponse.statusKey_) required this.status, @JsonKey(name: ProOnboardingStatusResponse.currentCityKey_) final  Map<String, dynamic>? currentCity, @JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_) this.inviteCodeId, @JsonKey(name: ProOnboardingStatusResponse.notesKey_) this.notes, @JsonKey(name: ProOnboardingStatusResponse.startedAtKey_) required this.startedAt, @JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_) required this.updatedAt}): _currentCity = currentCity,super._();
  factory _ProOnboardingStatusResponse.fromJson(Map<String, dynamic> json) => _$ProOnboardingStatusResponseFromJson(json);

/// proUserId
@override@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_) final  String proUserId;
/// status
@override@JsonKey(name: ProOnboardingStatusResponse.statusKey_) final  ProOnboardingStatus status;
/// currentCity
 final  Map<String, dynamic>? _currentCity;
/// currentCity
@override@JsonKey(name: ProOnboardingStatusResponse.currentCityKey_) Map<String, dynamic>? get currentCity {
  final value = _currentCity;
  if (value == null) return null;
  if (_currentCity is EqualUnmodifiableMapView) return _currentCity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// inviteCodeId
@override@JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_) final  String? inviteCodeId;
/// notes
@override@JsonKey(name: ProOnboardingStatusResponse.notesKey_) final  String? notes;
/// startedAt
@override@JsonKey(name: ProOnboardingStatusResponse.startedAtKey_) final  DateTime startedAt;
/// updatedAt
@override@JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of ProOnboardingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProOnboardingStatusResponseCopyWith<_ProOnboardingStatusResponse> get copyWith => __$ProOnboardingStatusResponseCopyWithImpl<_ProOnboardingStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProOnboardingStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProOnboardingStatusResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._currentCity, _currentCity)&&(identical(other.inviteCodeId, inviteCodeId) || other.inviteCodeId == inviteCodeId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,status,const DeepCollectionEquality().hash(_currentCity),inviteCodeId,notes,startedAt,updatedAt);

@override
String toString() {
  return 'ProOnboardingStatusResponse(proUserId: $proUserId, status: $status, currentCity: $currentCity, inviteCodeId: $inviteCodeId, notes: $notes, startedAt: $startedAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProOnboardingStatusResponseCopyWith<$Res> implements $ProOnboardingStatusResponseCopyWith<$Res> {
  factory _$ProOnboardingStatusResponseCopyWith(_ProOnboardingStatusResponse value, $Res Function(_ProOnboardingStatusResponse) _then) = __$ProOnboardingStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProOnboardingStatusResponse.statusKey_) ProOnboardingStatus status,@JsonKey(name: ProOnboardingStatusResponse.currentCityKey_) Map<String, dynamic>? currentCity,@JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_) String? inviteCodeId,@JsonKey(name: ProOnboardingStatusResponse.notesKey_) String? notes,@JsonKey(name: ProOnboardingStatusResponse.startedAtKey_) DateTime startedAt,@JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$ProOnboardingStatusResponseCopyWithImpl<$Res>
    implements _$ProOnboardingStatusResponseCopyWith<$Res> {
  __$ProOnboardingStatusResponseCopyWithImpl(this._self, this._then);

  final _ProOnboardingStatusResponse _self;
  final $Res Function(_ProOnboardingStatusResponse) _then;

/// Create a copy of ProOnboardingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? status = null,Object? currentCity = freezed,Object? inviteCodeId = freezed,Object? notes = freezed,Object? startedAt = null,Object? updatedAt = null,}) {
  return _then(_ProOnboardingStatusResponse(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProOnboardingStatus,currentCity: freezed == currentCity ? _self._currentCity : currentCity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,inviteCodeId: freezed == inviteCodeId ? _self.inviteCodeId : inviteCodeId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
