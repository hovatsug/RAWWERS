// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolio_niche_tags_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PortfolioNicheTagsRequest {

/// nicheSlugs
@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_) List<String>? get nicheSlugs;
/// Create a copy of PortfolioNicheTagsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioNicheTagsRequestCopyWith<PortfolioNicheTagsRequest> get copyWith => _$PortfolioNicheTagsRequestCopyWithImpl<PortfolioNicheTagsRequest>(this as PortfolioNicheTagsRequest, _$identity);

  /// Serializes this PortfolioNicheTagsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfolioNicheTagsRequest&&const DeepCollectionEquality().equals(other.nicheSlugs, nicheSlugs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(nicheSlugs));

@override
String toString() {
  return 'PortfolioNicheTagsRequest(nicheSlugs: $nicheSlugs)';
}


}

/// @nodoc
abstract mixin class $PortfolioNicheTagsRequestCopyWith<$Res>  {
  factory $PortfolioNicheTagsRequestCopyWith(PortfolioNicheTagsRequest value, $Res Function(PortfolioNicheTagsRequest) _then) = _$PortfolioNicheTagsRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_) List<String>? nicheSlugs
});




}
/// @nodoc
class _$PortfolioNicheTagsRequestCopyWithImpl<$Res>
    implements $PortfolioNicheTagsRequestCopyWith<$Res> {
  _$PortfolioNicheTagsRequestCopyWithImpl(this._self, this._then);

  final PortfolioNicheTagsRequest _self;
  final $Res Function(PortfolioNicheTagsRequest) _then;

/// Create a copy of PortfolioNicheTagsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nicheSlugs = freezed,}) {
  return _then(_self.copyWith(
nicheSlugs: freezed == nicheSlugs ? _self.nicheSlugs : nicheSlugs // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortfolioNicheTagsRequest].
extension PortfolioNicheTagsRequestPatterns on PortfolioNicheTagsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfolioNicheTagsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfolioNicheTagsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfolioNicheTagsRequest value)  $default,){
final _that = this;
switch (_that) {
case _PortfolioNicheTagsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfolioNicheTagsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PortfolioNicheTagsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_)  List<String>? nicheSlugs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfolioNicheTagsRequest() when $default != null:
return $default(_that.nicheSlugs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_)  List<String>? nicheSlugs)  $default,) {final _that = this;
switch (_that) {
case _PortfolioNicheTagsRequest():
return $default(_that.nicheSlugs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_)  List<String>? nicheSlugs)?  $default,) {final _that = this;
switch (_that) {
case _PortfolioNicheTagsRequest() when $default != null:
return $default(_that.nicheSlugs);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PortfolioNicheTagsRequest extends PortfolioNicheTagsRequest {
  const _PortfolioNicheTagsRequest({@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_) final  List<String>? nicheSlugs}): _nicheSlugs = nicheSlugs,super._();
  factory _PortfolioNicheTagsRequest.fromJson(Map<String, dynamic> json) => _$PortfolioNicheTagsRequestFromJson(json);

/// nicheSlugs
 final  List<String>? _nicheSlugs;
/// nicheSlugs
@override@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_) List<String>? get nicheSlugs {
  final value = _nicheSlugs;
  if (value == null) return null;
  if (_nicheSlugs is EqualUnmodifiableListView) return _nicheSlugs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PortfolioNicheTagsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioNicheTagsRequestCopyWith<_PortfolioNicheTagsRequest> get copyWith => __$PortfolioNicheTagsRequestCopyWithImpl<_PortfolioNicheTagsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortfolioNicheTagsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfolioNicheTagsRequest&&const DeepCollectionEquality().equals(other._nicheSlugs, _nicheSlugs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_nicheSlugs));

@override
String toString() {
  return 'PortfolioNicheTagsRequest(nicheSlugs: $nicheSlugs)';
}


}

/// @nodoc
abstract mixin class _$PortfolioNicheTagsRequestCopyWith<$Res> implements $PortfolioNicheTagsRequestCopyWith<$Res> {
  factory _$PortfolioNicheTagsRequestCopyWith(_PortfolioNicheTagsRequest value, $Res Function(_PortfolioNicheTagsRequest) _then) = __$PortfolioNicheTagsRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_) List<String>? nicheSlugs
});




}
/// @nodoc
class __$PortfolioNicheTagsRequestCopyWithImpl<$Res>
    implements _$PortfolioNicheTagsRequestCopyWith<$Res> {
  __$PortfolioNicheTagsRequestCopyWithImpl(this._self, this._then);

  final _PortfolioNicheTagsRequest _self;
  final $Res Function(_PortfolioNicheTagsRequest) _then;

/// Create a copy of PortfolioNicheTagsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nicheSlugs = freezed,}) {
  return _then(_PortfolioNicheTagsRequest(
nicheSlugs: freezed == nicheSlugs ? _self._nicheSlugs : nicheSlugs // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
