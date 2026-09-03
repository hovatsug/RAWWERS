// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_gig_consent_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateGigConsentRequest {

/// consentLevel
@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_) GigConsentLevel get consentLevel;/// scope
@JsonKey(name: UpdateGigConsentRequest.scopeKey_) Map<String, dynamic>? get scope;/// reason
@JsonKey(name: UpdateGigConsentRequest.reasonKey_) String? get reason;
/// Create a copy of UpdateGigConsentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateGigConsentRequestCopyWith<UpdateGigConsentRequest> get copyWith => _$UpdateGigConsentRequestCopyWithImpl<UpdateGigConsentRequest>(this as UpdateGigConsentRequest, _$identity);

  /// Serializes this UpdateGigConsentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGigConsentRequest&&(identical(other.consentLevel, consentLevel) || other.consentLevel == consentLevel)&&const DeepCollectionEquality().equals(other.scope, scope)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,consentLevel,const DeepCollectionEquality().hash(scope),reason);

@override
String toString() {
  return 'UpdateGigConsentRequest(consentLevel: $consentLevel, scope: $scope, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $UpdateGigConsentRequestCopyWith<$Res>  {
  factory $UpdateGigConsentRequestCopyWith(UpdateGigConsentRequest value, $Res Function(UpdateGigConsentRequest) _then) = _$UpdateGigConsentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_) GigConsentLevel consentLevel,@JsonKey(name: UpdateGigConsentRequest.scopeKey_) Map<String, dynamic>? scope,@JsonKey(name: UpdateGigConsentRequest.reasonKey_) String? reason
});




}
/// @nodoc
class _$UpdateGigConsentRequestCopyWithImpl<$Res>
    implements $UpdateGigConsentRequestCopyWith<$Res> {
  _$UpdateGigConsentRequestCopyWithImpl(this._self, this._then);

  final UpdateGigConsentRequest _self;
  final $Res Function(UpdateGigConsentRequest) _then;

/// Create a copy of UpdateGigConsentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? consentLevel = null,Object? scope = freezed,Object? reason = freezed,}) {
  return _then(_self.copyWith(
consentLevel: null == consentLevel ? _self.consentLevel : consentLevel // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateGigConsentRequest].
extension UpdateGigConsentRequestPatterns on UpdateGigConsentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateGigConsentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateGigConsentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateGigConsentRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateGigConsentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateGigConsentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateGigConsentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_)  GigConsentLevel consentLevel, @JsonKey(name: UpdateGigConsentRequest.scopeKey_)  Map<String, dynamic>? scope, @JsonKey(name: UpdateGigConsentRequest.reasonKey_)  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateGigConsentRequest() when $default != null:
return $default(_that.consentLevel,_that.scope,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_)  GigConsentLevel consentLevel, @JsonKey(name: UpdateGigConsentRequest.scopeKey_)  Map<String, dynamic>? scope, @JsonKey(name: UpdateGigConsentRequest.reasonKey_)  String? reason)  $default,) {final _that = this;
switch (_that) {
case _UpdateGigConsentRequest():
return $default(_that.consentLevel,_that.scope,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_)  GigConsentLevel consentLevel, @JsonKey(name: UpdateGigConsentRequest.scopeKey_)  Map<String, dynamic>? scope, @JsonKey(name: UpdateGigConsentRequest.reasonKey_)  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _UpdateGigConsentRequest() when $default != null:
return $default(_that.consentLevel,_that.scope,_that.reason);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpdateGigConsentRequest extends UpdateGigConsentRequest {
  const _UpdateGigConsentRequest({@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_) required this.consentLevel, @JsonKey(name: UpdateGigConsentRequest.scopeKey_) final  Map<String, dynamic>? scope, @JsonKey(name: UpdateGigConsentRequest.reasonKey_) this.reason}): _scope = scope,super._();
  factory _UpdateGigConsentRequest.fromJson(Map<String, dynamic> json) => _$UpdateGigConsentRequestFromJson(json);

/// consentLevel
@override@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_) final  GigConsentLevel consentLevel;
/// scope
 final  Map<String, dynamic>? _scope;
/// scope
@override@JsonKey(name: UpdateGigConsentRequest.scopeKey_) Map<String, dynamic>? get scope {
  final value = _scope;
  if (value == null) return null;
  if (_scope is EqualUnmodifiableMapView) return _scope;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// reason
@override@JsonKey(name: UpdateGigConsentRequest.reasonKey_) final  String? reason;

/// Create a copy of UpdateGigConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateGigConsentRequestCopyWith<_UpdateGigConsentRequest> get copyWith => __$UpdateGigConsentRequestCopyWithImpl<_UpdateGigConsentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateGigConsentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateGigConsentRequest&&(identical(other.consentLevel, consentLevel) || other.consentLevel == consentLevel)&&const DeepCollectionEquality().equals(other._scope, _scope)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,consentLevel,const DeepCollectionEquality().hash(_scope),reason);

@override
String toString() {
  return 'UpdateGigConsentRequest(consentLevel: $consentLevel, scope: $scope, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$UpdateGigConsentRequestCopyWith<$Res> implements $UpdateGigConsentRequestCopyWith<$Res> {
  factory _$UpdateGigConsentRequestCopyWith(_UpdateGigConsentRequest value, $Res Function(_UpdateGigConsentRequest) _then) = __$UpdateGigConsentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpdateGigConsentRequest.consentLevelKey_) GigConsentLevel consentLevel,@JsonKey(name: UpdateGigConsentRequest.scopeKey_) Map<String, dynamic>? scope,@JsonKey(name: UpdateGigConsentRequest.reasonKey_) String? reason
});




}
/// @nodoc
class __$UpdateGigConsentRequestCopyWithImpl<$Res>
    implements _$UpdateGigConsentRequestCopyWith<$Res> {
  __$UpdateGigConsentRequestCopyWithImpl(this._self, this._then);

  final _UpdateGigConsentRequest _self;
  final $Res Function(_UpdateGigConsentRequest) _then;

/// Create a copy of UpdateGigConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? consentLevel = null,Object? scope = freezed,Object? reason = freezed,}) {
  return _then(_UpdateGigConsentRequest(
consentLevel: null == consentLevel ? _self.consentLevel : consentLevel // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,scope: freezed == scope ? _self._scope : scope // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
