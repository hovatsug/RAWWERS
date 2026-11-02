// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grant_marketing_consent_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GrantMarketingConsentRequest {

/// mediaAssetIds
@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds;/// termMonths
@JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_) int get termMonths;/// peopleConfirmed
@JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_) bool get peopleConfirmed;
/// Create a copy of GrantMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrantMarketingConsentRequestCopyWith<GrantMarketingConsentRequest> get copyWith => _$GrantMarketingConsentRequestCopyWithImpl<GrantMarketingConsentRequest>(this as GrantMarketingConsentRequest, _$identity);

  /// Serializes this GrantMarketingConsentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrantMarketingConsentRequest&&const DeepCollectionEquality().equals(other.mediaAssetIds, mediaAssetIds)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.peopleConfirmed, peopleConfirmed) || other.peopleConfirmed == peopleConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mediaAssetIds),termMonths,peopleConfirmed);

@override
String toString() {
  return 'GrantMarketingConsentRequest(mediaAssetIds: $mediaAssetIds, termMonths: $termMonths, peopleConfirmed: $peopleConfirmed)';
}


}

/// @nodoc
abstract mixin class $GrantMarketingConsentRequestCopyWith<$Res>  {
  factory $GrantMarketingConsentRequestCopyWith(GrantMarketingConsentRequest value, $Res Function(GrantMarketingConsentRequest) _then) = _$GrantMarketingConsentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_) List<String> mediaAssetIds,@JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_) int termMonths,@JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_) bool peopleConfirmed
});




}
/// @nodoc
class _$GrantMarketingConsentRequestCopyWithImpl<$Res>
    implements $GrantMarketingConsentRequestCopyWith<$Res> {
  _$GrantMarketingConsentRequestCopyWithImpl(this._self, this._then);

  final GrantMarketingConsentRequest _self;
  final $Res Function(GrantMarketingConsentRequest) _then;

/// Create a copy of GrantMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetIds = null,Object? termMonths = null,Object? peopleConfirmed = null,}) {
  return _then(_self.copyWith(
mediaAssetIds: null == mediaAssetIds ? _self.mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,peopleConfirmed: null == peopleConfirmed ? _self.peopleConfirmed : peopleConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GrantMarketingConsentRequest].
extension GrantMarketingConsentRequestPatterns on GrantMarketingConsentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrantMarketingConsentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrantMarketingConsentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrantMarketingConsentRequest value)  $default,){
final _that = this;
switch (_that) {
case _GrantMarketingConsentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrantMarketingConsentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _GrantMarketingConsentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_)  int termMonths, @JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_)  bool peopleConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrantMarketingConsentRequest() when $default != null:
return $default(_that.mediaAssetIds,_that.termMonths,_that.peopleConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_)  int termMonths, @JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_)  bool peopleConfirmed)  $default,) {final _that = this;
switch (_that) {
case _GrantMarketingConsentRequest():
return $default(_that.mediaAssetIds,_that.termMonths,_that.peopleConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_)  int termMonths, @JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_)  bool peopleConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _GrantMarketingConsentRequest() when $default != null:
return $default(_that.mediaAssetIds,_that.termMonths,_that.peopleConfirmed);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GrantMarketingConsentRequest extends GrantMarketingConsentRequest {
  const _GrantMarketingConsentRequest({@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_) required final  List<String> mediaAssetIds, @JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_) this.termMonths = 12, @JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_) this.peopleConfirmed = false}): _mediaAssetIds = mediaAssetIds,super._();
  factory _GrantMarketingConsentRequest.fromJson(Map<String, dynamic> json) => _$GrantMarketingConsentRequestFromJson(json);

/// mediaAssetIds
 final  List<String> _mediaAssetIds;
/// mediaAssetIds
@override@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds {
  if (_mediaAssetIds is EqualUnmodifiableListView) return _mediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaAssetIds);
}

/// termMonths
@override@JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_) final  int termMonths;
/// peopleConfirmed
@override@JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_) final  bool peopleConfirmed;

/// Create a copy of GrantMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrantMarketingConsentRequestCopyWith<_GrantMarketingConsentRequest> get copyWith => __$GrantMarketingConsentRequestCopyWithImpl<_GrantMarketingConsentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GrantMarketingConsentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrantMarketingConsentRequest&&const DeepCollectionEquality().equals(other._mediaAssetIds, _mediaAssetIds)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.peopleConfirmed, peopleConfirmed) || other.peopleConfirmed == peopleConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaAssetIds),termMonths,peopleConfirmed);

@override
String toString() {
  return 'GrantMarketingConsentRequest(mediaAssetIds: $mediaAssetIds, termMonths: $termMonths, peopleConfirmed: $peopleConfirmed)';
}


}

/// @nodoc
abstract mixin class _$GrantMarketingConsentRequestCopyWith<$Res> implements $GrantMarketingConsentRequestCopyWith<$Res> {
  factory _$GrantMarketingConsentRequestCopyWith(_GrantMarketingConsentRequest value, $Res Function(_GrantMarketingConsentRequest) _then) = __$GrantMarketingConsentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_) List<String> mediaAssetIds,@JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_) int termMonths,@JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_) bool peopleConfirmed
});




}
/// @nodoc
class __$GrantMarketingConsentRequestCopyWithImpl<$Res>
    implements _$GrantMarketingConsentRequestCopyWith<$Res> {
  __$GrantMarketingConsentRequestCopyWithImpl(this._self, this._then);

  final _GrantMarketingConsentRequest _self;
  final $Res Function(_GrantMarketingConsentRequest) _then;

/// Create a copy of GrantMarketingConsentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetIds = null,Object? termMonths = null,Object? peopleConfirmed = null,}) {
  return _then(_GrantMarketingConsentRequest(
mediaAssetIds: null == mediaAssetIds ? _self._mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,peopleConfirmed: null == peopleConfirmed ? _self.peopleConfirmed : peopleConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
