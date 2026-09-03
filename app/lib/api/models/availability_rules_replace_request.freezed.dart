// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_rules_replace_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityRulesReplaceRequest {

/// rules
@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_) List<AvailabilityRuleItem>? get rules;
/// Create a copy of AvailabilityRulesReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityRulesReplaceRequestCopyWith<AvailabilityRulesReplaceRequest> get copyWith => _$AvailabilityRulesReplaceRequestCopyWithImpl<AvailabilityRulesReplaceRequest>(this as AvailabilityRulesReplaceRequest, _$identity);

  /// Serializes this AvailabilityRulesReplaceRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityRulesReplaceRequest&&const DeepCollectionEquality().equals(other.rules, rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rules));

@override
String toString() {
  return 'AvailabilityRulesReplaceRequest(rules: $rules)';
}


}

/// @nodoc
abstract mixin class $AvailabilityRulesReplaceRequestCopyWith<$Res>  {
  factory $AvailabilityRulesReplaceRequestCopyWith(AvailabilityRulesReplaceRequest value, $Res Function(AvailabilityRulesReplaceRequest) _then) = _$AvailabilityRulesReplaceRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_) List<AvailabilityRuleItem>? rules
});




}
/// @nodoc
class _$AvailabilityRulesReplaceRequestCopyWithImpl<$Res>
    implements $AvailabilityRulesReplaceRequestCopyWith<$Res> {
  _$AvailabilityRulesReplaceRequestCopyWithImpl(this._self, this._then);

  final AvailabilityRulesReplaceRequest _self;
  final $Res Function(AvailabilityRulesReplaceRequest) _then;

/// Create a copy of AvailabilityRulesReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rules = freezed,}) {
  return _then(_self.copyWith(
rules: freezed == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityRulesReplaceRequest].
extension AvailabilityRulesReplaceRequestPatterns on AvailabilityRulesReplaceRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityRulesReplaceRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityRulesReplaceRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityRulesReplaceRequest value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRulesReplaceRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityRulesReplaceRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRulesReplaceRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_)  List<AvailabilityRuleItem>? rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityRulesReplaceRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_)  List<AvailabilityRuleItem>? rules)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRulesReplaceRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_)  List<AvailabilityRuleItem>? rules)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRulesReplaceRequest() when $default != null:
return $default(_that.rules);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityRulesReplaceRequest extends AvailabilityRulesReplaceRequest {
  const _AvailabilityRulesReplaceRequest({@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_) final  List<AvailabilityRuleItem>? rules}): _rules = rules,super._();
  factory _AvailabilityRulesReplaceRequest.fromJson(Map<String, dynamic> json) => _$AvailabilityRulesReplaceRequestFromJson(json);

/// rules
 final  List<AvailabilityRuleItem>? _rules;
/// rules
@override@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_) List<AvailabilityRuleItem>? get rules {
  final value = _rules;
  if (value == null) return null;
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of AvailabilityRulesReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityRulesReplaceRequestCopyWith<_AvailabilityRulesReplaceRequest> get copyWith => __$AvailabilityRulesReplaceRequestCopyWithImpl<_AvailabilityRulesReplaceRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityRulesReplaceRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityRulesReplaceRequest&&const DeepCollectionEquality().equals(other._rules, _rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rules));

@override
String toString() {
  return 'AvailabilityRulesReplaceRequest(rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityRulesReplaceRequestCopyWith<$Res> implements $AvailabilityRulesReplaceRequestCopyWith<$Res> {
  factory _$AvailabilityRulesReplaceRequestCopyWith(_AvailabilityRulesReplaceRequest value, $Res Function(_AvailabilityRulesReplaceRequest) _then) = __$AvailabilityRulesReplaceRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_) List<AvailabilityRuleItem>? rules
});




}
/// @nodoc
class __$AvailabilityRulesReplaceRequestCopyWithImpl<$Res>
    implements _$AvailabilityRulesReplaceRequestCopyWith<$Res> {
  __$AvailabilityRulesReplaceRequestCopyWithImpl(this._self, this._then);

  final _AvailabilityRulesReplaceRequest _self;
  final $Res Function(_AvailabilityRulesReplaceRequest) _then;

/// Create a copy of AvailabilityRulesReplaceRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rules = freezed,}) {
  return _then(_AvailabilityRulesReplaceRequest(
rules: freezed == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleItem>?,
  ));
}


}

// dart format on
