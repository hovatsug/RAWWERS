// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchCandidate {

/// proUserId
@JsonKey(name: MatchCandidate.proUserIdKey_) String get proUserId;/// rankingScore
@JsonKey(name: MatchCandidate.rankingScoreKey_) String get rankingScore;/// reasons
@JsonKey(name: MatchCandidate.reasonsKey_) List<String> get reasons;
/// Create a copy of MatchCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchCandidateCopyWith<MatchCandidate> get copyWith => _$MatchCandidateCopyWithImpl<MatchCandidate>(this as MatchCandidate, _$identity);

  /// Serializes this MatchCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchCandidate&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.rankingScore, rankingScore) || other.rankingScore == rankingScore)&&const DeepCollectionEquality().equals(other.reasons, reasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,rankingScore,const DeepCollectionEquality().hash(reasons));

@override
String toString() {
  return 'MatchCandidate(proUserId: $proUserId, rankingScore: $rankingScore, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class $MatchCandidateCopyWith<$Res>  {
  factory $MatchCandidateCopyWith(MatchCandidate value, $Res Function(MatchCandidate) _then) = _$MatchCandidateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MatchCandidate.proUserIdKey_) String proUserId,@JsonKey(name: MatchCandidate.rankingScoreKey_) String rankingScore,@JsonKey(name: MatchCandidate.reasonsKey_) List<String> reasons
});




}
/// @nodoc
class _$MatchCandidateCopyWithImpl<$Res>
    implements $MatchCandidateCopyWith<$Res> {
  _$MatchCandidateCopyWithImpl(this._self, this._then);

  final MatchCandidate _self;
  final $Res Function(MatchCandidate) _then;

/// Create a copy of MatchCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? rankingScore = null,Object? reasons = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as String,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchCandidate].
extension MatchCandidatePatterns on MatchCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchCandidate value)  $default,){
final _that = this;
switch (_that) {
case _MatchCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _MatchCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MatchCandidate.proUserIdKey_)  String proUserId, @JsonKey(name: MatchCandidate.rankingScoreKey_)  String rankingScore, @JsonKey(name: MatchCandidate.reasonsKey_)  List<String> reasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchCandidate() when $default != null:
return $default(_that.proUserId,_that.rankingScore,_that.reasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MatchCandidate.proUserIdKey_)  String proUserId, @JsonKey(name: MatchCandidate.rankingScoreKey_)  String rankingScore, @JsonKey(name: MatchCandidate.reasonsKey_)  List<String> reasons)  $default,) {final _that = this;
switch (_that) {
case _MatchCandidate():
return $default(_that.proUserId,_that.rankingScore,_that.reasons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MatchCandidate.proUserIdKey_)  String proUserId, @JsonKey(name: MatchCandidate.rankingScoreKey_)  String rankingScore, @JsonKey(name: MatchCandidate.reasonsKey_)  List<String> reasons)?  $default,) {final _that = this;
switch (_that) {
case _MatchCandidate() when $default != null:
return $default(_that.proUserId,_that.rankingScore,_that.reasons);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MatchCandidate extends MatchCandidate {
  const _MatchCandidate({@JsonKey(name: MatchCandidate.proUserIdKey_) required this.proUserId, @JsonKey(name: MatchCandidate.rankingScoreKey_) required this.rankingScore, @JsonKey(name: MatchCandidate.reasonsKey_) required final  List<String> reasons}): _reasons = reasons,super._();
  factory _MatchCandidate.fromJson(Map<String, dynamic> json) => _$MatchCandidateFromJson(json);

/// proUserId
@override@JsonKey(name: MatchCandidate.proUserIdKey_) final  String proUserId;
/// rankingScore
@override@JsonKey(name: MatchCandidate.rankingScoreKey_) final  String rankingScore;
/// reasons
 final  List<String> _reasons;
/// reasons
@override@JsonKey(name: MatchCandidate.reasonsKey_) List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}


/// Create a copy of MatchCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchCandidateCopyWith<_MatchCandidate> get copyWith => __$MatchCandidateCopyWithImpl<_MatchCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchCandidate&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.rankingScore, rankingScore) || other.rankingScore == rankingScore)&&const DeepCollectionEquality().equals(other._reasons, _reasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,rankingScore,const DeepCollectionEquality().hash(_reasons));

@override
String toString() {
  return 'MatchCandidate(proUserId: $proUserId, rankingScore: $rankingScore, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class _$MatchCandidateCopyWith<$Res> implements $MatchCandidateCopyWith<$Res> {
  factory _$MatchCandidateCopyWith(_MatchCandidate value, $Res Function(_MatchCandidate) _then) = __$MatchCandidateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MatchCandidate.proUserIdKey_) String proUserId,@JsonKey(name: MatchCandidate.rankingScoreKey_) String rankingScore,@JsonKey(name: MatchCandidate.reasonsKey_) List<String> reasons
});




}
/// @nodoc
class __$MatchCandidateCopyWithImpl<$Res>
    implements _$MatchCandidateCopyWith<$Res> {
  __$MatchCandidateCopyWithImpl(this._self, this._then);

  final _MatchCandidate _self;
  final $Res Function(_MatchCandidate) _then;

/// Create a copy of MatchCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? rankingScore = null,Object? reasons = null,}) {
  return _then(_MatchCandidate(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as String,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
