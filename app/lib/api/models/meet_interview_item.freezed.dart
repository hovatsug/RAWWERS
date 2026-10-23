// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meet_interview_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeetInterviewItem {

/// questionId
@JsonKey(name: MeetInterviewItem.questionIdKey_) String get questionId;/// title
@JsonKey(name: MeetInterviewItem.titleKey_) String get title;/// answer
@JsonKey(name: MeetInterviewItem.answerKey_) String get answer;
/// Create a copy of MeetInterviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetInterviewItemCopyWith<MeetInterviewItem> get copyWith => _$MeetInterviewItemCopyWithImpl<MeetInterviewItem>(this as MeetInterviewItem, _$identity);

  /// Serializes this MeetInterviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetInterviewItem&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,title,answer);

@override
String toString() {
  return 'MeetInterviewItem(questionId: $questionId, title: $title, answer: $answer)';
}


}

/// @nodoc
abstract mixin class $MeetInterviewItemCopyWith<$Res>  {
  factory $MeetInterviewItemCopyWith(MeetInterviewItem value, $Res Function(MeetInterviewItem) _then) = _$MeetInterviewItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MeetInterviewItem.questionIdKey_) String questionId,@JsonKey(name: MeetInterviewItem.titleKey_) String title,@JsonKey(name: MeetInterviewItem.answerKey_) String answer
});




}
/// @nodoc
class _$MeetInterviewItemCopyWithImpl<$Res>
    implements $MeetInterviewItemCopyWith<$Res> {
  _$MeetInterviewItemCopyWithImpl(this._self, this._then);

  final MeetInterviewItem _self;
  final $Res Function(MeetInterviewItem) _then;

/// Create a copy of MeetInterviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionId = null,Object? title = null,Object? answer = null,}) {
  return _then(_self.copyWith(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MeetInterviewItem].
extension MeetInterviewItemPatterns on MeetInterviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetInterviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetInterviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetInterviewItem value)  $default,){
final _that = this;
switch (_that) {
case _MeetInterviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetInterviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _MeetInterviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MeetInterviewItem.questionIdKey_)  String questionId, @JsonKey(name: MeetInterviewItem.titleKey_)  String title, @JsonKey(name: MeetInterviewItem.answerKey_)  String answer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetInterviewItem() when $default != null:
return $default(_that.questionId,_that.title,_that.answer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MeetInterviewItem.questionIdKey_)  String questionId, @JsonKey(name: MeetInterviewItem.titleKey_)  String title, @JsonKey(name: MeetInterviewItem.answerKey_)  String answer)  $default,) {final _that = this;
switch (_that) {
case _MeetInterviewItem():
return $default(_that.questionId,_that.title,_that.answer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MeetInterviewItem.questionIdKey_)  String questionId, @JsonKey(name: MeetInterviewItem.titleKey_)  String title, @JsonKey(name: MeetInterviewItem.answerKey_)  String answer)?  $default,) {final _that = this;
switch (_that) {
case _MeetInterviewItem() when $default != null:
return $default(_that.questionId,_that.title,_that.answer);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MeetInterviewItem extends MeetInterviewItem {
  const _MeetInterviewItem({@JsonKey(name: MeetInterviewItem.questionIdKey_) required this.questionId, @JsonKey(name: MeetInterviewItem.titleKey_) required this.title, @JsonKey(name: MeetInterviewItem.answerKey_) required this.answer}): super._();
  factory _MeetInterviewItem.fromJson(Map<String, dynamic> json) => _$MeetInterviewItemFromJson(json);

/// questionId
@override@JsonKey(name: MeetInterviewItem.questionIdKey_) final  String questionId;
/// title
@override@JsonKey(name: MeetInterviewItem.titleKey_) final  String title;
/// answer
@override@JsonKey(name: MeetInterviewItem.answerKey_) final  String answer;

/// Create a copy of MeetInterviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetInterviewItemCopyWith<_MeetInterviewItem> get copyWith => __$MeetInterviewItemCopyWithImpl<_MeetInterviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeetInterviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetInterviewItem&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,title,answer);

@override
String toString() {
  return 'MeetInterviewItem(questionId: $questionId, title: $title, answer: $answer)';
}


}

/// @nodoc
abstract mixin class _$MeetInterviewItemCopyWith<$Res> implements $MeetInterviewItemCopyWith<$Res> {
  factory _$MeetInterviewItemCopyWith(_MeetInterviewItem value, $Res Function(_MeetInterviewItem) _then) = __$MeetInterviewItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MeetInterviewItem.questionIdKey_) String questionId,@JsonKey(name: MeetInterviewItem.titleKey_) String title,@JsonKey(name: MeetInterviewItem.answerKey_) String answer
});




}
/// @nodoc
class __$MeetInterviewItemCopyWithImpl<$Res>
    implements _$MeetInterviewItemCopyWith<$Res> {
  __$MeetInterviewItemCopyWithImpl(this._self, this._then);

  final _MeetInterviewItem _self;
  final $Res Function(_MeetInterviewItem) _then;

/// Create a copy of MeetInterviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionId = null,Object? title = null,Object? answer = null,}) {
  return _then(_MeetInterviewItem(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
