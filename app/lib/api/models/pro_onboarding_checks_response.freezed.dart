// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_onboarding_checks_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProOnboardingChecksResponse {

/// status
@JsonKey(name: ProOnboardingChecksResponse.statusKey_) ProOnboardingStatus get status;/// checks
@JsonKey(name: ProOnboardingChecksResponse.checksKey_) Map<String, dynamic>? get checks;/// missing
@JsonKey(name: ProOnboardingChecksResponse.missingKey_) List<String>? get missing;
/// Create a copy of ProOnboardingChecksResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProOnboardingChecksResponseCopyWith<ProOnboardingChecksResponse> get copyWith => _$ProOnboardingChecksResponseCopyWithImpl<ProOnboardingChecksResponse>(this as ProOnboardingChecksResponse, _$identity);

  /// Serializes this ProOnboardingChecksResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProOnboardingChecksResponse&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.checks, checks)&&const DeepCollectionEquality().equals(other.missing, missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(checks),const DeepCollectionEquality().hash(missing));

@override
String toString() {
  return 'ProOnboardingChecksResponse(status: $status, checks: $checks, missing: $missing)';
}


}

/// @nodoc
abstract mixin class $ProOnboardingChecksResponseCopyWith<$Res>  {
  factory $ProOnboardingChecksResponseCopyWith(ProOnboardingChecksResponse value, $Res Function(ProOnboardingChecksResponse) _then) = _$ProOnboardingChecksResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProOnboardingChecksResponse.statusKey_) ProOnboardingStatus status,@JsonKey(name: ProOnboardingChecksResponse.checksKey_) Map<String, dynamic>? checks,@JsonKey(name: ProOnboardingChecksResponse.missingKey_) List<String>? missing
});




}
/// @nodoc
class _$ProOnboardingChecksResponseCopyWithImpl<$Res>
    implements $ProOnboardingChecksResponseCopyWith<$Res> {
  _$ProOnboardingChecksResponseCopyWithImpl(this._self, this._then);

  final ProOnboardingChecksResponse _self;
  final $Res Function(ProOnboardingChecksResponse) _then;

/// Create a copy of ProOnboardingChecksResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? checks = freezed,Object? missing = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProOnboardingStatus,checks: freezed == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,missing: freezed == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProOnboardingChecksResponse].
extension ProOnboardingChecksResponsePatterns on ProOnboardingChecksResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProOnboardingChecksResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProOnboardingChecksResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProOnboardingChecksResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProOnboardingChecksResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProOnboardingChecksResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProOnboardingChecksResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProOnboardingChecksResponse.statusKey_)  ProOnboardingStatus status, @JsonKey(name: ProOnboardingChecksResponse.checksKey_)  Map<String, dynamic>? checks, @JsonKey(name: ProOnboardingChecksResponse.missingKey_)  List<String>? missing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProOnboardingChecksResponse() when $default != null:
return $default(_that.status,_that.checks,_that.missing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProOnboardingChecksResponse.statusKey_)  ProOnboardingStatus status, @JsonKey(name: ProOnboardingChecksResponse.checksKey_)  Map<String, dynamic>? checks, @JsonKey(name: ProOnboardingChecksResponse.missingKey_)  List<String>? missing)  $default,) {final _that = this;
switch (_that) {
case _ProOnboardingChecksResponse():
return $default(_that.status,_that.checks,_that.missing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProOnboardingChecksResponse.statusKey_)  ProOnboardingStatus status, @JsonKey(name: ProOnboardingChecksResponse.checksKey_)  Map<String, dynamic>? checks, @JsonKey(name: ProOnboardingChecksResponse.missingKey_)  List<String>? missing)?  $default,) {final _that = this;
switch (_that) {
case _ProOnboardingChecksResponse() when $default != null:
return $default(_that.status,_that.checks,_that.missing);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProOnboardingChecksResponse extends ProOnboardingChecksResponse {
  const _ProOnboardingChecksResponse({@JsonKey(name: ProOnboardingChecksResponse.statusKey_) required this.status, @JsonKey(name: ProOnboardingChecksResponse.checksKey_) final  Map<String, dynamic>? checks, @JsonKey(name: ProOnboardingChecksResponse.missingKey_) final  List<String>? missing}): _checks = checks,_missing = missing,super._();
  factory _ProOnboardingChecksResponse.fromJson(Map<String, dynamic> json) => _$ProOnboardingChecksResponseFromJson(json);

/// status
@override@JsonKey(name: ProOnboardingChecksResponse.statusKey_) final  ProOnboardingStatus status;
/// checks
 final  Map<String, dynamic>? _checks;
/// checks
@override@JsonKey(name: ProOnboardingChecksResponse.checksKey_) Map<String, dynamic>? get checks {
  final value = _checks;
  if (value == null) return null;
  if (_checks is EqualUnmodifiableMapView) return _checks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// missing
 final  List<String>? _missing;
/// missing
@override@JsonKey(name: ProOnboardingChecksResponse.missingKey_) List<String>? get missing {
  final value = _missing;
  if (value == null) return null;
  if (_missing is EqualUnmodifiableListView) return _missing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProOnboardingChecksResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProOnboardingChecksResponseCopyWith<_ProOnboardingChecksResponse> get copyWith => __$ProOnboardingChecksResponseCopyWithImpl<_ProOnboardingChecksResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProOnboardingChecksResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProOnboardingChecksResponse&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._checks, _checks)&&const DeepCollectionEquality().equals(other._missing, _missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_checks),const DeepCollectionEquality().hash(_missing));

@override
String toString() {
  return 'ProOnboardingChecksResponse(status: $status, checks: $checks, missing: $missing)';
}


}

/// @nodoc
abstract mixin class _$ProOnboardingChecksResponseCopyWith<$Res> implements $ProOnboardingChecksResponseCopyWith<$Res> {
  factory _$ProOnboardingChecksResponseCopyWith(_ProOnboardingChecksResponse value, $Res Function(_ProOnboardingChecksResponse) _then) = __$ProOnboardingChecksResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProOnboardingChecksResponse.statusKey_) ProOnboardingStatus status,@JsonKey(name: ProOnboardingChecksResponse.checksKey_) Map<String, dynamic>? checks,@JsonKey(name: ProOnboardingChecksResponse.missingKey_) List<String>? missing
});




}
/// @nodoc
class __$ProOnboardingChecksResponseCopyWithImpl<$Res>
    implements _$ProOnboardingChecksResponseCopyWith<$Res> {
  __$ProOnboardingChecksResponseCopyWithImpl(this._self, this._then);

  final _ProOnboardingChecksResponse _self;
  final $Res Function(_ProOnboardingChecksResponse) _then;

/// Create a copy of ProOnboardingChecksResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? checks = freezed,Object? missing = freezed,}) {
  return _then(_ProOnboardingChecksResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProOnboardingStatus,checks: freezed == checks ? _self._checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,missing: freezed == missing ? _self._missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
