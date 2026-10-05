// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gear_floor_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GearFloorView {

/// meetsFloor
@JsonKey(name: GearFloorView.meetsFloorKey_) bool get meetsFloor;/// hasFullFrameBody
@JsonKey(name: GearFloorView.hasFullFrameBodyKey_) bool get hasFullFrameBody;/// hasQualifyingLens
@JsonKey(name: GearFloorView.hasQualifyingLensKey_) bool get hasQualifyingLens;/// hasLighting
@JsonKey(name: GearFloorView.hasLightingKey_) bool get hasLighting;/// lightingRequired
@JsonKey(name: GearFloorView.lightingRequiredKey_) bool get lightingRequired;/// lightingIsDeclared
@JsonKey(name: GearFloorView.lightingIsDeclaredKey_) bool get lightingIsDeclared;/// awaitingReview
@JsonKey(name: GearFloorView.awaitingReviewKey_) int get awaitingReview;/// missing
@JsonKey(name: GearFloorView.missingKey_) List<String>? get missing;
/// Create a copy of GearFloorView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GearFloorViewCopyWith<GearFloorView> get copyWith => _$GearFloorViewCopyWithImpl<GearFloorView>(this as GearFloorView, _$identity);

  /// Serializes this GearFloorView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GearFloorView&&(identical(other.meetsFloor, meetsFloor) || other.meetsFloor == meetsFloor)&&(identical(other.hasFullFrameBody, hasFullFrameBody) || other.hasFullFrameBody == hasFullFrameBody)&&(identical(other.hasQualifyingLens, hasQualifyingLens) || other.hasQualifyingLens == hasQualifyingLens)&&(identical(other.hasLighting, hasLighting) || other.hasLighting == hasLighting)&&(identical(other.lightingRequired, lightingRequired) || other.lightingRequired == lightingRequired)&&(identical(other.lightingIsDeclared, lightingIsDeclared) || other.lightingIsDeclared == lightingIsDeclared)&&(identical(other.awaitingReview, awaitingReview) || other.awaitingReview == awaitingReview)&&const DeepCollectionEquality().equals(other.missing, missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meetsFloor,hasFullFrameBody,hasQualifyingLens,hasLighting,lightingRequired,lightingIsDeclared,awaitingReview,const DeepCollectionEquality().hash(missing));

@override
String toString() {
  return 'GearFloorView(meetsFloor: $meetsFloor, hasFullFrameBody: $hasFullFrameBody, hasQualifyingLens: $hasQualifyingLens, hasLighting: $hasLighting, lightingRequired: $lightingRequired, lightingIsDeclared: $lightingIsDeclared, awaitingReview: $awaitingReview, missing: $missing)';
}


}

