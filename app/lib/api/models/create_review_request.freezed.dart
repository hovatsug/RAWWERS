// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_review_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateReviewRequest {

/// rating
@JsonKey(name: CreateReviewRequest.ratingKey_) int get rating;/// tags
@JsonKey(name: CreateReviewRequest.tagsKey_) List<String>? get tags;/// text
@JsonKey(name: CreateReviewRequest.textKey_) String? get text;/// wouldBookAgain
@JsonKey(name: CreateReviewRequest.wouldBookAgainKey_) bool get wouldBookAgain;/// videoMediaAssetId
@JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_) String? get videoMediaAssetId;
/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReviewRequestCopyWith<CreateReviewRequest> get copyWith => _$CreateReviewRequestCopyWithImpl<CreateReviewRequest>(this as CreateReviewRequest, _$identity);

  /// Serializes this CreateReviewRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReviewRequest&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.text, text) || other.text == text)&&(identical(other.wouldBookAgain, wouldBookAgain) || other.wouldBookAgain == wouldBookAgain)&&(identical(other.videoMediaAssetId, videoMediaAssetId) || other.videoMediaAssetId == videoMediaAssetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,const DeepCollectionEquality().hash(tags),text,wouldBookAgain,videoMediaAssetId);

@override
String toString() {
  return 'CreateReviewRequest(rating: $rating, tags: $tags, text: $text, wouldBookAgain: $wouldBookAgain, videoMediaAssetId: $videoMediaAssetId)';
}


}

/// @nodoc
abstract mixin class $CreateReviewRequestCopyWith<$Res>  {
  factory $CreateReviewRequestCopyWith(CreateReviewRequest value, $Res Function(CreateReviewRequest) _then) = _$CreateReviewRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateReviewRequest.ratingKey_) int rating,@JsonKey(name: CreateReviewRequest.tagsKey_) List<String>? tags,@JsonKey(name: CreateReviewRequest.textKey_) String? text,@JsonKey(name: CreateReviewRequest.wouldBookAgainKey_) bool wouldBookAgain,@JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_) String? videoMediaAssetId
});




}
/// @nodoc
class _$CreateReviewRequestCopyWithImpl<$Res>
    implements $CreateReviewRequestCopyWith<$Res> {
  _$CreateReviewRequestCopyWithImpl(this._self, this._then);

  final CreateReviewRequest _self;
  final $Res Function(CreateReviewRequest) _then;

/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rating = null,Object? tags = freezed,Object? text = freezed,Object? wouldBookAgain = null,Object? videoMediaAssetId = freezed,}) {
  return _then(_self.copyWith(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,wouldBookAgain: null == wouldBookAgain ? _self.wouldBookAgain : wouldBookAgain // ignore: cast_nullable_to_non_nullable
as bool,videoMediaAssetId: freezed == videoMediaAssetId ? _self.videoMediaAssetId : videoMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateReviewRequest].
extension CreateReviewRequestPatterns on CreateReviewRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateReviewRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateReviewRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateReviewRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateReviewRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateReviewRequest.ratingKey_)  int rating, @JsonKey(name: CreateReviewRequest.tagsKey_)  List<String>? tags, @JsonKey(name: CreateReviewRequest.textKey_)  String? text, @JsonKey(name: CreateReviewRequest.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_)  String? videoMediaAssetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
return $default(_that.rating,_that.tags,_that.text,_that.wouldBookAgain,_that.videoMediaAssetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateReviewRequest.ratingKey_)  int rating, @JsonKey(name: CreateReviewRequest.tagsKey_)  List<String>? tags, @JsonKey(name: CreateReviewRequest.textKey_)  String? text, @JsonKey(name: CreateReviewRequest.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_)  String? videoMediaAssetId)  $default,) {final _that = this;
switch (_that) {
case _CreateReviewRequest():
return $default(_that.rating,_that.tags,_that.text,_that.wouldBookAgain,_that.videoMediaAssetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateReviewRequest.ratingKey_)  int rating, @JsonKey(name: CreateReviewRequest.tagsKey_)  List<String>? tags, @JsonKey(name: CreateReviewRequest.textKey_)  String? text, @JsonKey(name: CreateReviewRequest.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_)  String? videoMediaAssetId)?  $default,) {final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
return $default(_that.rating,_that.tags,_that.text,_that.wouldBookAgain,_that.videoMediaAssetId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateReviewRequest extends CreateReviewRequest {
  const _CreateReviewRequest({@JsonKey(name: CreateReviewRequest.ratingKey_) required this.rating, @JsonKey(name: CreateReviewRequest.tagsKey_) final  List<String>? tags, @JsonKey(name: CreateReviewRequest.textKey_) this.text, @JsonKey(name: CreateReviewRequest.wouldBookAgainKey_) this.wouldBookAgain = true, @JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_) this.videoMediaAssetId}): _tags = tags,super._();
  factory _CreateReviewRequest.fromJson(Map<String, dynamic> json) => _$CreateReviewRequestFromJson(json);

/// rating
@override@JsonKey(name: CreateReviewRequest.ratingKey_) final  int rating;
/// tags
 final  List<String>? _tags;
/// tags
@override@JsonKey(name: CreateReviewRequest.tagsKey_) List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// text
@override@JsonKey(name: CreateReviewRequest.textKey_) final  String? text;
/// wouldBookAgain
@override@JsonKey(name: CreateReviewRequest.wouldBookAgainKey_) final  bool wouldBookAgain;
/// videoMediaAssetId
@override@JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_) final  String? videoMediaAssetId;

/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateReviewRequestCopyWith<_CreateReviewRequest> get copyWith => __$CreateReviewRequestCopyWithImpl<_CreateReviewRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateReviewRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReviewRequest&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.text, text) || other.text == text)&&(identical(other.wouldBookAgain, wouldBookAgain) || other.wouldBookAgain == wouldBookAgain)&&(identical(other.videoMediaAssetId, videoMediaAssetId) || other.videoMediaAssetId == videoMediaAssetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,const DeepCollectionEquality().hash(_tags),text,wouldBookAgain,videoMediaAssetId);

