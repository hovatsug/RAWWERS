// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_availability_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicAvailabilityResponse {

/// proUserId
@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_) String get proUserId;/// rules
@JsonKey(name: PublicAvailabilityResponse.rulesKey_) List<PublicAvailabilityRuleView> get rules;/// blackouts
@JsonKey(name: PublicAvailabilityResponse.blackoutsKey_) List<BlackoutView> get blackouts;
/// Create a copy of PublicAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicAvailabilityResponseCopyWith<PublicAvailabilityResponse> get copyWith => _$PublicAvailabilityResponseCopyWithImpl<PublicAvailabilityResponse>(this as PublicAvailabilityResponse, _$identity);

  /// Serializes this PublicAvailabilityResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicAvailabilityResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.blackouts, blackouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(blackouts));

@override
String toString() {
  return 'PublicAvailabilityResponse(proUserId: $proUserId, rules: $rules, blackouts: $blackouts)';
}


}

/// @nodoc
abstract mixin class $PublicAvailabilityResponseCopyWith<$Res>  {
  factory $PublicAvailabilityResponseCopyWith(PublicAvailabilityResponse value, $Res Function(PublicAvailabilityResponse) _then) = _$PublicAvailabilityResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_) String proUserId,@JsonKey(name: PublicAvailabilityResponse.rulesKey_) List<PublicAvailabilityRuleView> rules,@JsonKey(name: PublicAvailabilityResponse.blackoutsKey_) List<BlackoutView> blackouts
});




}
/// @nodoc
class _$PublicAvailabilityResponseCopyWithImpl<$Res>
    implements $PublicAvailabilityResponseCopyWith<$Res> {
  _$PublicAvailabilityResponseCopyWithImpl(this._self, this._then);

  final PublicAvailabilityResponse _self;
  final $Res Function(PublicAvailabilityResponse) _then;

/// Create a copy of PublicAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? rules = null,Object? blackouts = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<PublicAvailabilityRuleView>,blackouts: null == blackouts ? _self.blackouts : blackouts // ignore: cast_nullable_to_non_nullable
as List<BlackoutView>,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicAvailabilityResponse].
extension PublicAvailabilityResponsePatterns on PublicAvailabilityResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicAvailabilityResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicAvailabilityResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicAvailabilityResponse value)  $default,){
final _that = this;
switch (_that) {
case _PublicAvailabilityResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicAvailabilityResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PublicAvailabilityResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_)  String proUserId, @JsonKey(name: PublicAvailabilityResponse.rulesKey_)  List<PublicAvailabilityRuleView> rules, @JsonKey(name: PublicAvailabilityResponse.blackoutsKey_)  List<BlackoutView> blackouts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicAvailabilityResponse() when $default != null:
return $default(_that.proUserId,_that.rules,_that.blackouts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_)  String proUserId, @JsonKey(name: PublicAvailabilityResponse.rulesKey_)  List<PublicAvailabilityRuleView> rules, @JsonKey(name: PublicAvailabilityResponse.blackoutsKey_)  List<BlackoutView> blackouts)  $default,) {final _that = this;
switch (_that) {
case _PublicAvailabilityResponse():
return $default(_that.proUserId,_that.rules,_that.blackouts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_)  String proUserId, @JsonKey(name: PublicAvailabilityResponse.rulesKey_)  List<PublicAvailabilityRuleView> rules, @JsonKey(name: PublicAvailabilityResponse.blackoutsKey_)  List<BlackoutView> blackouts)?  $default,) {final _that = this;
switch (_that) {
case _PublicAvailabilityResponse() when $default != null:
return $default(_that.proUserId,_that.rules,_that.blackouts);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PublicAvailabilityResponse extends PublicAvailabilityResponse {
  const _PublicAvailabilityResponse({@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: PublicAvailabilityResponse.rulesKey_) required final  List<PublicAvailabilityRuleView> rules, @JsonKey(name: PublicAvailabilityResponse.blackoutsKey_) required final  List<BlackoutView> blackouts}): _rules = rules,_blackouts = blackouts,super._();
  factory _PublicAvailabilityResponse.fromJson(Map<String, dynamic> json) => _$PublicAvailabilityResponseFromJson(json);

/// proUserId
@override@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_) final  String proUserId;
/// rules
 final  List<PublicAvailabilityRuleView> _rules;
/// rules
@override@JsonKey(name: PublicAvailabilityResponse.rulesKey_) List<PublicAvailabilityRuleView> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

/// blackouts
 final  List<BlackoutView> _blackouts;
/// blackouts
@override@JsonKey(name: PublicAvailabilityResponse.blackoutsKey_) List<BlackoutView> get blackouts {
  if (_blackouts is EqualUnmodifiableListView) return _blackouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blackouts);
}


/// Create a copy of PublicAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicAvailabilityResponseCopyWith<_PublicAvailabilityResponse> get copyWith => __$PublicAvailabilityResponseCopyWithImpl<_PublicAvailabilityResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicAvailabilityResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicAvailabilityResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._blackouts, _blackouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_blackouts));

@override
String toString() {
  return 'PublicAvailabilityResponse(proUserId: $proUserId, rules: $rules, blackouts: $blackouts)';
}


}

/// @nodoc
abstract mixin class _$PublicAvailabilityResponseCopyWith<$Res> implements $PublicAvailabilityResponseCopyWith<$Res> {
  factory _$PublicAvailabilityResponseCopyWith(_PublicAvailabilityResponse value, $Res Function(_PublicAvailabilityResponse) _then) = __$PublicAvailabilityResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PublicAvailabilityResponse.proUserIdKey_) String proUserId,@JsonKey(name: PublicAvailabilityResponse.rulesKey_) List<PublicAvailabilityRuleView> rules,@JsonKey(name: PublicAvailabilityResponse.blackoutsKey_) List<BlackoutView> blackouts
});




}
/// @nodoc
class __$PublicAvailabilityResponseCopyWithImpl<$Res>
    implements _$PublicAvailabilityResponseCopyWith<$Res> {
  __$PublicAvailabilityResponseCopyWithImpl(this._self, this._then);

  final _PublicAvailabilityResponse _self;
  final $Res Function(_PublicAvailabilityResponse) _then;

/// Create a copy of PublicAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? rules = null,Object? blackouts = null,}) {
  return _then(_PublicAvailabilityResponse(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<PublicAvailabilityRuleView>,blackouts: null == blackouts ? _self._blackouts : blackouts // ignore: cast_nullable_to_non_nullable
as List<BlackoutView>,
  ));
}


}

// dart format on
