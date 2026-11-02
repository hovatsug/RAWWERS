// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdraw_marketing_consent_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WithdrawMarketingConsentRequest {

/// consentIds
@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_) List<String>? get consentIds;/// all
@JsonKey(name: WithdrawMarketingConsentRequest.allKey_) bool get all;
/// Create a copy of WithdrawMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WithdrawMarketingConsentRequestCopyWith<WithdrawMarketingConsentRequest> get copyWith => _$WithdrawMarketingConsentRequestCopyWithImpl<WithdrawMarketingConsentRequest>(this as WithdrawMarketingConsentRequest, _$identity);

  /// Serializes this WithdrawMarketingConsentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WithdrawMarketingConsentRequest&&const DeepCollectionEquality().equals(other.consentIds, consentIds)&&(identical(other.all, all) || other.all == all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(consentIds),all);

@override
String toString() {
  return 'WithdrawMarketingConsentRequest(consentIds: $consentIds, all: $all)';
}


}

/// @nodoc
abstract mixin class $WithdrawMarketingConsentRequestCopyWith<$Res>  {
  factory $WithdrawMarketingConsentRequestCopyWith(WithdrawMarketingConsentRequest value, $Res Function(WithdrawMarketingConsentRequest) _then) = _$WithdrawMarketingConsentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_) List<String>? consentIds,@JsonKey(name: WithdrawMarketingConsentRequest.allKey_) bool all
});




}
/// @nodoc
class _$WithdrawMarketingConsentRequestCopyWithImpl<$Res>
    implements $WithdrawMarketingConsentRequestCopyWith<$Res> {
  _$WithdrawMarketingConsentRequestCopyWithImpl(this._self, this._then);

  final WithdrawMarketingConsentRequest _self;
  final $Res Function(WithdrawMarketingConsentRequest) _then;

/// Create a copy of WithdrawMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? consentIds = freezed,Object? all = null,}) {
  return _then(_self.copyWith(
consentIds: freezed == consentIds ? _self.consentIds : consentIds // ignore: cast_nullable_to_non_nullable
as List<String>?,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WithdrawMarketingConsentRequest].
extension WithdrawMarketingConsentRequestPatterns on WithdrawMarketingConsentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WithdrawMarketingConsentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WithdrawMarketingConsentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WithdrawMarketingConsentRequest value)  $default,){
final _that = this;
switch (_that) {
case _WithdrawMarketingConsentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WithdrawMarketingConsentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _WithdrawMarketingConsentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_)  List<String>? consentIds, @JsonKey(name: WithdrawMarketingConsentRequest.allKey_)  bool all)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WithdrawMarketingConsentRequest() when $default != null:
return $default(_that.consentIds,_that.all);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_)  List<String>? consentIds, @JsonKey(name: WithdrawMarketingConsentRequest.allKey_)  bool all)  $default,) {final _that = this;
switch (_that) {
case _WithdrawMarketingConsentRequest():
return $default(_that.consentIds,_that.all);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_)  List<String>? consentIds, @JsonKey(name: WithdrawMarketingConsentRequest.allKey_)  bool all)?  $default,) {final _that = this;
switch (_that) {
case _WithdrawMarketingConsentRequest() when $default != null:
return $default(_that.consentIds,_that.all);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _WithdrawMarketingConsentRequest extends WithdrawMarketingConsentRequest {
  const _WithdrawMarketingConsentRequest({@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_) final  List<String>? consentIds, @JsonKey(name: WithdrawMarketingConsentRequest.allKey_) this.all = false}): _consentIds = consentIds,super._();
  factory _WithdrawMarketingConsentRequest.fromJson(Map<String, dynamic> json) => _$WithdrawMarketingConsentRequestFromJson(json);

/// consentIds
 final  List<String>? _consentIds;
/// consentIds
@override@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_) List<String>? get consentIds {
  final value = _consentIds;
  if (value == null) return null;
  if (_consentIds is EqualUnmodifiableListView) return _consentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// all
@override@JsonKey(name: WithdrawMarketingConsentRequest.allKey_) final  bool all;

/// Create a copy of WithdrawMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WithdrawMarketingConsentRequestCopyWith<_WithdrawMarketingConsentRequest> get copyWith => __$WithdrawMarketingConsentRequestCopyWithImpl<_WithdrawMarketingConsentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WithdrawMarketingConsentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WithdrawMarketingConsentRequest&&const DeepCollectionEquality().equals(other._consentIds, _consentIds)&&(identical(other.all, all) || other.all == all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_consentIds),all);

@override
String toString() {
  return 'WithdrawMarketingConsentRequest(consentIds: $consentIds, all: $all)';
}


}

/// @nodoc
abstract mixin class _$WithdrawMarketingConsentRequestCopyWith<$Res> implements $WithdrawMarketingConsentRequestCopyWith<$Res> {
  factory _$WithdrawMarketingConsentRequestCopyWith(_WithdrawMarketingConsentRequest value, $Res Function(_WithdrawMarketingConsentRequest) _then) = __$WithdrawMarketingConsentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_) List<String>? consentIds,@JsonKey(name: WithdrawMarketingConsentRequest.allKey_) bool all
});




}
/// @nodoc
class __$WithdrawMarketingConsentRequestCopyWithImpl<$Res>
    implements _$WithdrawMarketingConsentRequestCopyWith<$Res> {
  __$WithdrawMarketingConsentRequestCopyWithImpl(this._self, this._then);

  final _WithdrawMarketingConsentRequest _self;
  final $Res Function(_WithdrawMarketingConsentRequest) _then;

/// Create a copy of WithdrawMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? consentIds = freezed,Object? all = null,}) {
  return _then(_WithdrawMarketingConsentRequest(
consentIds: freezed == consentIds ? _self._consentIds : consentIds // ignore: cast_nullable_to_non_nullable
as List<String>?,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
