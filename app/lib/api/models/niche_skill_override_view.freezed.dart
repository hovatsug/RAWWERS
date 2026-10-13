// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'niche_skill_override_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NicheSkillOverrideView {

/// tier
@JsonKey(name: NicheSkillOverrideView.tierKey_) SkillTier? get tier;/// score
@JsonKey(name: NicheSkillOverrideView.scoreKey_) int? get score;/// verified
@JsonKey(name: NicheSkillOverrideView.verifiedKey_) bool? get verified;/// by
@JsonKey(name: NicheSkillOverrideView.byKey_) String? get by;/// at
@JsonKey(name: NicheSkillOverrideView.atKey_) DateTime? get at;/// reason
@JsonKey(name: NicheSkillOverrideView.reasonKey_) String? get reason;
/// Create a copy of NicheSkillOverrideView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NicheSkillOverrideViewCopyWith<NicheSkillOverrideView> get copyWith => _$NicheSkillOverrideViewCopyWithImpl<NicheSkillOverrideView>(this as NicheSkillOverrideView, _$identity);

  /// Serializes this NicheSkillOverrideView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NicheSkillOverrideView&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.score, score) || other.score == score)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.by, by) || other.by == by)&&(identical(other.at, at) || other.at == at)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,score,verified,by,at,reason);

