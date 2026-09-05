// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewView {

/// id
@JsonKey(name: ReviewView.idKey_) String get id;/// gigId
@JsonKey(name: ReviewView.gigIdKey_) String get gigId;/// proUserId
@JsonKey(name: ReviewView.proUserIdKey_) String get proUserId;/// clientUserId
@JsonKey(name: ReviewView.clientUserIdKey_) String get clientUserId;/// nicheId
@JsonKey(name: ReviewView.nicheIdKey_) String get nicheId;/// rating
@JsonKey(name: ReviewView.ratingKey_) int get rating;/// tags
@JsonKey(name: ReviewView.tagsKey_) List<String> get tags;/// text
@JsonKey(name: ReviewView.textKey_) String? get text;/// wouldBookAgain
@JsonKey(name: ReviewView.wouldBookAgainKey_) bool get wouldBookAgain;/// videoMediaAssetId
@JsonKey(name: ReviewView.videoMediaAssetIdKey_) String? get videoMediaAssetId;/// videoPlaybackId
@JsonKey(name: ReviewView.videoPlaybackIdKey_) String? get videoPlaybackId;/// status
@JsonKey(name: ReviewView.statusKey_) ReviewStatus get status;/// createdAt
@JsonKey(name: ReviewView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: ReviewView.updatedAtKey_) DateTime get updatedAt;/// reply
@JsonKey(name: ReviewView.replyKey_) ReviewReplyView? get reply;
/// Create a copy of ReviewView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewViewCopyWith<ReviewView> get copyWith => _$ReviewViewCopyWithImpl<ReviewView>(this as ReviewView, _$identity);

  /// Serializes this ReviewView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.text, text) || other.text == text)&&(identical(other.wouldBookAgain, wouldBookAgain) || other.wouldBookAgain == wouldBookAgain)&&(identical(other.videoMediaAssetId, videoMediaAssetId) || other.videoMediaAssetId == videoMediaAssetId)&&(identical(other.videoPlaybackId, videoPlaybackId) || other.videoPlaybackId == videoPlaybackId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reply, reply) || other.reply == reply));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,proUserId,clientUserId,nicheId,rating,const DeepCollectionEquality().hash(tags),text,wouldBookAgain,videoMediaAssetId,videoPlaybackId,status,createdAt,updatedAt,reply);

@override
String toString() {
  return 'ReviewView(id: $id, gigId: $gigId, proUserId: $proUserId, clientUserId: $clientUserId, nicheId: $nicheId, rating: $rating, tags: $tags, text: $text, wouldBookAgain: $wouldBookAgain, videoMediaAssetId: $videoMediaAssetId, videoPlaybackId: $videoPlaybackId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, reply: $reply)';
}


}

/// @nodoc
abstract mixin class $ReviewViewCopyWith<$Res>  {
  factory $ReviewViewCopyWith(ReviewView value, $Res Function(ReviewView) _then) = _$ReviewViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ReviewView.idKey_) String id,@JsonKey(name: ReviewView.gigIdKey_) String gigId,@JsonKey(name: ReviewView.proUserIdKey_) String proUserId,@JsonKey(name: ReviewView.clientUserIdKey_) String clientUserId,@JsonKey(name: ReviewView.nicheIdKey_) String nicheId,@JsonKey(name: ReviewView.ratingKey_) int rating,@JsonKey(name: ReviewView.tagsKey_) List<String> tags,@JsonKey(name: ReviewView.textKey_) String? text,@JsonKey(name: ReviewView.wouldBookAgainKey_) bool wouldBookAgain,@JsonKey(name: ReviewView.videoMediaAssetIdKey_) String? videoMediaAssetId,@JsonKey(name: ReviewView.videoPlaybackIdKey_) String? videoPlaybackId,@JsonKey(name: ReviewView.statusKey_) ReviewStatus status,@JsonKey(name: ReviewView.createdAtKey_) DateTime createdAt,@JsonKey(name: ReviewView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: ReviewView.replyKey_) ReviewReplyView? reply
});


