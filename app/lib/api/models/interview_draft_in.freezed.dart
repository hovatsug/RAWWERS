// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interview_draft_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InterviewDraftIn {

/// answers
@JsonKey(name: InterviewDraftIn.answersKey_) Map<String, dynamic> get answers;
/// Create a copy of InterviewDraftIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterviewDraftInCopyWith<InterviewDraftIn> get copyWith => _$InterviewDraftInCopyWithImpl<InterviewDraftIn>(this as InterviewDraftIn, _$identity);

  /// Serializes this InterviewDraftIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterviewDraftIn&&const DeepCollectionEquality().equals(other.answers, answers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(answers));

@override
String toString() {
  return 'InterviewDraftIn(answers: $answers)';
}


}

/// @nodoc
abstract mixin class $InterviewDraftInCopyWith<$Res>  {
  factory $InterviewDraftInCopyWith(InterviewDraftIn value, $Res Function(InterviewDraftIn) _then) = _$InterviewDraftInCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: InterviewDraftIn.answersKey_) Map<String, dynamic> answers
});




}
/// @nodoc
class _$InterviewDraftInCopyWithImpl<$Res>
    implements $InterviewDraftInCopyWith<$Res> {
  _$InterviewDraftInCopyWithImpl(this._self, this._then);

  final InterviewDraftIn _self;
  final $Res Function(InterviewDraftIn) _then;

/// Create a copy of InterviewDraftIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? answers = null,}) {
  return _then(_self.copyWith(
answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [InterviewDraftIn].
extension InterviewDraftInPatterns on InterviewDraftIn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterviewDraftIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterviewDraftIn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterviewDraftIn value)  $default,){
final _that = this;
switch (_that) {
case _InterviewDraftIn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterviewDraftIn value)?  $default,){
final _that = this;
switch (_that) {
case _InterviewDraftIn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: InterviewDraftIn.answersKey_)  Map<String, dynamic> answers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterviewDraftIn() when $default != null:
return $default(_that.answers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: InterviewDraftIn.answersKey_)  Map<String, dynamic> answers)  $default,) {final _that = this;
switch (_that) {
case _InterviewDraftIn():
return $default(_that.answers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: InterviewDraftIn.answersKey_)  Map<String, dynamic> answers)?  $default,) {final _that = this;
switch (_that) {
case _InterviewDraftIn() when $default != null:
return $default(_that.answers);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _InterviewDraftIn extends InterviewDraftIn {
  const _InterviewDraftIn({@JsonKey(name: InterviewDraftIn.answersKey_) required final  Map<String, dynamic> answers}): _answers = answers,super._();
  factory _InterviewDraftIn.fromJson(Map<String, dynamic> json) => _$InterviewDraftInFromJson(json);

/// answers
 final  Map<String, dynamic> _answers;
/// answers
@override@JsonKey(name: InterviewDraftIn.answersKey_) Map<String, dynamic> get answers {
  if (_answers is EqualUnmodifiableMapView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_answers);
}


/// Create a copy of InterviewDraftIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterviewDraftInCopyWith<_InterviewDraftIn> get copyWith => __$InterviewDraftInCopyWithImpl<_InterviewDraftIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterviewDraftInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterviewDraftIn&&const DeepCollectionEquality().equals(other._answers, _answers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_answers));

@override
String toString() {
  return 'InterviewDraftIn(answers: $answers)';
}


}

/// @nodoc
abstract mixin class _$InterviewDraftInCopyWith<$Res> implements $InterviewDraftInCopyWith<$Res> {
  factory _$InterviewDraftInCopyWith(_InterviewDraftIn value, $Res Function(_InterviewDraftIn) _then) = __$InterviewDraftInCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: InterviewDraftIn.answersKey_) Map<String, dynamic> answers
});




}
/// @nodoc
class __$InterviewDraftInCopyWithImpl<$Res>
    implements _$InterviewDraftInCopyWith<$Res> {
  __$InterviewDraftInCopyWithImpl(this._self, this._then);

  final _InterviewDraftIn _self;
  final $Res Function(_InterviewDraftIn) _then;

/// Create a copy of InterviewDraftIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? answers = null,}) {
  return _then(_InterviewDraftIn(
answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
