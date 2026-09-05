// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_my_niches_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateMyNichesRequest {

/// primaryNicheSlug
@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_) String? get primaryNicheSlug;/// niches
@JsonKey(name: UpdateMyNichesRequest.nichesKey_) List<ProNicheInput>? get niches;
/// Create a copy of UpdateMyNichesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMyNichesRequestCopyWith<UpdateMyNichesRequest> get copyWith => _$UpdateMyNichesRequestCopyWithImpl<UpdateMyNichesRequest>(this as UpdateMyNichesRequest, _$identity);

  /// Serializes this UpdateMyNichesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMyNichesRequest&&(identical(other.primaryNicheSlug, primaryNicheSlug) || other.primaryNicheSlug == primaryNicheSlug)&&const DeepCollectionEquality().equals(other.niches, niches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryNicheSlug,const DeepCollectionEquality().hash(niches));

@override
String toString() {
  return 'UpdateMyNichesRequest(primaryNicheSlug: $primaryNicheSlug, niches: $niches)';
}


}

/// @nodoc
abstract mixin class $UpdateMyNichesRequestCopyWith<$Res>  {
  factory $UpdateMyNichesRequestCopyWith(UpdateMyNichesRequest value, $Res Function(UpdateMyNichesRequest) _then) = _$UpdateMyNichesRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_) String? primaryNicheSlug,@JsonKey(name: UpdateMyNichesRequest.nichesKey_) List<ProNicheInput>? niches
});




}
/// @nodoc
class _$UpdateMyNichesRequestCopyWithImpl<$Res>
    implements $UpdateMyNichesRequestCopyWith<$Res> {
  _$UpdateMyNichesRequestCopyWithImpl(this._self, this._then);

  final UpdateMyNichesRequest _self;
  final $Res Function(UpdateMyNichesRequest) _then;

/// Create a copy of UpdateMyNichesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryNicheSlug = freezed,Object? niches = freezed,}) {
  return _then(_self.copyWith(
primaryNicheSlug: freezed == primaryNicheSlug ? _self.primaryNicheSlug : primaryNicheSlug // ignore: cast_nullable_to_non_nullable
as String?,niches: freezed == niches ? _self.niches : niches // ignore: cast_nullable_to_non_nullable
as List<ProNicheInput>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMyNichesRequest].
extension UpdateMyNichesRequestPatterns on UpdateMyNichesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMyNichesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMyNichesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMyNichesRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMyNichesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMyNichesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMyNichesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_)  String? primaryNicheSlug, @JsonKey(name: UpdateMyNichesRequest.nichesKey_)  List<ProNicheInput>? niches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMyNichesRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_)  String? primaryNicheSlug, @JsonKey(name: UpdateMyNichesRequest.nichesKey_)  List<ProNicheInput>? niches)  $default,) {final _that = this;
switch (_that) {
case _UpdateMyNichesRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_)  String? primaryNicheSlug, @JsonKey(name: UpdateMyNichesRequest.nichesKey_)  List<ProNicheInput>? niches)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMyNichesRequest() when $default != null:
return $default(_that.primaryNicheSlug,_that.niches);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpdateMyNichesRequest extends UpdateMyNichesRequest {
  const _UpdateMyNichesRequest({@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_) this.primaryNicheSlug, @JsonKey(name: UpdateMyNichesRequest.nichesKey_) final  List<ProNicheInput>? niches}): _niches = niches,super._();
  factory _UpdateMyNichesRequest.fromJson(Map<String, dynamic> json) => _$UpdateMyNichesRequestFromJson(json);

/// primaryNicheSlug
@override@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_) final  String? primaryNicheSlug;
/// niches
 final  List<ProNicheInput>? _niches;
/// niches
@override@JsonKey(name: UpdateMyNichesRequest.nichesKey_) List<ProNicheInput>? get niches {
  final value = _niches;
  if (value == null) return null;
  if (_niches is EqualUnmodifiableListView) return _niches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateMyNichesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMyNichesRequestCopyWith<_UpdateMyNichesRequest> get copyWith => __$UpdateMyNichesRequestCopyWithImpl<_UpdateMyNichesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMyNichesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMyNichesRequest&&(identical(other.primaryNicheSlug, primaryNicheSlug) || other.primaryNicheSlug == primaryNicheSlug)&&const DeepCollectionEquality().equals(other._niches, _niches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryNicheSlug,const DeepCollectionEquality().hash(_niches));

@override
String toString() {
  return 'UpdateMyNichesRequest(primaryNicheSlug: $primaryNicheSlug, niches: $niches)';
}


}

/// @nodoc
abstract mixin class _$UpdateMyNichesRequestCopyWith<$Res> implements $UpdateMyNichesRequestCopyWith<$Res> {
  factory _$UpdateMyNichesRequestCopyWith(_UpdateMyNichesRequest value, $Res Function(_UpdateMyNichesRequest) _then) = __$UpdateMyNichesRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_) String? primaryNicheSlug,@JsonKey(name: UpdateMyNichesRequest.nichesKey_) List<ProNicheInput>? niches
});




}
/// @nodoc
class __$UpdateMyNichesRequestCopyWithImpl<$Res>
    implements _$UpdateMyNichesRequestCopyWith<$Res> {
  __$UpdateMyNichesRequestCopyWithImpl(this._self, this._then);

  final _UpdateMyNichesRequest _self;
  final $Res Function(_UpdateMyNichesRequest) _then;

/// Create a copy of UpdateMyNichesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryNicheSlug = freezed,Object? niches = freezed,}) {
  return _then(_UpdateMyNichesRequest(
primaryNicheSlug: freezed == primaryNicheSlug ? _self.primaryNicheSlug : primaryNicheSlug // ignore: cast_nullable_to_non_nullable
as String?,niches: freezed == niches ? _self._niches : niches // ignore: cast_nullable_to_non_nullable
as List<ProNicheInput>?,
  ));
}


}

// dart format on
