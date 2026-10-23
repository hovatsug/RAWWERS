// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interview_answer_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InterviewAnswerView {

/// questionId
@JsonKey(name: InterviewAnswerView.questionIdKey_) String get questionId;/// prompt
@JsonKey(name: InterviewAnswerView.promptKey_) String get prompt;/// title
@JsonKey(name: InterviewAnswerView.titleKey_) String get title;/// hint
@JsonKey(name: InterviewAnswerView.hintKey_) String? get hint;/// minChars
@JsonKey(name: InterviewAnswerView.minCharsKey_) int get minChars;/// maxChars
@JsonKey(name: InterviewAnswerView.maxCharsKey_) int get maxChars;/// draft
@JsonKey(name: InterviewAnswerView.draftKey_) String? get draft;/// published
@JsonKey(name: InterviewAnswerView.publishedKey_) String? get published;/// warning
@JsonKey(name: InterviewAnswerView.warningKey_) String? get warning;
/// Create a copy of InterviewAnswerView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterviewAnswerViewCopyWith<InterviewAnswerView> get copyWith => _$InterviewAnswerViewCopyWithImpl<InterviewAnswerView>(this as InterviewAnswerView, _$identity);

  /// Serializes this InterviewAnswerView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterviewAnswerView&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.title, title) || other.title == title)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.minChars, minChars) || other.minChars == minChars)&&(identical(other.maxChars, maxChars) || other.maxChars == maxChars)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.published, published) || other.published == published)&&(identical(other.warning, warning) || other.warning == warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,prompt,title,hint,minChars,maxChars,draft,published,warning);

@override
String toString() {
  return 'InterviewAnswerView(questionId: $questionId, prompt: $prompt, title: $title, hint: $hint, minChars: $minChars, maxChars: $maxChars, draft: $draft, published: $published, warning: $warning)';
}


}