@override
String toString() {
  return 'NicheSkillOverrideView(tier: $tier, score: $score, verified: $verified, by: $by, at: $at, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $NicheSkillOverrideViewCopyWith<$Res>  {
  factory $NicheSkillOverrideViewCopyWith(NicheSkillOverrideView value, $Res Function(NicheSkillOverrideView) _then) = _$NicheSkillOverrideViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NicheSkillOverrideView.tierKey_) SkillTier? tier,@JsonKey(name: NicheSkillOverrideView.scoreKey_) int? score,@JsonKey(name: NicheSkillOverrideView.verifiedKey_) bool? verified,@JsonKey(name: NicheSkillOverrideView.byKey_) String? by,@JsonKey(name: NicheSkillOverrideView.atKey_) DateTime? at,@JsonKey(name: NicheSkillOverrideView.reasonKey_) String? reason
});




}
/// @nodoc
class _$NicheSkillOverrideViewCopyWithImpl<$Res>
    implements $NicheSkillOverrideViewCopyWith<$Res> {
  _$NicheSkillOverrideViewCopyWithImpl(this._self, this._then);

  final NicheSkillOverrideView _self;
  final $Res Function(NicheSkillOverrideView) _then;

/// Create a copy of NicheSkillOverrideView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = freezed,Object? score = freezed,Object? verified = freezed,Object? by = freezed,Object? at = freezed,Object? reason = freezed,}) {
  return _then(_self.copyWith(
tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SkillTier?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,by: freezed == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String?,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NicheSkillOverrideView].
extension NicheSkillOverrideViewPatterns on NicheSkillOverrideView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NicheSkillOverrideView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NicheSkillOverrideView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NicheSkillOverrideView value)  $default,){
final _that = this;
switch (_that) {
case _NicheSkillOverrideView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NicheSkillOverrideView value)?  $default,){
final _that = this;
switch (_that) {
case _NicheSkillOverrideView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NicheSkillOverrideView.tierKey_)  SkillTier? tier, @JsonKey(name: NicheSkillOverrideView.scoreKey_)  int? score, @JsonKey(name: NicheSkillOverrideView.verifiedKey_)  bool? verified, @JsonKey(name: NicheSkillOverrideView.byKey_)  String? by, @JsonKey(name: NicheSkillOverrideView.atKey_)  DateTime? at, @JsonKey(name: NicheSkillOverrideView.reasonKey_)  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NicheSkillOverrideView() when $default != null:
return $default(_that.tier,_that.score,_that.verified,_that.by,_that.at,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NicheSkillOverrideView.tierKey_)  SkillTier? tier, @JsonKey(name: NicheSkillOverrideView.scoreKey_)  int? score, @JsonKey(name: NicheSkillOverrideView.verifiedKey_)  bool? verified, @JsonKey(name: NicheSkillOverrideView.byKey_)  String? by, @JsonKey(name: NicheSkillOverrideView.atKey_)  DateTime? at, @JsonKey(name: NicheSkillOverrideView.reasonKey_)  String? reason)  $default,) {final _that = this;
switch (_that) {
case _NicheSkillOverrideView():
return $default(_that.tier,_that.score,_that.verified,_that.by,_that.at,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NicheSkillOverrideView.tierKey_)  SkillTier? tier, @JsonKey(name: NicheSkillOverrideView.scoreKey_)  int? score, @JsonKey(name: NicheSkillOverrideView.verifiedKey_)  bool? verified, @JsonKey(name: NicheSkillOverrideView.byKey_)  String? by, @JsonKey(name: NicheSkillOverrideView.atKey_)  DateTime? at, @JsonKey(name: NicheSkillOverrideView.reasonKey_)  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _NicheSkillOverrideView() when $default != null:
return $default(_that.tier,_that.score,_that.verified,_that.by,_that.at,_that.reason);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NicheSkillOverrideView extends NicheSkillOverrideView {
  const _NicheSkillOverrideView({@JsonKey(name: NicheSkillOverrideView.tierKey_) this.tier, @JsonKey(name: NicheSkillOverrideView.scoreKey_) this.score, @JsonKey(name: NicheSkillOverrideView.verifiedKey_) this.verified, @JsonKey(name: NicheSkillOverrideView.byKey_) this.by, @JsonKey(name: NicheSkillOverrideView.atKey_) this.at, @JsonKey(name: NicheSkillOverrideView.reasonKey_) this.reason}): super._();
  factory _NicheSkillOverrideView.fromJson(Map<String, dynamic> json) => _$NicheSkillOverrideViewFromJson(json);

/// tier
@override@JsonKey(name: NicheSkillOverrideView.tierKey_) final  SkillTier? tier;
/// score
@override@JsonKey(name: NicheSkillOverrideView.scoreKey_) final  int? score;
/// verified
@override@JsonKey(name: NicheSkillOverrideView.verifiedKey_) final  bool? verified;
/// by
@override@JsonKey(name: NicheSkillOverrideView.byKey_) final  String? by;
/// at
@override@JsonKey(name: NicheSkillOverrideView.atKey_) final  DateTime? at;
/// reason
@override@JsonKey(name: NicheSkillOverrideView.reasonKey_) final  String? reason;

/// Create a copy of NicheSkillOverrideView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NicheSkillOverrideViewCopyWith<_NicheSkillOverrideView> get copyWith => __$NicheSkillOverrideViewCopyWithImpl<_NicheSkillOverrideView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NicheSkillOverrideViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NicheSkillOverrideView&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.score, score) || other.score == score)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.by, by) || other.by == by)&&(identical(other.at, at) || other.at == at)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,score,verified,by,at,reason);

@override
String toString() {
  return 'NicheSkillOverrideView(tier: $tier, score: $score, verified: $verified, by: $by, at: $at, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$NicheSkillOverrideViewCopyWith<$Res> implements $NicheSkillOverrideViewCopyWith<$Res> {
  factory _$NicheSkillOverrideViewCopyWith(_NicheSkillOverrideView value, $Res Function(_NicheSkillOverrideView) _then) = __$NicheSkillOverrideViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NicheSkillOverrideView.tierKey_) SkillTier? tier,@JsonKey(name: NicheSkillOverrideView.scoreKey_) int? score,@JsonKey(name: NicheSkillOverrideView.verifiedKey_) bool? verified,@JsonKey(name: NicheSkillOverrideView.byKey_) String? by,@JsonKey(name: NicheSkillOverrideView.atKey_) DateTime? at,@JsonKey(name: NicheSkillOverrideView.reasonKey_) String? reason
});




}
/// @nodoc
class __$NicheSkillOverrideViewCopyWithImpl<$Res>
    implements _$NicheSkillOverrideViewCopyWith<$Res> {
  __$NicheSkillOverrideViewCopyWithImpl(this._self, this._then);

  final _NicheSkillOverrideView _self;
  final $Res Function(_NicheSkillOverrideView) _then;

/// Create a copy of NicheSkillOverrideView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = freezed,Object? score = freezed,Object? verified = freezed,Object? by = freezed,Object? at = freezed,Object? reason = freezed,}) {
  return _then(_NicheSkillOverrideView(
tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SkillTier?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,by: freezed == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String?,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