@override
String toString() {
  return 'CreateReviewRequest(rating: $rating, tags: $tags, text: $text, wouldBookAgain: $wouldBookAgain, videoMediaAssetId: $videoMediaAssetId)';
}


}

/// @nodoc
abstract mixin class _$CreateReviewRequestCopyWith<$Res> implements $CreateReviewRequestCopyWith<$Res> {
  factory _$CreateReviewRequestCopyWith(_CreateReviewRequest value, $Res Function(_CreateReviewRequest) _then) = __$CreateReviewRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateReviewRequest.ratingKey_) int rating,@JsonKey(name: CreateReviewRequest.tagsKey_) List<String>? tags,@JsonKey(name: CreateReviewRequest.textKey_) String? text,@JsonKey(name: CreateReviewRequest.wouldBookAgainKey_) bool wouldBookAgain,@JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_) String? videoMediaAssetId
});




}
/// @nodoc
class __$CreateReviewRequestCopyWithImpl<$Res>
    implements _$CreateReviewRequestCopyWith<$Res> {
  __$CreateReviewRequestCopyWithImpl(this._self, this._then);

  final _CreateReviewRequest _self;
  final $Res Function(_CreateReviewRequest) _then;

/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rating = null,Object? tags = freezed,Object? text = freezed,Object? wouldBookAgain = null,Object? videoMediaAssetId = freezed,}) {
  return _then(_CreateReviewRequest(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,wouldBookAgain: null == wouldBookAgain ? _self.wouldBookAgain : wouldBookAgain // ignore: cast_nullable_to_non_nullable
as bool,videoMediaAssetId: freezed == videoMediaAssetId ? _self.videoMediaAssetId : videoMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