/// @nodoc
abstract mixin class $InterviewAnswerViewCopyWith<$Res>  {
  factory $InterviewAnswerViewCopyWith(InterviewAnswerView value, $Res Function(InterviewAnswerView) _then) = _$InterviewAnswerViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: InterviewAnswerView.questionIdKey_) String questionId,@JsonKey(name: InterviewAnswerView.promptKey_) String prompt,@JsonKey(name: InterviewAnswerView.titleKey_) String title,@JsonKey(name: InterviewAnswerView.hintKey_) String? hint,@JsonKey(name: InterviewAnswerView.minCharsKey_) int minChars,@JsonKey(name: InterviewAnswerView.maxCharsKey_) int maxChars,@JsonKey(name: InterviewAnswerView.draftKey_) String? draft,@JsonKey(name: InterviewAnswerView.publishedKey_) String? published,@JsonKey(name: InterviewAnswerView.warningKey_) String? warning
});




}
/// @nodoc
class _$InterviewAnswerViewCopyWithImpl<$Res>
    implements $InterviewAnswerViewCopyWith<$Res> {
  _$InterviewAnswerViewCopyWithImpl(this._self, this._then);

  final InterviewAnswerView _self;
  final $Res Function(InterviewAnswerView) _then;

/// Create a copy of InterviewAnswerView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionId = null,Object? prompt = null,Object? title = null,Object? hint = freezed,Object? minChars = null,Object? maxChars = null,Object? draft = freezed,Object? published = freezed,Object? warning = freezed,}) {
  return _then(_self.copyWith(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,minChars: null == minChars ? _self.minChars : minChars // ignore: cast_nullable_to_non_nullable
as int,maxChars: null == maxChars ? _self.maxChars : maxChars // ignore: cast_nullable_to_non_nullable
as int,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String?,published: freezed == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InterviewAnswerView].
extension InterviewAnswerViewPatterns on InterviewAnswerView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterviewAnswerView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterviewAnswerView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterviewAnswerView value)  $default,){
final _that = this;
switch (_that) {
case _InterviewAnswerView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterviewAnswerView value)?  $default,){
final _that = this;
switch (_that) {
case _InterviewAnswerView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: InterviewAnswerView.questionIdKey_)  String questionId, @JsonKey(name: InterviewAnswerView.promptKey_)  String prompt, @JsonKey(name: InterviewAnswerView.titleKey_)  String title, @JsonKey(name: InterviewAnswerView.hintKey_)  String? hint, @JsonKey(name: InterviewAnswerView.minCharsKey_)  int minChars, @JsonKey(name: InterviewAnswerView.maxCharsKey_)  int maxChars, @JsonKey(name: InterviewAnswerView.draftKey_)  String? draft, @JsonKey(name: InterviewAnswerView.publishedKey_)  String? published, @JsonKey(name: InterviewAnswerView.warningKey_)  String? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterviewAnswerView() when $default != null:
return $default(_that.questionId,_that.prompt,_that.title,_that.hint,_that.minChars,_that.maxChars,_that.draft,_that.published,_that.warning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: InterviewAnswerView.questionIdKey_)  String questionId, @JsonKey(name: InterviewAnswerView.promptKey_)  String prompt, @JsonKey(name: InterviewAnswerView.titleKey_)  String title, @JsonKey(name: InterviewAnswerView.hintKey_)  String? hint, @JsonKey(name: InterviewAnswerView.minCharsKey_)  int minChars, @JsonKey(name: InterviewAnswerView.maxCharsKey_)  int maxChars, @JsonKey(name: InterviewAnswerView.draftKey_)  String? draft, @JsonKey(name: InterviewAnswerView.publishedKey_)  String? published, @JsonKey(name: InterviewAnswerView.warningKey_)  String? warning)  $default,) {final _that = this;
switch (_that) {
case _InterviewAnswerView():
return $default(_that.questionId,_that.prompt,_that.title,_that.hint,_that.minChars,_that.maxChars,_that.draft,_that.published,_that.warning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: InterviewAnswerView.questionIdKey_)  String questionId, @JsonKey(name: InterviewAnswerView.promptKey_)  String prompt, @JsonKey(name: InterviewAnswerView.titleKey_)  String title, @JsonKey(name: InterviewAnswerView.hintKey_)  String? hint, @JsonKey(name: InterviewAnswerView.minCharsKey_)  int minChars, @JsonKey(name: InterviewAnswerView.maxCharsKey_)  int maxChars, @JsonKey(name: InterviewAnswerView.draftKey_)  String? draft, @JsonKey(name: InterviewAnswerView.publishedKey_)  String? published, @JsonKey(name: InterviewAnswerView.warningKey_)  String? warning)?  $default,) {final _that = this;
switch (_that) {
case _InterviewAnswerView() when $default != null:
return $default(_that.questionId,_that.prompt,_that.title,_that.hint,_that.minChars,_that.maxChars,_that.draft,_that.published,_that.warning);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _InterviewAnswerView extends InterviewAnswerView {
  const _InterviewAnswerView({@JsonKey(name: InterviewAnswerView.questionIdKey_) required this.questionId, @JsonKey(name: InterviewAnswerView.promptKey_) required this.prompt, @JsonKey(name: InterviewAnswerView.titleKey_) required this.title, @JsonKey(name: InterviewAnswerView.hintKey_) this.hint, @JsonKey(name: InterviewAnswerView.minCharsKey_) required this.minChars, @JsonKey(name: InterviewAnswerView.maxCharsKey_) required this.maxChars, @JsonKey(name: InterviewAnswerView.draftKey_) this.draft, @JsonKey(name: InterviewAnswerView.publishedKey_) this.published, @JsonKey(name: InterviewAnswerView.warningKey_) this.warning}): super._();
  factory _InterviewAnswerView.fromJson(Map<String, dynamic> json) => _$InterviewAnswerViewFromJson(json);

/// questionId
@override@JsonKey(name: InterviewAnswerView.questionIdKey_) final  String questionId;
/// prompt
@override@JsonKey(name: InterviewAnswerView.promptKey_) final  String prompt;
/// title
@override@JsonKey(name: InterviewAnswerView.titleKey_) final  String title;
/// hint
@override@JsonKey(name: InterviewAnswerView.hintKey_) final  String? hint;
/// minChars
@override@JsonKey(name: InterviewAnswerView.minCharsKey_) final  int minChars;
/// maxChars
@override@JsonKey(name: InterviewAnswerView.maxCharsKey_) final  int maxChars;
/// draft
@override@JsonKey(name: InterviewAnswerView.draftKey_) final  String? draft;
/// published
@override@JsonKey(name: InterviewAnswerView.publishedKey_) final  String? published;
/// warning
@override@JsonKey(name: InterviewAnswerView.warningKey_) final  String? warning;

/// Create a copy of InterviewAnswerView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterviewAnswerViewCopyWith<_InterviewAnswerView> get copyWith => __$InterviewAnswerViewCopyWithImpl<_InterviewAnswerView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterviewAnswerViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterviewAnswerView&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.title, title) || other.title == title)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.minChars, minChars) || other.minChars == minChars)&&(identical(other.maxChars, maxChars) || other.maxChars == maxChars)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.published, published) || other.published == published)&&(identical(other.warning, warning) || other.warning == warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,prompt,title,hint,minChars,maxChars,draft,published,warning);

@override
String toString() {
  return 'InterviewAnswerView(questionId: $questionId, prompt: $prompt, title: $title, hint: $hint, minChars: $minChars, maxChars: $maxChars, draft: $draft, published: $published, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$InterviewAnswerViewCopyWith<$Res> implements $InterviewAnswerViewCopyWith<$Res> {
  factory _$InterviewAnswerViewCopyWith(_InterviewAnswerView value, $Res Function(_InterviewAnswerView) _then) = __$InterviewAnswerViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: InterviewAnswerView.questionIdKey_) String questionId,@JsonKey(name: InterviewAnswerView.promptKey_) String prompt,@JsonKey(name: InterviewAnswerView.titleKey_) String title,@JsonKey(name: InterviewAnswerView.hintKey_) String? hint,@JsonKey(name: InterviewAnswerView.minCharsKey_) int minChars,@JsonKey(name: InterviewAnswerView.maxCharsKey_) int maxChars,@JsonKey(name: InterviewAnswerView.draftKey_) String? draft,@JsonKey(name: InterviewAnswerView.publishedKey_) String? published,@JsonKey(name: InterviewAnswerView.warningKey_) String? warning
});




}
/// @nodoc
class __$InterviewAnswerViewCopyWithImpl<$Res>
    implements _$InterviewAnswerViewCopyWith<$Res> {
  __$InterviewAnswerViewCopyWithImpl(this._self, this._then);

  final _InterviewAnswerView _self;
  final $Res Function(_InterviewAnswerView) _then;

/// Create a copy of InterviewAnswerView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionId = null,Object? prompt = null,Object? title = null,Object? hint = freezed,Object? minChars = null,Object? maxChars = null,Object? draft = freezed,Object? published = freezed,Object? warning = freezed,}) {
  return _then(_InterviewAnswerView(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,minChars: null == minChars ? _self.minChars : minChars // ignore: cast_nullable_to_non_nullable
as int,maxChars: null == maxChars ? _self.maxChars : maxChars // ignore: cast_nullable_to_non_nullable
as int,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String?,published: freezed == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
