// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_my_niches_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateMyNichesResponse {

/// primaryNicheSlug
@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_) String? get primaryNicheSlug;/// niches
@JsonKey(name: UpdateMyNichesResponse.nichesKey_) List<ProNicheView>? get niches;
/// Create a copy of UpdateMyNichesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMyNichesResponseCopyWith<UpdateMyNichesResponse> get copyWith => _$UpdateMyNichesResponseCopyWithImpl<UpdateMyNichesResponse>(this as UpdateMyNichesResponse, _$identity);

  /// Serializes this UpdateMyNichesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMyNichesResponse&&(identical(other.primaryNicheSlug, primaryNicheSlug) || other.primaryNicheSlug == primaryNicheSlug)&&const DeepCollectionEquality().equals(other.niches, niches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryNicheSlug,const DeepCollectionEquality().hash(niches));

@override
String toString() {
  return 'UpdateMyNichesResponse(primaryNicheSlug: $primaryNicheSlug, niches: $niches)';
}


}

/// @nodoc
abstract mixin class $UpdateMyNichesResponseCopyWith<$Res>  {
  factory $UpdateMyNichesResponseCopyWith(UpdateMyNichesResponse value, $Res Function(UpdateMyNichesResponse) _then) = _$UpdateMyNichesResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_) String? primaryNicheSlug,@JsonKey(name: UpdateMyNichesResponse.nichesKey_) List<ProNicheView>? niches
});




}
/// @nodoc
class _$UpdateMyNichesResponseCopyWithImpl<$Res>
    implements $UpdateMyNichesResponseCopyWith<$Res> {
  _$UpdateMyNichesResponseCopyWithImpl(this._self, this._then);

  final UpdateMyNichesResponse _self;
  final $Res Function(UpdateMyNichesResponse) _then;

/// Create a copy of UpdateMyNichesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryNicheSlug = freezed,Object? niches = freezed,}) {
  return _then(_self.copyWith(
primaryNicheSlug: freezed == primaryNicheSlug ? _self.primaryNicheSlug : primaryNicheSlug // ignore: cast_nullable_to_non_nullable
as String?,niches: freezed == niches ? _self.niches : niches // ignore: cast_nullable_to_non_nullable
as List<ProNicheView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMyNichesResponse].
extension UpdateMyNichesResponsePatterns on UpdateMyNichesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMyNichesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMyNichesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMyNichesResponse value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMyNichesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMyNichesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMyNichesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_)  String? primaryNicheSlug, @JsonKey(name: UpdateMyNichesResponse.nichesKey_)  List<ProNicheView>? niches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMyNichesResponse() when $default != null:
return $default(_that.primaryNicheSlug,_that.niches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_)  String? primaryNicheSlug, @JsonKey(name: UpdateMyNichesResponse.nichesKey_)  List<ProNicheView>? niches)  $default,) {final _that = this;
switch (_that) {
case _UpdateMyNichesResponse():
return $default(_that.primaryNicheSlug,_that.niches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_)  String? primaryNicheSlug, @JsonKey(name: UpdateMyNichesResponse.nichesKey_)  List<ProNicheView>? niches)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMyNichesResponse() when $default != null:
return $default(_that.primaryNicheSlug,_that.niches);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpdateMyNichesResponse extends UpdateMyNichesResponse {
  const _UpdateMyNichesResponse({@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_) this.primaryNicheSlug, @JsonKey(name: UpdateMyNichesResponse.nichesKey_) final  List<ProNicheView>? niches}): _niches = niches,super._();
  factory _UpdateMyNichesResponse.fromJson(Map<String, dynamic> json) => _$UpdateMyNichesResponseFromJson(json);

/// primaryNicheSlug
@override@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_) final  String? primaryNicheSlug;
/// niches
 final  List<ProNicheView>? _niches;
/// niches
@override@JsonKey(name: UpdateMyNichesResponse.nichesKey_) List<ProNicheView>? get niches {
  final value = _niches;
  if (value == null) return null;
  if (_niches is EqualUnmodifiableListView) return _niches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateMyNichesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMyNichesResponseCopyWith<_UpdateMyNichesResponse> get copyWith => __$UpdateMyNichesResponseCopyWithImpl<_UpdateMyNichesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMyNichesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMyNichesResponse&&(identical(other.primaryNicheSlug, primaryNicheSlug) || other.primaryNicheSlug == primaryNicheSlug)&&const DeepCollectionEquality().equals(other._niches, _niches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryNicheSlug,const DeepCollectionEquality().hash(_niches));

@override
String toString() {
  return 'UpdateMyNichesResponse(primaryNicheSlug: $primaryNicheSlug, niches: $niches)';
}


}

/// @nodoc
abstract mixin class _$UpdateMyNichesResponseCopyWith<$Res> implements $UpdateMyNichesResponseCopyWith<$Res> {
  factory _$UpdateMyNichesResponseCopyWith(_UpdateMyNichesResponse value, $Res Function(_UpdateMyNichesResponse) _then) = __$UpdateMyNichesResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_) String? primaryNicheSlug,@JsonKey(name: UpdateMyNichesResponse.nichesKey_) List<ProNicheView>? niches
});




}
/// @nodoc
class __$UpdateMyNichesResponseCopyWithImpl<$Res>
    implements _$UpdateMyNichesResponseCopyWith<$Res> {
  __$UpdateMyNichesResponseCopyWithImpl(this._self, this._then);

  final _UpdateMyNichesResponse _self;
  final $Res Function(_UpdateMyNichesResponse) _then;

/// Create a copy of UpdateMyNichesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryNicheSlug = freezed,Object? niches = freezed,}) {
  return _then(_UpdateMyNichesResponse(
primaryNicheSlug: freezed == primaryNicheSlug ? _self.primaryNicheSlug : primaryNicheSlug // ignore: cast_nullable_to_non_nullable
as String?,niches: freezed == niches ? _self._niches : niches // ignore: cast_nullable_to_non_nullable
as List<ProNicheView>?,
  ));
}


}

// dart format on
