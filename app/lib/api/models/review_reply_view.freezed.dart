// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_reply_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewReplyView {

/// id
@JsonKey(name: ReviewReplyView.idKey_) String get id;/// reviewId
@JsonKey(name: ReviewReplyView.reviewIdKey_) String get reviewId;/// proUserId
@JsonKey(name: ReviewReplyView.proUserIdKey_) String get proUserId;/// text
@JsonKey(name: ReviewReplyView.textKey_) String get text;/// createdAt
@JsonKey(name: ReviewReplyView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: ReviewReplyView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of ReviewReplyView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewReplyViewCopyWith<ReviewReplyView> get copyWith => _$ReviewReplyViewCopyWithImpl<ReviewReplyView>(this as ReviewReplyView, _$identity);

  /// Serializes this ReviewReplyView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewReplyView&&(identical(other.id, id) || other.id == id)&&(identical(other.reviewId, reviewId) || other.reviewId == reviewId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reviewId,proUserId,text,createdAt,updatedAt);

@override
String toString() {
  return 'ReviewReplyView(id: $id, reviewId: $reviewId, proUserId: $proUserId, text: $text, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReviewReplyViewCopyWith<$Res>  {
  factory $ReviewReplyViewCopyWith(ReviewReplyView value, $Res Function(ReviewReplyView) _then) = _$ReviewReplyViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ReviewReplyView.idKey_) String id,@JsonKey(name: ReviewReplyView.reviewIdKey_) String reviewId,@JsonKey(name: ReviewReplyView.proUserIdKey_) String proUserId,@JsonKey(name: ReviewReplyView.textKey_) String text,@JsonKey(name: ReviewReplyView.createdAtKey_) DateTime createdAt,@JsonKey(name: ReviewReplyView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$ReviewReplyViewCopyWithImpl<$Res>
    implements $ReviewReplyViewCopyWith<$Res> {
  _$ReviewReplyViewCopyWithImpl(this._self, this._then);

  final ReviewReplyView _self;
  final $Res Function(ReviewReplyView) _then;

/// Create a copy of ReviewReplyView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reviewId = null,Object? proUserId = null,Object? text = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reviewId: null == reviewId ? _self.reviewId : reviewId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewReplyView].
extension ReviewReplyViewPatterns on ReviewReplyView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewReplyView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewReplyView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewReplyView value)  $default,){
final _that = this;
switch (_that) {
case _ReviewReplyView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewReplyView value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewReplyView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ReviewReplyView.idKey_)  String id, @JsonKey(name: ReviewReplyView.reviewIdKey_)  String reviewId, @JsonKey(name: ReviewReplyView.proUserIdKey_)  String proUserId, @JsonKey(name: ReviewReplyView.textKey_)  String text, @JsonKey(name: ReviewReplyView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ReviewReplyView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewReplyView() when $default != null:
return $default(_that.id,_that.reviewId,_that.proUserId,_that.text,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ReviewReplyView.idKey_)  String id, @JsonKey(name: ReviewReplyView.reviewIdKey_)  String reviewId, @JsonKey(name: ReviewReplyView.proUserIdKey_)  String proUserId, @JsonKey(name: ReviewReplyView.textKey_)  String text, @JsonKey(name: ReviewReplyView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ReviewReplyView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewReplyView():
return $default(_that.id,_that.reviewId,_that.proUserId,_that.text,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ReviewReplyView.idKey_)  String id, @JsonKey(name: ReviewReplyView.reviewIdKey_)  String reviewId, @JsonKey(name: ReviewReplyView.proUserIdKey_)  String proUserId, @JsonKey(name: ReviewReplyView.textKey_)  String text, @JsonKey(name: ReviewReplyView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ReviewReplyView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewReplyView() when $default != null:
return $default(_that.id,_that.reviewId,_that.proUserId,_that.text,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ReviewReplyView extends ReviewReplyView {
  const _ReviewReplyView({@JsonKey(name: ReviewReplyView.idKey_) required this.id, @JsonKey(name: ReviewReplyView.reviewIdKey_) required this.reviewId, @JsonKey(name: ReviewReplyView.proUserIdKey_) required this.proUserId, @JsonKey(name: ReviewReplyView.textKey_) required this.text, @JsonKey(name: ReviewReplyView.createdAtKey_) required this.createdAt, @JsonKey(name: ReviewReplyView.updatedAtKey_) required this.updatedAt}): super._();
  factory _ReviewReplyView.fromJson(Map<String, dynamic> json) => _$ReviewReplyViewFromJson(json);

/// id
@override@JsonKey(name: ReviewReplyView.idKey_) final  String id;
/// reviewId
@override@JsonKey(name: ReviewReplyView.reviewIdKey_) final  String reviewId;
/// proUserId
@override@JsonKey(name: ReviewReplyView.proUserIdKey_) final  String proUserId;
/// text
@override@JsonKey(name: ReviewReplyView.textKey_) final  String text;
/// createdAt
@override@JsonKey(name: ReviewReplyView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: ReviewReplyView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of ReviewReplyView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewReplyViewCopyWith<_ReviewReplyView> get copyWith => __$ReviewReplyViewCopyWithImpl<_ReviewReplyView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewReplyViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewReplyView&&(identical(other.id, id) || other.id == id)&&(identical(other.reviewId, reviewId) || other.reviewId == reviewId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reviewId,proUserId,text,createdAt,updatedAt);

@override
String toString() {
  return 'ReviewReplyView(id: $id, reviewId: $reviewId, proUserId: $proUserId, text: $text, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewReplyViewCopyWith<$Res> implements $ReviewReplyViewCopyWith<$Res> {
  factory _$ReviewReplyViewCopyWith(_ReviewReplyView value, $Res Function(_ReviewReplyView) _then) = __$ReviewReplyViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ReviewReplyView.idKey_) String id,@JsonKey(name: ReviewReplyView.reviewIdKey_) String reviewId,@JsonKey(name: ReviewReplyView.proUserIdKey_) String proUserId,@JsonKey(name: ReviewReplyView.textKey_) String text,@JsonKey(name: ReviewReplyView.createdAtKey_) DateTime createdAt,@JsonKey(name: ReviewReplyView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$ReviewReplyViewCopyWithImpl<$Res>
    implements _$ReviewReplyViewCopyWith<$Res> {
  __$ReviewReplyViewCopyWithImpl(this._self, this._then);

  final _ReviewReplyView _self;
  final $Res Function(_ReviewReplyView) _then;

/// Create a copy of ReviewReplyView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reviewId = null,Object? proUserId = null,Object? text = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ReviewReplyView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reviewId: null == reviewId ? _self.reviewId : reviewId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
