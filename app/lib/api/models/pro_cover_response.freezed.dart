// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_cover_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProCoverResponse {

/// coverMediaAssetId
@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_) String get coverMediaAssetId;/// changed
@JsonKey(name: ProCoverResponse.changedKey_) bool get changed;
/// Create a copy of ProCoverResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProCoverResponseCopyWith<ProCoverResponse> get copyWith => _$ProCoverResponseCopyWithImpl<ProCoverResponse>(this as ProCoverResponse, _$identity);

  /// Serializes this ProCoverResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProCoverResponse&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.changed, changed) || other.changed == changed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coverMediaAssetId,changed);

@override
String toString() {
  return 'ProCoverResponse(coverMediaAssetId: $coverMediaAssetId, changed: $changed)';
}


}

/// @nodoc
abstract mixin class $ProCoverResponseCopyWith<$Res>  {
  factory $ProCoverResponseCopyWith(ProCoverResponse value, $Res Function(ProCoverResponse) _then) = _$ProCoverResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_) String coverMediaAssetId,@JsonKey(name: ProCoverResponse.changedKey_) bool changed
});




}
/// @nodoc
class _$ProCoverResponseCopyWithImpl<$Res>
    implements $ProCoverResponseCopyWith<$Res> {
  _$ProCoverResponseCopyWithImpl(this._self, this._then);

  final ProCoverResponse _self;
  final $Res Function(ProCoverResponse) _then;

/// Create a copy of ProCoverResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coverMediaAssetId = null,Object? changed = null,}) {
  return _then(_self.copyWith(
coverMediaAssetId: null == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String,changed: null == changed ? _self.changed : changed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProCoverResponse].
extension ProCoverResponsePatterns on ProCoverResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProCoverResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProCoverResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProCoverResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProCoverResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProCoverResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProCoverResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_)  String coverMediaAssetId, @JsonKey(name: ProCoverResponse.changedKey_)  bool changed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProCoverResponse() when $default != null:
return $default(_that.coverMediaAssetId,_that.changed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_)  String coverMediaAssetId, @JsonKey(name: ProCoverResponse.changedKey_)  bool changed)  $default,) {final _that = this;
switch (_that) {
case _ProCoverResponse():
return $default(_that.coverMediaAssetId,_that.changed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_)  String coverMediaAssetId, @JsonKey(name: ProCoverResponse.changedKey_)  bool changed)?  $default,) {final _that = this;
switch (_that) {
case _ProCoverResponse() when $default != null:
return $default(_that.coverMediaAssetId,_that.changed);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProCoverResponse extends ProCoverResponse {
  const _ProCoverResponse({@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_) required this.coverMediaAssetId, @JsonKey(name: ProCoverResponse.changedKey_) required this.changed}): super._();
  factory _ProCoverResponse.fromJson(Map<String, dynamic> json) => _$ProCoverResponseFromJson(json);

/// coverMediaAssetId
@override@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_) final  String coverMediaAssetId;
/// changed
@override@JsonKey(name: ProCoverResponse.changedKey_) final  bool changed;

/// Create a copy of ProCoverResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProCoverResponseCopyWith<_ProCoverResponse> get copyWith => __$ProCoverResponseCopyWithImpl<_ProCoverResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProCoverResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProCoverResponse&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.changed, changed) || other.changed == changed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coverMediaAssetId,changed);

@override
String toString() {
  return 'ProCoverResponse(coverMediaAssetId: $coverMediaAssetId, changed: $changed)';
}


}

/// @nodoc
abstract mixin class _$ProCoverResponseCopyWith<$Res> implements $ProCoverResponseCopyWith<$Res> {
  factory _$ProCoverResponseCopyWith(_ProCoverResponse value, $Res Function(_ProCoverResponse) _then) = __$ProCoverResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_) String coverMediaAssetId,@JsonKey(name: ProCoverResponse.changedKey_) bool changed
});




}
/// @nodoc
class __$ProCoverResponseCopyWithImpl<$Res>
    implements _$ProCoverResponseCopyWith<$Res> {
  __$ProCoverResponseCopyWithImpl(this._self, this._then);

  final _ProCoverResponse _self;
  final $Res Function(_ProCoverResponse) _then;

/// Create a copy of ProCoverResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coverMediaAssetId = null,Object? changed = null,}) {
  return _then(_ProCoverResponse(
coverMediaAssetId: null == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String,changed: null == changed ? _self.changed : changed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