$ReviewReplyViewCopyWith<$Res>? get reply;

}
/// @nodoc
class _$ReviewViewCopyWithImpl<$Res>
    implements $ReviewViewCopyWith<$Res> {
  _$ReviewViewCopyWithImpl(this._self, this._then);

  final ReviewView _self;
  final $Res Function(ReviewView) _then;

/// Create a copy of ReviewView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gigId = null,Object? proUserId = null,Object? clientUserId = null,Object? nicheId = null,Object? rating = null,Object? tags = null,Object? text = freezed,Object? wouldBookAgain = null,Object? videoMediaAssetId = freezed,Object? videoPlaybackId = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? reply = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,wouldBookAgain: null == wouldBookAgain ? _self.wouldBookAgain : wouldBookAgain // ignore: cast_nullable_to_non_nullable
as bool,videoMediaAssetId: freezed == videoMediaAssetId ? _self.videoMediaAssetId : videoMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,videoPlaybackId: freezed == videoPlaybackId ? _self.videoPlaybackId : videoPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReviewStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as ReviewReplyView?,
  ));
}
/// Create a copy of ReviewView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewReplyViewCopyWith<$Res>? get reply {
    if (_self.reply == null) {
    return null;
  }

  return $ReviewReplyViewCopyWith<$Res>(_self.reply!, (value) {
    return _then(_self.copyWith(reply: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReviewView].
extension ReviewViewPatterns on ReviewView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewView value)  $default,){
final _that = this;
switch (_that) {
case _ReviewView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewView value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ReviewView.idKey_)  String id, @JsonKey(name: ReviewView.gigIdKey_)  String gigId, @JsonKey(name: ReviewView.proUserIdKey_)  String proUserId, @JsonKey(name: ReviewView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ReviewView.nicheIdKey_)  String nicheId, @JsonKey(name: ReviewView.ratingKey_)  int rating, @JsonKey(name: ReviewView.tagsKey_)  List<String> tags, @JsonKey(name: ReviewView.textKey_)  String? text, @JsonKey(name: ReviewView.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: ReviewView.videoMediaAssetIdKey_)  String? videoMediaAssetId, @JsonKey(name: ReviewView.videoPlaybackIdKey_)  String? videoPlaybackId, @JsonKey(name: ReviewView.statusKey_)  ReviewStatus status, @JsonKey(name: ReviewView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ReviewView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: ReviewView.replyKey_)  ReviewReplyView? reply)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewView() when $default != null:
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.nicheId,_that.rating,_that.tags,_that.text,_that.wouldBookAgain,_that.videoMediaAssetId,_that.videoPlaybackId,_that.status,_that.createdAt,_that.updatedAt,_that.reply);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ReviewView.idKey_)  String id, @JsonKey(name: ReviewView.gigIdKey_)  String gigId, @JsonKey(name: ReviewView.proUserIdKey_)  String proUserId, @JsonKey(name: ReviewView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ReviewView.nicheIdKey_)  String nicheId, @JsonKey(name: ReviewView.ratingKey_)  int rating, @JsonKey(name: ReviewView.tagsKey_)  List<String> tags, @JsonKey(name: ReviewView.textKey_)  String? text, @JsonKey(name: ReviewView.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: ReviewView.videoMediaAssetIdKey_)  String? videoMediaAssetId, @JsonKey(name: ReviewView.videoPlaybackIdKey_)  String? videoPlaybackId, @JsonKey(name: ReviewView.statusKey_)  ReviewStatus status, @JsonKey(name: ReviewView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ReviewView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: ReviewView.replyKey_)  ReviewReplyView? reply)  $default,) {final _that = this;
switch (_that) {
case _ReviewView():
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.nicheId,_that.rating,_that.tags,_that.text,_that.wouldBookAgain,_that.videoMediaAssetId,_that.videoPlaybackId,_that.status,_that.createdAt,_that.updatedAt,_that.reply);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ReviewView.idKey_)  String id, @JsonKey(name: ReviewView.gigIdKey_)  String gigId, @JsonKey(name: ReviewView.proUserIdKey_)  String proUserId, @JsonKey(name: ReviewView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ReviewView.nicheIdKey_)  String nicheId, @JsonKey(name: ReviewView.ratingKey_)  int rating, @JsonKey(name: ReviewView.tagsKey_)  List<String> tags, @JsonKey(name: ReviewView.textKey_)  String? text, @JsonKey(name: ReviewView.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: ReviewView.videoMediaAssetIdKey_)  String? videoMediaAssetId, @JsonKey(name: ReviewView.videoPlaybackIdKey_)  String? videoPlaybackId, @JsonKey(name: ReviewView.statusKey_)  ReviewStatus status, @JsonKey(name: ReviewView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ReviewView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: ReviewView.replyKey_)  ReviewReplyView? reply)?  $default,) {final _that = this;
switch (_that) {
case _ReviewView() when $default != null:
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.nicheId,_that.rating,_that.tags,_that.text,_that.wouldBookAgain,_that.videoMediaAssetId,_that.videoPlaybackId,_that.status,_that.createdAt,_that.updatedAt,_that.reply);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ReviewView extends ReviewView {
  const _ReviewView({@JsonKey(name: ReviewView.idKey_) required this.id, @JsonKey(name: ReviewView.gigIdKey_) required this.gigId, @JsonKey(name: ReviewView.proUserIdKey_) required this.proUserId, @JsonKey(name: ReviewView.clientUserIdKey_) required this.clientUserId, @JsonKey(name: ReviewView.nicheIdKey_) required this.nicheId, @JsonKey(name: ReviewView.ratingKey_) required this.rating, @JsonKey(name: ReviewView.tagsKey_) required final  List<String> tags, @JsonKey(name: ReviewView.textKey_) this.text, @JsonKey(name: ReviewView.wouldBookAgainKey_) required this.wouldBookAgain, @JsonKey(name: ReviewView.videoMediaAssetIdKey_) this.videoMediaAssetId, @JsonKey(name: ReviewView.videoPlaybackIdKey_) this.videoPlaybackId, @JsonKey(name: ReviewView.statusKey_) required this.status, @JsonKey(name: ReviewView.createdAtKey_) required this.createdAt, @JsonKey(name: ReviewView.updatedAtKey_) required this.updatedAt, @JsonKey(name: ReviewView.replyKey_) this.reply}): _tags = tags,super._();
  factory _ReviewView.fromJson(Map<String, dynamic> json) => _$ReviewViewFromJson(json);

/// id
@override@JsonKey(name: ReviewView.idKey_) final  String id;
/// gigId
@override@JsonKey(name: ReviewView.gigIdKey_) final  String gigId;
/// proUserId
@override@JsonKey(name: ReviewView.proUserIdKey_) final  String proUserId;
/// clientUserId
@override@JsonKey(name: ReviewView.clientUserIdKey_) final  String clientUserId;
/// nicheId
@override@JsonKey(name: ReviewView.nicheIdKey_) final  String nicheId;
/// rating
@override@JsonKey(name: ReviewView.ratingKey_) final  int rating;
/// tags
 final  List<String> _tags;
/// tags
@override@JsonKey(name: ReviewView.tagsKey_) List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// text
@override@JsonKey(name: ReviewView.textKey_) final  String? text;
/// wouldBookAgain
@override@JsonKey(name: ReviewView.wouldBookAgainKey_) final  bool wouldBookAgain;
/// videoMediaAssetId
@override@JsonKey(name: ReviewView.videoMediaAssetIdKey_) final  String? videoMediaAssetId;
/// videoPlaybackId
@override@JsonKey(name: ReviewView.videoPlaybackIdKey_) final  String? videoPlaybackId;
/// status
@override@JsonKey(name: ReviewView.statusKey_) final  ReviewStatus status;
/// createdAt
@override@JsonKey(name: ReviewView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: ReviewView.updatedAtKey_) final  DateTime updatedAt;
/// reply
@override@JsonKey(name: ReviewView.replyKey_) final  ReviewReplyView? reply;

/// Create a copy of ReviewView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewViewCopyWith<_ReviewView> get copyWith => __$ReviewViewCopyWithImpl<_ReviewView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.text, text) || other.text == text)&&(identical(other.wouldBookAgain, wouldBookAgain) || other.wouldBookAgain == wouldBookAgain)&&(identical(other.videoMediaAssetId, videoMediaAssetId) || other.videoMediaAssetId == videoMediaAssetId)&&(identical(other.videoPlaybackId, videoPlaybackId) || other.videoPlaybackId == videoPlaybackId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reply, reply) || other.reply == reply));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,proUserId,clientUserId,nicheId,rating,const DeepCollectionEquality().hash(_tags),text,wouldBookAgain,videoMediaAssetId,videoPlaybackId,status,createdAt,updatedAt,reply);

@override
String toString() {
  return 'ReviewView(id: $id, gigId: $gigId, proUserId: $proUserId, clientUserId: $clientUserId, nicheId: $nicheId, rating: $rating, tags: $tags, text: $text, wouldBookAgain: $wouldBookAgain, videoMediaAssetId: $videoMediaAssetId, videoPlaybackId: $videoPlaybackId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, reply: $reply)';
}


}

/// @nodoc
abstract mixin class _$ReviewViewCopyWith<$Res> implements $ReviewViewCopyWith<$Res> {
  factory _$ReviewViewCopyWith(_ReviewView value, $Res Function(_ReviewView) _then) = __$ReviewViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ReviewView.idKey_) String id,@JsonKey(name: ReviewView.gigIdKey_) String gigId,@JsonKey(name: ReviewView.proUserIdKey_) String proUserId,@JsonKey(name: ReviewView.clientUserIdKey_) String clientUserId,@JsonKey(name: ReviewView.nicheIdKey_) String nicheId,@JsonKey(name: ReviewView.ratingKey_) int rating,@JsonKey(name: ReviewView.tagsKey_) List<String> tags,@JsonKey(name: ReviewView.textKey_) String? text,@JsonKey(name: ReviewView.wouldBookAgainKey_) bool wouldBookAgain,@JsonKey(name: ReviewView.videoMediaAssetIdKey_) String? videoMediaAssetId,@JsonKey(name: ReviewView.videoPlaybackIdKey_) String? videoPlaybackId,@JsonKey(name: ReviewView.statusKey_) ReviewStatus status,@JsonKey(name: ReviewView.createdAtKey_) DateTime createdAt,@JsonKey(name: ReviewView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: ReviewView.replyKey_) ReviewReplyView? reply
});


