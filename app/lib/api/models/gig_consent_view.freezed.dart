// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_consent_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GigConsentView {

/// gigId
@JsonKey(name: GigConsentView.gigIdKey_) String get gigId;/// clientUserId
@JsonKey(name: GigConsentView.clientUserIdKey_) String get clientUserId;/// proUserId
@JsonKey(name: GigConsentView.proUserIdKey_) String get proUserId;/// consentLevel
@JsonKey(name: GigConsentView.consentLevelKey_) GigConsentLevel get consentLevel;/// scope
@JsonKey(name: GigConsentView.scopeKey_) Map<String, dynamic>? get scope;/// incentive
@JsonKey(name: GigConsentView.incentiveKey_) Map<String, dynamic>? get incentive;/// snapshotAtBooking
@JsonKey(name: GigConsentView.snapshotAtBookingKey_) bool get snapshotAtBooking;/// createdAt
@JsonKey(name: GigConsentView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: GigConsentView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of GigConsentView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GigConsentViewCopyWith<GigConsentView> get copyWith => _$GigConsentViewCopyWithImpl<GigConsentView>(this as GigConsentView, _$identity);

  /// Serializes this GigConsentView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GigConsentView&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.consentLevel, consentLevel) || other.consentLevel == consentLevel)&&const DeepCollectionEquality().equals(other.scope, scope)&&const DeepCollectionEquality().equals(other.incentive, incentive)&&(identical(other.snapshotAtBooking, snapshotAtBooking) || other.snapshotAtBooking == snapshotAtBooking)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,clientUserId,proUserId,consentLevel,const DeepCollectionEquality().hash(scope),const DeepCollectionEquality().hash(incentive),snapshotAtBooking,createdAt,updatedAt);

@override
String toString() {
  return 'GigConsentView(gigId: $gigId, clientUserId: $clientUserId, proUserId: $proUserId, consentLevel: $consentLevel, scope: $scope, incentive: $incentive, snapshotAtBooking: $snapshotAtBooking, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GigConsentViewCopyWith<$Res>  {
  factory $GigConsentViewCopyWith(GigConsentView value, $Res Function(GigConsentView) _then) = _$GigConsentViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GigConsentView.gigIdKey_) String gigId,@JsonKey(name: GigConsentView.clientUserIdKey_) String clientUserId,@JsonKey(name: GigConsentView.proUserIdKey_) String proUserId,@JsonKey(name: GigConsentView.consentLevelKey_) GigConsentLevel consentLevel,@JsonKey(name: GigConsentView.scopeKey_) Map<String, dynamic>? scope,@JsonKey(name: GigConsentView.incentiveKey_) Map<String, dynamic>? incentive,@JsonKey(name: GigConsentView.snapshotAtBookingKey_) bool snapshotAtBooking,@JsonKey(name: GigConsentView.createdAtKey_) DateTime createdAt,@JsonKey(name: GigConsentView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$GigConsentViewCopyWithImpl<$Res>
    implements $GigConsentViewCopyWith<$Res> {
  _$GigConsentViewCopyWithImpl(this._self, this._then);

  final GigConsentView _self;
  final $Res Function(GigConsentView) _then;

/// Create a copy of GigConsentView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gigId = null,Object? clientUserId = null,Object? proUserId = null,Object? consentLevel = null,Object? scope = freezed,Object? incentive = freezed,Object? snapshotAtBooking = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,consentLevel: null == consentLevel ? _self.consentLevel : consentLevel // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,incentive: freezed == incentive ? _self.incentive : incentive // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,snapshotAtBooking: null == snapshotAtBooking ? _self.snapshotAtBooking : snapshotAtBooking // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GigConsentView].
extension GigConsentViewPatterns on GigConsentView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GigConsentView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GigConsentView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GigConsentView value)  $default,){
final _that = this;
switch (_that) {
case _GigConsentView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GigConsentView value)?  $default,){
final _that = this;
switch (_that) {
case _GigConsentView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GigConsentView.gigIdKey_)  String gigId, @JsonKey(name: GigConsentView.clientUserIdKey_)  String clientUserId, @JsonKey(name: GigConsentView.proUserIdKey_)  String proUserId, @JsonKey(name: GigConsentView.consentLevelKey_)  GigConsentLevel consentLevel, @JsonKey(name: GigConsentView.scopeKey_)  Map<String, dynamic>? scope, @JsonKey(name: GigConsentView.incentiveKey_)  Map<String, dynamic>? incentive, @JsonKey(name: GigConsentView.snapshotAtBookingKey_)  bool snapshotAtBooking, @JsonKey(name: GigConsentView.createdAtKey_)  DateTime createdAt, @JsonKey(name: GigConsentView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GigConsentView() when $default != null:
return $default(_that.gigId,_that.clientUserId,_that.proUserId,_that.consentLevel,_that.scope,_that.incentive,_that.snapshotAtBooking,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GigConsentView.gigIdKey_)  String gigId, @JsonKey(name: GigConsentView.clientUserIdKey_)  String clientUserId, @JsonKey(name: GigConsentView.proUserIdKey_)  String proUserId, @JsonKey(name: GigConsentView.consentLevelKey_)  GigConsentLevel consentLevel, @JsonKey(name: GigConsentView.scopeKey_)  Map<String, dynamic>? scope, @JsonKey(name: GigConsentView.incentiveKey_)  Map<String, dynamic>? incentive, @JsonKey(name: GigConsentView.snapshotAtBookingKey_)  bool snapshotAtBooking, @JsonKey(name: GigConsentView.createdAtKey_)  DateTime createdAt, @JsonKey(name: GigConsentView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GigConsentView():
return $default(_that.gigId,_that.clientUserId,_that.proUserId,_that.consentLevel,_that.scope,_that.incentive,_that.snapshotAtBooking,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GigConsentView.gigIdKey_)  String gigId, @JsonKey(name: GigConsentView.clientUserIdKey_)  String clientUserId, @JsonKey(name: GigConsentView.proUserIdKey_)  String proUserId, @JsonKey(name: GigConsentView.consentLevelKey_)  GigConsentLevel consentLevel, @JsonKey(name: GigConsentView.scopeKey_)  Map<String, dynamic>? scope, @JsonKey(name: GigConsentView.incentiveKey_)  Map<String, dynamic>? incentive, @JsonKey(name: GigConsentView.snapshotAtBookingKey_)  bool snapshotAtBooking, @JsonKey(name: GigConsentView.createdAtKey_)  DateTime createdAt, @JsonKey(name: GigConsentView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GigConsentView() when $default != null:
return $default(_that.gigId,_that.clientUserId,_that.proUserId,_that.consentLevel,_that.scope,_that.incentive,_that.snapshotAtBooking,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GigConsentView extends GigConsentView {
  const _GigConsentView({@JsonKey(name: GigConsentView.gigIdKey_) required this.gigId, @JsonKey(name: GigConsentView.clientUserIdKey_) required this.clientUserId, @JsonKey(name: GigConsentView.proUserIdKey_) required this.proUserId, @JsonKey(name: GigConsentView.consentLevelKey_) required this.consentLevel, @JsonKey(name: GigConsentView.scopeKey_) final  Map<String, dynamic>? scope, @JsonKey(name: GigConsentView.incentiveKey_) final  Map<String, dynamic>? incentive, @JsonKey(name: GigConsentView.snapshotAtBookingKey_) required this.snapshotAtBooking, @JsonKey(name: GigConsentView.createdAtKey_) required this.createdAt, @JsonKey(name: GigConsentView.updatedAtKey_) required this.updatedAt}): _scope = scope,_incentive = incentive,super._();
  factory _GigConsentView.fromJson(Map<String, dynamic> json) => _$GigConsentViewFromJson(json);

/// gigId
@override@JsonKey(name: GigConsentView.gigIdKey_) final  String gigId;
/// clientUserId
@override@JsonKey(name: GigConsentView.clientUserIdKey_) final  String clientUserId;
/// proUserId
@override@JsonKey(name: GigConsentView.proUserIdKey_) final  String proUserId;
/// consentLevel
@override@JsonKey(name: GigConsentView.consentLevelKey_) final  GigConsentLevel consentLevel;
/// scope
 final  Map<String, dynamic>? _scope;
/// scope
@override@JsonKey(name: GigConsentView.scopeKey_) Map<String, dynamic>? get scope {
  final value = _scope;
  if (value == null) return null;
  if (_scope is EqualUnmodifiableMapView) return _scope;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// incentive
 final  Map<String, dynamic>? _incentive;
/// incentive
@override@JsonKey(name: GigConsentView.incentiveKey_) Map<String, dynamic>? get incentive {
  final value = _incentive;
  if (value == null) return null;
  if (_incentive is EqualUnmodifiableMapView) return _incentive;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// snapshotAtBooking
@override@JsonKey(name: GigConsentView.snapshotAtBookingKey_) final  bool snapshotAtBooking;
/// createdAt
@override@JsonKey(name: GigConsentView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: GigConsentView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of GigConsentView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GigConsentViewCopyWith<_GigConsentView> get copyWith => __$GigConsentViewCopyWithImpl<_GigConsentView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GigConsentViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GigConsentView&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.consentLevel, consentLevel) || other.consentLevel == consentLevel)&&const DeepCollectionEquality().equals(other._scope, _scope)&&const DeepCollectionEquality().equals(other._incentive, _incentive)&&(identical(other.snapshotAtBooking, snapshotAtBooking) || other.snapshotAtBooking == snapshotAtBooking)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,clientUserId,proUserId,consentLevel,const DeepCollectionEquality().hash(_scope),const DeepCollectionEquality().hash(_incentive),snapshotAtBooking,createdAt,updatedAt);

@override
String toString() {
  return 'GigConsentView(gigId: $gigId, clientUserId: $clientUserId, proUserId: $proUserId, consentLevel: $consentLevel, scope: $scope, incentive: $incentive, snapshotAtBooking: $snapshotAtBooking, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GigConsentViewCopyWith<$Res> implements $GigConsentViewCopyWith<$Res> {
  factory _$GigConsentViewCopyWith(_GigConsentView value, $Res Function(_GigConsentView) _then) = __$GigConsentViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GigConsentView.gigIdKey_) String gigId,@JsonKey(name: GigConsentView.clientUserIdKey_) String clientUserId,@JsonKey(name: GigConsentView.proUserIdKey_) String proUserId,@JsonKey(name: GigConsentView.consentLevelKey_) GigConsentLevel consentLevel,@JsonKey(name: GigConsentView.scopeKey_) Map<String, dynamic>? scope,@JsonKey(name: GigConsentView.incentiveKey_) Map<String, dynamic>? incentive,@JsonKey(name: GigConsentView.snapshotAtBookingKey_) bool snapshotAtBooking,@JsonKey(name: GigConsentView.createdAtKey_) DateTime createdAt,@JsonKey(name: GigConsentView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$GigConsentViewCopyWithImpl<$Res>
    implements _$GigConsentViewCopyWith<$Res> {
  __$GigConsentViewCopyWithImpl(this._self, this._then);

  final _GigConsentView _self;
  final $Res Function(_GigConsentView) _then;

/// Create a copy of GigConsentView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gigId = null,Object? clientUserId = null,Object? proUserId = null,Object? consentLevel = null,Object? scope = freezed,Object? incentive = freezed,Object? snapshotAtBooking = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_GigConsentView(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,consentLevel: null == consentLevel ? _self.consentLevel : consentLevel // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,scope: freezed == scope ? _self._scope : scope // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,incentive: freezed == incentive ? _self._incentive : incentive // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,snapshotAtBooking: null == snapshotAtBooking ? _self.snapshotAtBooking : snapshotAtBooking // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
