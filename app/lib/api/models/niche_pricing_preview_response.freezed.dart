// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'niche_pricing_preview_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NichePricingPreviewResponse {

/// proUserId
@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_) String get proUserId;/// nicheId
@JsonKey(name: NichePricingPreviewResponse.nicheIdKey_) String get nicheId;/// packages
@JsonKey(name: NichePricingPreviewResponse.packagesKey_) List<PackagePricingPreview> get packages;
/// Create a copy of NichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NichePricingPreviewResponseCopyWith<NichePricingPreviewResponse> get copyWith => _$NichePricingPreviewResponseCopyWithImpl<NichePricingPreviewResponse>(this as NichePricingPreviewResponse, _$identity);

  /// Serializes this NichePricingPreviewResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NichePricingPreviewResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&const DeepCollectionEquality().equals(other.packages, packages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,nicheId,const DeepCollectionEquality().hash(packages));

@override
String toString() {
  return 'NichePricingPreviewResponse(proUserId: $proUserId, nicheId: $nicheId, packages: $packages)';
}


}

/// @nodoc
abstract mixin class $NichePricingPreviewResponseCopyWith<$Res>  {
  factory $NichePricingPreviewResponseCopyWith(NichePricingPreviewResponse value, $Res Function(NichePricingPreviewResponse) _then) = _$NichePricingPreviewResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_) String proUserId,@JsonKey(name: NichePricingPreviewResponse.nicheIdKey_) String nicheId,@JsonKey(name: NichePricingPreviewResponse.packagesKey_) List<PackagePricingPreview> packages
});




}
/// @nodoc
class _$NichePricingPreviewResponseCopyWithImpl<$Res>
    implements $NichePricingPreviewResponseCopyWith<$Res> {
  _$NichePricingPreviewResponseCopyWithImpl(this._self, this._then);

  final NichePricingPreviewResponse _self;
  final $Res Function(NichePricingPreviewResponse) _then;

/// Create a copy of NichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? nicheId = null,Object? packages = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<PackagePricingPreview>,
  ));
}

}


/// Adds pattern-matching-related methods to [NichePricingPreviewResponse].
extension NichePricingPreviewResponsePatterns on NichePricingPreviewResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NichePricingPreviewResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NichePricingPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NichePricingPreviewResponse value)  $default,){
final _that = this;
switch (_that) {
case _NichePricingPreviewResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NichePricingPreviewResponse value)?  $default,){
final _that = this;
switch (_that) {
case _NichePricingPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_)  String proUserId, @JsonKey(name: NichePricingPreviewResponse.nicheIdKey_)  String nicheId, @JsonKey(name: NichePricingPreviewResponse.packagesKey_)  List<PackagePricingPreview> packages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NichePricingPreviewResponse() when $default != null:
return $default(_that.proUserId,_that.nicheId,_that.packages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_)  String proUserId, @JsonKey(name: NichePricingPreviewResponse.nicheIdKey_)  String nicheId, @JsonKey(name: NichePricingPreviewResponse.packagesKey_)  List<PackagePricingPreview> packages)  $default,) {final _that = this;
switch (_that) {
case _NichePricingPreviewResponse():
return $default(_that.proUserId,_that.nicheId,_that.packages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_)  String proUserId, @JsonKey(name: NichePricingPreviewResponse.nicheIdKey_)  String nicheId, @JsonKey(name: NichePricingPreviewResponse.packagesKey_)  List<PackagePricingPreview> packages)?  $default,) {final _that = this;
switch (_that) {
case _NichePricingPreviewResponse() when $default != null:
return $default(_that.proUserId,_that.nicheId,_that.packages);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NichePricingPreviewResponse extends NichePricingPreviewResponse {
  const _NichePricingPreviewResponse({@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: NichePricingPreviewResponse.nicheIdKey_) required this.nicheId, @JsonKey(name: NichePricingPreviewResponse.packagesKey_) required final  List<PackagePricingPreview> packages}): _packages = packages,super._();
  factory _NichePricingPreviewResponse.fromJson(Map<String, dynamic> json) => _$NichePricingPreviewResponseFromJson(json);

/// proUserId
@override@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_) final  String proUserId;
/// nicheId
@override@JsonKey(name: NichePricingPreviewResponse.nicheIdKey_) final  String nicheId;
/// packages
 final  List<PackagePricingPreview> _packages;
/// packages
@override@JsonKey(name: NichePricingPreviewResponse.packagesKey_) List<PackagePricingPreview> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}


/// Create a copy of NichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NichePricingPreviewResponseCopyWith<_NichePricingPreviewResponse> get copyWith => __$NichePricingPreviewResponseCopyWithImpl<_NichePricingPreviewResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NichePricingPreviewResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NichePricingPreviewResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&const DeepCollectionEquality().equals(other._packages, _packages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,nicheId,const DeepCollectionEquality().hash(_packages));

@override
String toString() {
  return 'NichePricingPreviewResponse(proUserId: $proUserId, nicheId: $nicheId, packages: $packages)';
}


}

/// @nodoc
abstract mixin class _$NichePricingPreviewResponseCopyWith<$Res> implements $NichePricingPreviewResponseCopyWith<$Res> {
  factory _$NichePricingPreviewResponseCopyWith(_NichePricingPreviewResponse value, $Res Function(_NichePricingPreviewResponse) _then) = __$NichePricingPreviewResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NichePricingPreviewResponse.proUserIdKey_) String proUserId,@JsonKey(name: NichePricingPreviewResponse.nicheIdKey_) String nicheId,@JsonKey(name: NichePricingPreviewResponse.packagesKey_) List<PackagePricingPreview> packages
});




}
/// @nodoc
class __$NichePricingPreviewResponseCopyWithImpl<$Res>
    implements _$NichePricingPreviewResponseCopyWith<$Res> {
  __$NichePricingPreviewResponseCopyWithImpl(this._self, this._then);

  final _NichePricingPreviewResponse _self;
  final $Res Function(_NichePricingPreviewResponse) _then;

/// Create a copy of NichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? nicheId = null,Object? packages = null,}) {
  return _then(_NichePricingPreviewResponse(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<PackagePricingPreview>,
  ));
}


}

// dart format on
