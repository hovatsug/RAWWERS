// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_interview_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyInterviewView {

/// items
@JsonKey(name: MyInterviewView.itemsKey_) List<InterviewAnswerView> get items;/// isPublished
@JsonKey(name: MyInterviewView.isPublishedKey_) bool get isPublished;/// publishedAt
@JsonKey(name: MyInterviewView.publishedAtKey_) DateTime? get publishedAt;/// hasUnpublishedChanges
@JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_) bool get hasUnpublishedChanges;
/// Create a copy of MyInterviewView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyInterviewViewCopyWith<MyInterviewView> get copyWith => _$MyInterviewViewCopyWithImpl<MyInterviewView>(this as MyInterviewView, _$identity);

  /// Serializes this MyInterviewView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyInterviewView&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.hasUnpublishedChanges, hasUnpublishedChanges) || other.hasUnpublishedChanges == hasUnpublishedChanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),isPublished,publishedAt,hasUnpublishedChanges);

@override
String toString() {
  return 'MyInterviewView(items: $items, isPublished: $isPublished, publishedAt: $publishedAt, hasUnpublishedChanges: $hasUnpublishedChanges)';
}


}

/// @nodoc
abstract mixin class $MyInterviewViewCopyWith<$Res>  {
  factory $MyInterviewViewCopyWith(MyInterviewView value, $Res Function(MyInterviewView) _then) = _$MyInterviewViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MyInterviewView.itemsKey_) List<InterviewAnswerView> items,@JsonKey(name: MyInterviewView.isPublishedKey_) bool isPublished,@JsonKey(name: MyInterviewView.publishedAtKey_) DateTime? publishedAt,@JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_) bool hasUnpublishedChanges
});




}
/// @nodoc
class _$MyInterviewViewCopyWithImpl<$Res>
    implements $MyInterviewViewCopyWith<$Res> {
  _$MyInterviewViewCopyWithImpl(this._self, this._then);

  final MyInterviewView _self;
  final $Res Function(MyInterviewView) _then;

/// Create a copy of MyInterviewView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? isPublished = null,Object? publishedAt = freezed,Object? hasUnpublishedChanges = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InterviewAnswerView>,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasUnpublishedChanges: null == hasUnpublishedChanges ? _self.hasUnpublishedChanges : hasUnpublishedChanges // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MyInterviewView].
extension MyInterviewViewPatterns on MyInterviewView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyInterviewView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyInterviewView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyInterviewView value)  $default,){
final _that = this;
switch (_that) {
case _MyInterviewView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyInterviewView value)?  $default,){
final _that = this;
switch (_that) {
case _MyInterviewView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MyInterviewView.itemsKey_)  List<InterviewAnswerView> items, @JsonKey(name: MyInterviewView.isPublishedKey_)  bool isPublished, @JsonKey(name: MyInterviewView.publishedAtKey_)  DateTime? publishedAt, @JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_)  bool hasUnpublishedChanges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyInterviewView() when $default != null:
return $default(_that.items,_that.isPublished,_that.publishedAt,_that.hasUnpublishedChanges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MyInterviewView.itemsKey_)  List<InterviewAnswerView> items, @JsonKey(name: MyInterviewView.isPublishedKey_)  bool isPublished, @JsonKey(name: MyInterviewView.publishedAtKey_)  DateTime? publishedAt, @JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_)  bool hasUnpublishedChanges)  $default,) {final _that = this;
switch (_that) {
case _MyInterviewView():
return $default(_that.items,_that.isPublished,_that.publishedAt,_that.hasUnpublishedChanges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MyInterviewView.itemsKey_)  List<InterviewAnswerView> items, @JsonKey(name: MyInterviewView.isPublishedKey_)  bool isPublished, @JsonKey(name: MyInterviewView.publishedAtKey_)  DateTime? publishedAt, @JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_)  bool hasUnpublishedChanges)?  $default,) {final _that = this;
switch (_that) {
case _MyInterviewView() when $default != null:
return $default(_that.items,_that.isPublished,_that.publishedAt,_that.hasUnpublishedChanges);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MyInterviewView extends MyInterviewView {
  const _MyInterviewView({@JsonKey(name: MyInterviewView.itemsKey_) required final  List<InterviewAnswerView> items, @JsonKey(name: MyInterviewView.isPublishedKey_) required this.isPublished, @JsonKey(name: MyInterviewView.publishedAtKey_) this.publishedAt, @JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_) required this.hasUnpublishedChanges}): _items = items,super._();
  factory _MyInterviewView.fromJson(Map<String, dynamic> json) => _$MyInterviewViewFromJson(json);

/// items
 final  List<InterviewAnswerView> _items;
/// items
@override@JsonKey(name: MyInterviewView.itemsKey_) List<InterviewAnswerView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// isPublished
@override@JsonKey(name: MyInterviewView.isPublishedKey_) final  bool isPublished;
/// publishedAt
@override@JsonKey(name: MyInterviewView.publishedAtKey_) final  DateTime? publishedAt;
/// hasUnpublishedChanges
@override@JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_) final  bool hasUnpublishedChanges;

/// Create a copy of MyInterviewView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyInterviewViewCopyWith<_MyInterviewView> get copyWith => __$MyInterviewViewCopyWithImpl<_MyInterviewView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyInterviewViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyInterviewView&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.hasUnpublishedChanges, hasUnpublishedChanges) || other.hasUnpublishedChanges == hasUnpublishedChanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),isPublished,publishedAt,hasUnpublishedChanges);

@override
String toString() {
  return 'MyInterviewView(items: $items, isPublished: $isPublished, publishedAt: $publishedAt, hasUnpublishedChanges: $hasUnpublishedChanges)';
}


}

/// @nodoc
abstract mixin class _$MyInterviewViewCopyWith<$Res> implements $MyInterviewViewCopyWith<$Res> {
  factory _$MyInterviewViewCopyWith(_MyInterviewView value, $Res Function(_MyInterviewView) _then) = __$MyInterviewViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MyInterviewView.itemsKey_) List<InterviewAnswerView> items,@JsonKey(name: MyInterviewView.isPublishedKey_) bool isPublished,@JsonKey(name: MyInterviewView.publishedAtKey_) DateTime? publishedAt,@JsonKey(name: MyInterviewView.hasUnpublishedChangesKey_) bool hasUnpublishedChanges
});




}
/// @nodoc
class __$MyInterviewViewCopyWithImpl<$Res>
    implements _$MyInterviewViewCopyWith<$Res> {
  __$MyInterviewViewCopyWithImpl(this._self, this._then);

  final _MyInterviewView _self;
  final $Res Function(_MyInterviewView) _then;

/// Create a copy of MyInterviewView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? isPublished = null,Object? publishedAt = freezed,Object? hasUnpublishedChanges = null,}) {
  return _then(_MyInterviewView(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InterviewAnswerView>,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasUnpublishedChanges: null == hasUnpublishedChanges ? _self.hasUnpublishedChanges : hasUnpublishedChanges // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