@override $ReviewReplyViewCopyWith<$Res>? get reply;

}
/// @nodoc
class __$ReviewViewCopyWithImpl<$Res>
    implements _$ReviewViewCopyWith<$Res> {
  __$ReviewViewCopyWithImpl(this._self, this._then);

  final _ReviewView _self;
  final $Res Function(_ReviewView) _then;

/// Create a copy of ReviewView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gigId = null,Object? proUserId = null,Object? clientUserId = null,Object? nicheId = null,Object? rating = null,Object? tags = null,Object? text = freezed,Object? wouldBookAgain = null,Object? videoMediaAssetId = freezed,Object? videoPlaybackId = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? reply = freezed,}) {
  return _then(_ReviewView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,wouldBookAgain: null == wouldBookAgain ? _self.wouldBookAgain : wouldBookAgain // ignore: cast_nullable_to_non_nullable
as bool,videoMediaAssetId: freezed == videoMediaAssetId ? _self.videoMediaAssetId : videoMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,videoPlaybackId: freezed == videoPlaybackId ? _self.videoPlaybackId : videoPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReviewStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as ReviewReplyView?,
  ));
}

/// Create a copy of ReviewView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewReplyViewCopyWith<$Res>? get reply {
    if (_self.reply == null) {
    return null;
  }

  return $ReviewReplyViewCopyWith<$Res>(_self.reply!, (value) {
    return _then(_self.copyWith(reply: value));
  });
}
}

// dart format on
