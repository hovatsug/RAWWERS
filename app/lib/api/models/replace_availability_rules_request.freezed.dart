// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replace_availability_rules_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReplaceAvailabilityRulesRequest {

/// rules
@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_) List<AvailabilityRuleInput> get rules;
/// Create a copy of ReplaceAvailabilityRulesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplaceAvailabilityRulesRequestCopyWith<ReplaceAvailabilityRulesRequest> get copyWith => _$ReplaceAvailabilityRulesRequestCopyWithImpl<ReplaceAvailabilityRulesRequest>(this as ReplaceAvailabilityRulesRequest, _$identity);

  /// Serializes this ReplaceAvailabilityRulesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplaceAvailabilityRulesRequest&&const DeepCollectionEquality().equals(other.rules, rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rules));

@override
String toString() {
  return 'ReplaceAvailabilityRulesRequest(rules: $rules)';
}


}

/// @nodoc
abstract mixin class $ReplaceAvailabilityRulesRequestCopyWith<$Res>  {
  factory $ReplaceAvailabilityRulesRequestCopyWith(ReplaceAvailabilityRulesRequest value, $Res Function(ReplaceAvailabilityRulesRequest) _then) = _$ReplaceAvailabilityRulesRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_) List<AvailabilityRuleInput> rules
});




}
/// @nodoc
class _$ReplaceAvailabilityRulesRequestCopyWithImpl<$Res>
    implements $ReplaceAvailabilityRulesRequestCopyWith<$Res> {
  _$ReplaceAvailabilityRulesRequestCopyWithImpl(this._self, this._then);

  final ReplaceAvailabilityRulesRequest _self;
  final $Res Function(ReplaceAvailabilityRulesRequest) _then;

/// Create a copy of ReplaceAvailabilityRulesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rules = null,}) {
  return _then(_self.copyWith(
rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplaceAvailabilityRulesRequest].
extension ReplaceAvailabilityRulesRequestPatterns on ReplaceAvailabilityRulesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplaceAvailabilityRulesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplaceAvailabilityRulesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplaceAvailabilityRulesRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReplaceAvailabilityRulesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplaceAvailabilityRulesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReplaceAvailabilityRulesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_)  List<AvailabilityRuleInput> rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplaceAvailabilityRulesRequest() when $default != null:
return $default(_that.rules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_)  List<AvailabilityRuleInput> rules)  $default,) {final _that = this;
switch (_that) {
case _ReplaceAvailabilityRulesRequest():
return $default(_that.rules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_)  List<AvailabilityRuleInput> rules)?  $default,) {final _that = this;
switch (_that) {
case _ReplaceAvailabilityRulesRequest() when $default != null:
return $default(_that.rules);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ReplaceAvailabilityRulesRequest extends ReplaceAvailabilityRulesRequest {
  const _ReplaceAvailabilityRulesRequest({@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_) required final  List<AvailabilityRuleInput> rules}): _rules = rules,super._();
  factory _ReplaceAvailabilityRulesRequest.fromJson(Map<String, dynamic> json) => _$ReplaceAvailabilityRulesRequestFromJson(json);

/// rules
 final  List<AvailabilityRuleInput> _rules;
/// rules
@override@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_) List<AvailabilityRuleInput> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}


/// Create a copy of ReplaceAvailabilityRulesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplaceAvailabilityRulesRequestCopyWith<_ReplaceAvailabilityRulesRequest> get copyWith => __$ReplaceAvailabilityRulesRequestCopyWithImpl<_ReplaceAvailabilityRulesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplaceAvailabilityRulesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplaceAvailabilityRulesRequest&&const DeepCollectionEquality().equals(other._rules, _rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rules));

@override
String toString() {
  return 'ReplaceAvailabilityRulesRequest(rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$ReplaceAvailabilityRulesRequestCopyWith<$Res> implements $ReplaceAvailabilityRulesRequestCopyWith<$Res> {
  factory _$ReplaceAvailabilityRulesRequestCopyWith(_ReplaceAvailabilityRulesRequest value, $Res Function(_ReplaceAvailabilityRulesRequest) _then) = __$ReplaceAvailabilityRulesRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_) List<AvailabilityRuleInput> rules
});




}
/// @nodoc
class __$ReplaceAvailabilityRulesRequestCopyWithImpl<$Res>
    implements _$ReplaceAvailabilityRulesRequestCopyWith<$Res> {
  __$ReplaceAvailabilityRulesRequestCopyWithImpl(this._self, this._then);

  final _ReplaceAvailabilityRulesRequest _self;
  final $Res Function(_ReplaceAvailabilityRulesRequest) _then;

/// Create a copy of ReplaceAvailabilityRulesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rules = null,}) {
  return _then(_ReplaceAvailabilityRulesRequest(
rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleInput>,
  ));
}


}

// dart format on