/// @nodoc
abstract mixin class $GearFloorViewCopyWith<$Res>  {
  factory $GearFloorViewCopyWith(GearFloorView value, $Res Function(GearFloorView) _then) = _$GearFloorViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GearFloorView.meetsFloorKey_) bool meetsFloor,@JsonKey(name: GearFloorView.hasFullFrameBodyKey_) bool hasFullFrameBody,@JsonKey(name: GearFloorView.hasQualifyingLensKey_) bool hasQualifyingLens,@JsonKey(name: GearFloorView.hasLightingKey_) bool hasLighting,@JsonKey(name: GearFloorView.lightingRequiredKey_) bool lightingRequired,@JsonKey(name: GearFloorView.lightingIsDeclaredKey_) bool lightingIsDeclared,@JsonKey(name: GearFloorView.awaitingReviewKey_) int awaitingReview,@JsonKey(name: GearFloorView.missingKey_) List<String>? missing
});




}
/// @nodoc
class _$GearFloorViewCopyWithImpl<$Res>
    implements $GearFloorViewCopyWith<$Res> {
  _$GearFloorViewCopyWithImpl(this._self, this._then);

  final GearFloorView _self;
  final $Res Function(GearFloorView) _then;

/// Create a copy of GearFloorView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meetsFloor = null,Object? hasFullFrameBody = null,Object? hasQualifyingLens = null,Object? hasLighting = null,Object? lightingRequired = null,Object? lightingIsDeclared = null,Object? awaitingReview = null,Object? missing = freezed,}) {
  return _then(_self.copyWith(
meetsFloor: null == meetsFloor ? _self.meetsFloor : meetsFloor // ignore: cast_nullable_to_non_nullable
as bool,hasFullFrameBody: null == hasFullFrameBody ? _self.hasFullFrameBody : hasFullFrameBody // ignore: cast_nullable_to_non_nullable
as bool,hasQualifyingLens: null == hasQualifyingLens ? _self.hasQualifyingLens : hasQualifyingLens // ignore: cast_nullable_to_non_nullable
as bool,hasLighting: null == hasLighting ? _self.hasLighting : hasLighting // ignore: cast_nullable_to_non_nullable
as bool,lightingRequired: null == lightingRequired ? _self.lightingRequired : lightingRequired // ignore: cast_nullable_to_non_nullable
as bool,lightingIsDeclared: null == lightingIsDeclared ? _self.lightingIsDeclared : lightingIsDeclared // ignore: cast_nullable_to_non_nullable
as bool,awaitingReview: null == awaitingReview ? _self.awaitingReview : awaitingReview // ignore: cast_nullable_to_non_nullable
as int,missing: freezed == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GearFloorView].
extension GearFloorViewPatterns on GearFloorView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GearFloorView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GearFloorView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GearFloorView value)  $default,){
final _that = this;
switch (_that) {
case _GearFloorView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GearFloorView value)?  $default,){
final _that = this;
switch (_that) {
case _GearFloorView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GearFloorView.meetsFloorKey_)  bool meetsFloor, @JsonKey(name: GearFloorView.hasFullFrameBodyKey_)  bool hasFullFrameBody, @JsonKey(name: GearFloorView.hasQualifyingLensKey_)  bool hasQualifyingLens, @JsonKey(name: GearFloorView.hasLightingKey_)  bool hasLighting, @JsonKey(name: GearFloorView.lightingRequiredKey_)  bool lightingRequired, @JsonKey(name: GearFloorView.lightingIsDeclaredKey_)  bool lightingIsDeclared, @JsonKey(name: GearFloorView.awaitingReviewKey_)  int awaitingReview, @JsonKey(name: GearFloorView.missingKey_)  List<String>? missing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GearFloorView() when $default != null:
return $default(_that.meetsFloor,_that.hasFullFrameBody,_that.hasQualifyingLens,_that.hasLighting,_that.lightingRequired,_that.lightingIsDeclared,_that.awaitingReview,_that.missing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GearFloorView.meetsFloorKey_)  bool meetsFloor, @JsonKey(name: GearFloorView.hasFullFrameBodyKey_)  bool hasFullFrameBody, @JsonKey(name: GearFloorView.hasQualifyingLensKey_)  bool hasQualifyingLens, @JsonKey(name: GearFloorView.hasLightingKey_)  bool hasLighting, @JsonKey(name: GearFloorView.lightingRequiredKey_)  bool lightingRequired, @JsonKey(name: GearFloorView.lightingIsDeclaredKey_)  bool lightingIsDeclared, @JsonKey(name: GearFloorView.awaitingReviewKey_)  int awaitingReview, @JsonKey(name: GearFloorView.missingKey_)  List<String>? missing)  $default,) {final _that = this;
switch (_that) {
case _GearFloorView():
return $default(_that.meetsFloor,_that.hasFullFrameBody,_that.hasQualifyingLens,_that.hasLighting,_that.lightingRequired,_that.lightingIsDeclared,_that.awaitingReview,_that.missing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GearFloorView.meetsFloorKey_)  bool meetsFloor, @JsonKey(name: GearFloorView.hasFullFrameBodyKey_)  bool hasFullFrameBody, @JsonKey(name: GearFloorView.hasQualifyingLensKey_)  bool hasQualifyingLens, @JsonKey(name: GearFloorView.hasLightingKey_)  bool hasLighting, @JsonKey(name: GearFloorView.lightingRequiredKey_)  bool lightingRequired, @JsonKey(name: GearFloorView.lightingIsDeclaredKey_)  bool lightingIsDeclared, @JsonKey(name: GearFloorView.awaitingReviewKey_)  int awaitingReview, @JsonKey(name: GearFloorView.missingKey_)  List<String>? missing)?  $default,) {final _that = this;
switch (_that) {
case _GearFloorView() when $default != null:
return $default(_that.meetsFloor,_that.hasFullFrameBody,_that.hasQualifyingLens,_that.hasLighting,_that.lightingRequired,_that.lightingIsDeclared,_that.awaitingReview,_that.missing);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GearFloorView extends GearFloorView {
  const _GearFloorView({@JsonKey(name: GearFloorView.meetsFloorKey_) required this.meetsFloor, @JsonKey(name: GearFloorView.hasFullFrameBodyKey_) required this.hasFullFrameBody, @JsonKey(name: GearFloorView.hasQualifyingLensKey_) required this.hasQualifyingLens, @JsonKey(name: GearFloorView.hasLightingKey_) required this.hasLighting, @JsonKey(name: GearFloorView.lightingRequiredKey_) required this.lightingRequired, @JsonKey(name: GearFloorView.lightingIsDeclaredKey_) required this.lightingIsDeclared, @JsonKey(name: GearFloorView.awaitingReviewKey_) required this.awaitingReview, @JsonKey(name: GearFloorView.missingKey_) final  List<String>? missing}): _missing = missing,super._();
  factory _GearFloorView.fromJson(Map<String, dynamic> json) => _$GearFloorViewFromJson(json);

/// meetsFloor
@override@JsonKey(name: GearFloorView.meetsFloorKey_) final  bool meetsFloor;
/// hasFullFrameBody
@override@JsonKey(name: GearFloorView.hasFullFrameBodyKey_) final  bool hasFullFrameBody;
/// hasQualifyingLens
@override@JsonKey(name: GearFloorView.hasQualifyingLensKey_) final  bool hasQualifyingLens;
/// hasLighting
@override@JsonKey(name: GearFloorView.hasLightingKey_) final  bool hasLighting;
/// lightingRequired
@override@JsonKey(name: GearFloorView.lightingRequiredKey_) final  bool lightingRequired;
/// lightingIsDeclared
@override@JsonKey(name: GearFloorView.lightingIsDeclaredKey_) final  bool lightingIsDeclared;
/// awaitingReview
@override@JsonKey(name: GearFloorView.awaitingReviewKey_) final  int awaitingReview;
/// missing
 final  List<String>? _missing;
/// missing
@override@JsonKey(name: GearFloorView.missingKey_) List<String>? get missing {
  final value = _missing;
  if (value == null) return null;
  if (_missing is EqualUnmodifiableListView) return _missing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GearFloorView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GearFloorViewCopyWith<_GearFloorView> get copyWith => __$GearFloorViewCopyWithImpl<_GearFloorView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GearFloorViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GearFloorView&&(identical(other.meetsFloor, meetsFloor) || other.meetsFloor == meetsFloor)&&(identical(other.hasFullFrameBody, hasFullFrameBody) || other.hasFullFrameBody == hasFullFrameBody)&&(identical(other.hasQualifyingLens, hasQualifyingLens) || other.hasQualifyingLens == hasQualifyingLens)&&(identical(other.hasLighting, hasLighting) || other.hasLighting == hasLighting)&&(identical(other.lightingRequired, lightingRequired) || other.lightingRequired == lightingRequired)&&(identical(other.lightingIsDeclared, lightingIsDeclared) || other.lightingIsDeclared == lightingIsDeclared)&&(identical(other.awaitingReview, awaitingReview) || other.awaitingReview == awaitingReview)&&const DeepCollectionEquality().equals(other._missing, _missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meetsFloor,hasFullFrameBody,hasQualifyingLens,hasLighting,lightingRequired,lightingIsDeclared,awaitingReview,const DeepCollectionEquality().hash(_missing));

@override
String toString() {
  return 'GearFloorView(meetsFloor: $meetsFloor, hasFullFrameBody: $hasFullFrameBody, hasQualifyingLens: $hasQualifyingLens, hasLighting: $hasLighting, lightingRequired: $lightingRequired, lightingIsDeclared: $lightingIsDeclared, awaitingReview: $awaitingReview, missing: $missing)';
}


}

/// @nodoc
abstract mixin class _$GearFloorViewCopyWith<$Res> implements $GearFloorViewCopyWith<$Res> {
  factory _$GearFloorViewCopyWith(_GearFloorView value, $Res Function(_GearFloorView) _then) = __$GearFloorViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GearFloorView.meetsFloorKey_) bool meetsFloor,@JsonKey(name: GearFloorView.hasFullFrameBodyKey_) bool hasFullFrameBody,@JsonKey(name: GearFloorView.hasQualifyingLensKey_) bool hasQualifyingLens,@JsonKey(name: GearFloorView.hasLightingKey_) bool hasLighting,@JsonKey(name: GearFloorView.lightingRequiredKey_) bool lightingRequired,@JsonKey(name: GearFloorView.lightingIsDeclaredKey_) bool lightingIsDeclared,@JsonKey(name: GearFloorView.awaitingReviewKey_) int awaitingReview,@JsonKey(name: GearFloorView.missingKey_) List<String>? missing
});




}
/// @nodoc
class __$GearFloorViewCopyWithImpl<$Res>
    implements _$GearFloorViewCopyWith<$Res> {
  __$GearFloorViewCopyWithImpl(this._self, this._then);

  final _GearFloorView _self;
  final $Res Function(_GearFloorView) _then;

/// Create a copy of GearFloorView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meetsFloor = null,Object? hasFullFrameBody = null,Object? hasQualifyingLens = null,Object? hasLighting = null,Object? lightingRequired = null,Object? lightingIsDeclared = null,Object? awaitingReview = null,Object? missing = freezed,}) {
  return _then(_GearFloorView(
meetsFloor: null == meetsFloor ? _self.meetsFloor : meetsFloor // ignore: cast_nullable_to_non_nullable
as bool,hasFullFrameBody: null == hasFullFrameBody ? _self.hasFullFrameBody : hasFullFrameBody // ignore: cast_nullable_to_non_nullable
as bool,hasQualifyingLens: null == hasQualifyingLens ? _self.hasQualifyingLens : hasQualifyingLens // ignore: cast_nullable_to_non_nullable
as bool,hasLighting: null == hasLighting ? _self.hasLighting : hasLighting // ignore: cast_nullable_to_non_nullable
as bool,lightingRequired: null == lightingRequired ? _self.lightingRequired : lightingRequired // ignore: cast_nullable_to_non_nullable
as bool,lightingIsDeclared: null == lightingIsDeclared ? _self.lightingIsDeclared : lightingIsDeclared // ignore: cast_nullable_to_non_nullable
as bool,awaitingReview: null == awaitingReview ? _self.awaitingReview : awaitingReview // ignore: cast_nullable_to_non_nullable
as int,missing: freezed == missing ? _self._missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
