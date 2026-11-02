// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'renew_marketing_consent_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RenewMarketingConsentRequest {

/// consentIds
@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_) List<String> get consentIds;/// termMonths
@JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_) int get termMonths;
/// Create a copy of RenewMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RenewMarketingConsentRequestCopyWith<RenewMarketingConsentRequest> get copyWith => _$RenewMarketingConsentRequestCopyWithImpl<RenewMarketingConsentRequest>(this as RenewMarketingConsentRequest, _$identity);

  /// Serializes this RenewMarketingConsentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RenewMarketingConsentRequest&&const DeepCollectionEquality().equals(other.consentIds, consentIds)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(consentIds),termMonths);

@override
String toString() {
  return 'RenewMarketingConsentRequest(consentIds: $consentIds, termMonths: $termMonths)';
}


}

/// @nodoc
abstract mixin class $RenewMarketingConsentRequestCopyWith<$Res>  {
  factory $RenewMarketingConsentRequestCopyWith(RenewMarketingConsentRequest value, $Res Function(RenewMarketingConsentRequest) _then) = _$RenewMarketingConsentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_) List<String> consentIds,@JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_) int termMonths
});




}
/// @nodoc
class _$RenewMarketingConsentRequestCopyWithImpl<$Res>
    implements $RenewMarketingConsentRequestCopyWith<$Res> {
  _$RenewMarketingConsentRequestCopyWithImpl(this._self, this._then);

  final RenewMarketingConsentRequest _self;
  final $Res Function(RenewMarketingConsentRequest) _then;

/// Create a copy of RenewMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? consentIds = null,Object? termMonths = null,}) {
  return _then(_self.copyWith(
consentIds: null == consentIds ? _self.consentIds : consentIds // ignore: cast_nullable_to_non_nullable
as List<String>,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RenewMarketingConsentRequest].
extension RenewMarketingConsentRequestPatterns on RenewMarketingConsentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RenewMarketingConsentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RenewMarketingConsentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RenewMarketingConsentRequest value)  $default,){
final _that = this;
switch (_that) {
case _RenewMarketingConsentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RenewMarketingConsentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RenewMarketingConsentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_)  List<String> consentIds, @JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_)  int termMonths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RenewMarketingConsentRequest() when $default != null:
return $default(_that.consentIds,_that.termMonths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_)  List<String> consentIds, @JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_)  int termMonths)  $default,) {final _that = this;
switch (_that) {
case _RenewMarketingConsentRequest():
return $default(_that.consentIds,_that.termMonths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_)  List<String> consentIds, @JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_)  int termMonths)?  $default,) {final _that = this;
switch (_that) {
case _RenewMarketingConsentRequest() when $default != null:
return $default(_that.consentIds,_that.termMonths);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _RenewMarketingConsentRequest extends RenewMarketingConsentRequest {
  const _RenewMarketingConsentRequest({@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_) required final  List<String> consentIds, @JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_) this.termMonths = 12}): _consentIds = consentIds,super._();
  factory _RenewMarketingConsentRequest.fromJson(Map<String, dynamic> json) => _$RenewMarketingConsentRequestFromJson(json);

/// consentIds
 final  List<String> _consentIds;
/// consentIds
@override@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_) List<String> get consentIds {
  if (_consentIds is EqualUnmodifiableListView) return _consentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_consentIds);
}

/// termMonths
@override@JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_) final  int termMonths;

/// Create a copy of RenewMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RenewMarketingConsentRequestCopyWith<_RenewMarketingConsentRequest> get copyWith => __$RenewMarketingConsentRequestCopyWithImpl<_RenewMarketingConsentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RenewMarketingConsentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RenewMarketingConsentRequest&&const DeepCollectionEquality().equals(other._consentIds, _consentIds)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_consentIds),termMonths);

@override
String toString() {
  return 'RenewMarketingConsentRequest(consentIds: $consentIds, termMonths: $termMonths)';
}


}

/// @nodoc
abstract mixin class _$RenewMarketingConsentRequestCopyWith<$Res> implements $RenewMarketingConsentRequestCopyWith<$Res> {
  factory _$RenewMarketingConsentRequestCopyWith(_RenewMarketingConsentRequest value, $Res Function(_RenewMarketingConsentRequest) _then) = __$RenewMarketingConsentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_) List<String> consentIds,@JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_) int termMonths
});




}
/// @nodoc
class __$RenewMarketingConsentRequestCopyWithImpl<$Res>
    implements _$RenewMarketingConsentRequestCopyWith<$Res> {
  __$RenewMarketingConsentRequestCopyWithImpl(this._self, this._then);

  final _RenewMarketingConsentRequest _self;
  final $Res Function(_RenewMarketingConsentRequest) _then;

/// Create a copy of RenewMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? consentIds = null,Object? termMonths = null,}) {
  return _then(_RenewMarketingConsentRequest(
consentIds: null == consentIds ? _self._consentIds : consentIds // ignore: cast_nullable_to_non_nullable
as List<String>,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
