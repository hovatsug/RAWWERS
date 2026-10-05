// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_review_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicReviewView {

/// id
@JsonKey(name: PublicReviewView.idKey_) String get id;/// rating
@JsonKey(name: PublicReviewView.ratingKey_) int get rating;/// text
@JsonKey(name: PublicReviewView.textKey_) String? get text;/// wouldBookAgain
@JsonKey(name: PublicReviewView.wouldBookAgainKey_) bool get wouldBookAgain;/// niche
@JsonKey(name: PublicReviewView.nicheKey_) ReviewNicheView get niche;/// videoPlaybackId
@JsonKey(name: PublicReviewView.videoPlaybackIdKey_) String? get videoPlaybackId;/// createdAt
@JsonKey(name: PublicReviewView.createdAtKey_) DateTime get createdAt;/// reply
@JsonKey(name: PublicReviewView.replyKey_) ReviewReplyView? get reply;
/// Create a copy of PublicReviewView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicReviewViewCopyWith<PublicReviewView> get copyWith => _$PublicReviewViewCopyWithImpl<PublicReviewView>(this as PublicReviewView, _$identity);

  /// Serializes this PublicReviewView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicReviewView&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.text, text) || other.text == text)&&(identical(other.wouldBookAgain, wouldBookAgain) || other.wouldBookAgain == wouldBookAgain)&&(identical(other.niche, niche) || other.niche == niche)&&(identical(other.videoPlaybackId, videoPlaybackId) || other.videoPlaybackId == videoPlaybackId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reply, reply) || other.reply == reply));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,text,wouldBookAgain,niche,videoPlaybackId,createdAt,reply);

@override
String toString() {
  return 'PublicReviewView(id: $id, rating: $rating, text: $text, wouldBookAgain: $wouldBookAgain, niche: $niche, videoPlaybackId: $videoPlaybackId, createdAt: $createdAt, reply: $reply)';
}


}

/// @nodoc
abstract mixin class $PublicReviewViewCopyWith<$Res>  {
  factory $PublicReviewViewCopyWith(PublicReviewView value, $Res Function(PublicReviewView) _then) = _$PublicReviewViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PublicReviewView.idKey_) String id,@JsonKey(name: PublicReviewView.ratingKey_) int rating,@JsonKey(name: PublicReviewView.textKey_) String? text,@JsonKey(name: PublicReviewView.wouldBookAgainKey_) bool wouldBookAgain,@JsonKey(name: PublicReviewView.nicheKey_) ReviewNicheView niche,@JsonKey(name: PublicReviewView.videoPlaybackIdKey_) String? videoPlaybackId,@JsonKey(name: PublicReviewView.createdAtKey_) DateTime createdAt,@JsonKey(name: PublicReviewView.replyKey_) ReviewReplyView? reply
});


$ReviewNicheViewCopyWith<$Res> get niche;$ReviewReplyViewCopyWith<$Res>? get reply;

}
/// @nodoc
class _$PublicReviewViewCopyWithImpl<$Res>
    implements $PublicReviewViewCopyWith<$Res> {
  _$PublicReviewViewCopyWithImpl(this._self, this._then);

  final PublicReviewView _self;
  final $Res Function(PublicReviewView) _then;

/// Create a copy of PublicReviewView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rating = null,Object? text = freezed,Object? wouldBookAgain = null,Object? niche = null,Object? videoPlaybackId = freezed,Object? createdAt = null,Object? reply = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,wouldBookAgain: null == wouldBookAgain ? _self.wouldBookAgain : wouldBookAgain // ignore: cast_nullable_to_non_nullable
as bool,niche: null == niche ? _self.niche : niche // ignore: cast_nullable_to_non_nullable
as ReviewNicheView,videoPlaybackId: freezed == videoPlaybackId ? _self.videoPlaybackId : videoPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as ReviewReplyView?,
  ));
}
/// Create a copy of PublicReviewView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewNicheViewCopyWith<$Res> get niche {
  
  return $ReviewNicheViewCopyWith<$Res>(_self.niche, (value) {
    return _then(_self.copyWith(niche: value));
  });
}/// Create a copy of PublicReviewView
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


/// Adds pattern-matching-related methods to [PublicReviewView].
extension PublicReviewViewPatterns on PublicReviewView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicReviewView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicReviewView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicReviewView value)  $default,){
final _that = this;
switch (_that) {
case _PublicReviewView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicReviewView value)?  $default,){
final _that = this;
switch (_that) {
case _PublicReviewView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PublicReviewView.idKey_)  String id, @JsonKey(name: PublicReviewView.ratingKey_)  int rating, @JsonKey(name: PublicReviewView.textKey_)  String? text, @JsonKey(name: PublicReviewView.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: PublicReviewView.nicheKey_)  ReviewNicheView niche, @JsonKey(name: PublicReviewView.videoPlaybackIdKey_)  String? videoPlaybackId, @JsonKey(name: PublicReviewView.createdAtKey_)  DateTime createdAt, @JsonKey(name: PublicReviewView.replyKey_)  ReviewReplyView? reply)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicReviewView() when $default != null:
return $default(_that.id,_that.rating,_that.text,_that.wouldBookAgain,_that.niche,_that.videoPlaybackId,_that.createdAt,_that.reply);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PublicReviewView.idKey_)  String id, @JsonKey(name: PublicReviewView.ratingKey_)  int rating, @JsonKey(name: PublicReviewView.textKey_)  String? text, @JsonKey(name: PublicReviewView.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: PublicReviewView.nicheKey_)  ReviewNicheView niche, @JsonKey(name: PublicReviewView.videoPlaybackIdKey_)  String? videoPlaybackId, @JsonKey(name: PublicReviewView.createdAtKey_)  DateTime createdAt, @JsonKey(name: PublicReviewView.replyKey_)  ReviewReplyView? reply)  $default,) {final _that = this;
switch (_that) {
case _PublicReviewView():
return $default(_that.id,_that.rating,_that.text,_that.wouldBookAgain,_that.niche,_that.videoPlaybackId,_that.createdAt,_that.reply);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PublicReviewView.idKey_)  String id, @JsonKey(name: PublicReviewView.ratingKey_)  int rating, @JsonKey(name: PublicReviewView.textKey_)  String? text, @JsonKey(name: PublicReviewView.wouldBookAgainKey_)  bool wouldBookAgain, @JsonKey(name: PublicReviewView.nicheKey_)  ReviewNicheView niche, @JsonKey(name: PublicReviewView.videoPlaybackIdKey_)  String? videoPlaybackId, @JsonKey(name: PublicReviewView.createdAtKey_)  DateTime createdAt, @JsonKey(name: PublicReviewView.replyKey_)  ReviewReplyView? reply)?  $default,) {final _that = this;
switch (_that) {
case _PublicReviewView() when $default != null:
return $default(_that.id,_that.rating,_that.text,_that.wouldBookAgain,_that.niche,_that.videoPlaybackId,_that.createdAt,_that.reply);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PublicReviewView extends PublicReviewView {
  const _PublicReviewView({@JsonKey(name: PublicReviewView.idKey_) required this.id, @JsonKey(name: PublicReviewView.ratingKey_) required this.rating, @JsonKey(name: PublicReviewView.textKey_) this.text, @JsonKey(name: PublicReviewView.wouldBookAgainKey_) required this.wouldBookAgain, @JsonKey(name: PublicReviewView.nicheKey_) required this.niche, @JsonKey(name: PublicReviewView.videoPlaybackIdKey_) this.videoPlaybackId, @JsonKey(name: PublicReviewView.createdAtKey_) required this.createdAt, @JsonKey(name: PublicReviewView.replyKey_) this.reply}): super._();
  factory _PublicReviewView.fromJson(Map<String, dynamic> json) => _$PublicReviewViewFromJson(json);

/// id
@override@JsonKey(name: PublicReviewView.idKey_) final  String id;
/// rating
@override@JsonKey(name: PublicReviewView.ratingKey_) final  int rating;
/// text
@override@JsonKey(name: PublicReviewView.textKey_) final  String? text;
/// wouldBookAgain
@override@JsonKey(name: PublicReviewView.wouldBookAgainKey_) final  bool wouldBookAgain;
/// niche
@override@JsonKey(name: PublicReviewView.nicheKey_) final  ReviewNicheView niche;
/// videoPlaybackId
@override@JsonKey(name: PublicReviewView.videoPlaybackIdKey_) final  String? videoPlaybackId;
/// createdAt
@override@JsonKey(name: PublicReviewView.createdAtKey_) final  DateTime createdAt;
/// reply
@override@JsonKey(name: PublicReviewView.replyKey_) final  ReviewReplyView? reply;

/// Create a copy of PublicReviewView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicReviewViewCopyWith<_PublicReviewView> get copyWith => __$PublicReviewViewCopyWithImpl<_PublicReviewView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicReviewViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicReviewView&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.text, text) || other.text == text)&&(identical(other.wouldBookAgain, wouldBookAgain) || other.wouldBookAgain == wouldBookAgain)&&(identical(other.niche, niche) || other.niche == niche)&&(identical(other.videoPlaybackId, videoPlaybackId) || other.videoPlaybackId == videoPlaybackId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reply, reply) || other.reply == reply));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,text,wouldBookAgain,niche,videoPlaybackId,createdAt,reply);

@override
String toString() {
  return 'PublicReviewView(id: $id, rating: $rating, text: $text, wouldBookAgain: $wouldBookAgain, niche: $niche, videoPlaybackId: $videoPlaybackId, createdAt: $createdAt, reply: $reply)';
}


}

/// @nodoc
abstract mixin class _$PublicReviewViewCopyWith<$Res> implements $PublicReviewViewCopyWith<$Res> {
  factory _$PublicReviewViewCopyWith(_PublicReviewView value, $Res Function(_PublicReviewView) _then) = __$PublicReviewViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PublicReviewView.idKey_) String id,@JsonKey(name: PublicReviewView.ratingKey_) int rating,@JsonKey(name: PublicReviewView.textKey_) String? text,@JsonKey(name: PublicReviewView.wouldBookAgainKey_) bool wouldBookAgain,@JsonKey(name: PublicReviewView.nicheKey_) ReviewNicheView niche,@JsonKey(name: PublicReviewView.videoPlaybackIdKey_) String? videoPlaybackId,@JsonKey(name: PublicReviewView.createdAtKey_) DateTime createdAt,@JsonKey(name: PublicReviewView.replyKey_) ReviewReplyView? reply
});


@override $ReviewNicheViewCopyWith<$Res> get niche;@override $ReviewReplyViewCopyWith<$Res>? get reply;

}
/// @nodoc
class __$PublicReviewViewCopyWithImpl<$Res>
    implements _$PublicReviewViewCopyWith<$Res> {
  __$PublicReviewViewCopyWithImpl(this._self, this._then);

  final _PublicReviewView _self;
  final $Res Function(_PublicReviewView) _then;

/// Create a copy of PublicReviewView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rating = null,Object? text = freezed,Object? wouldBookAgain = null,Object? niche = null,Object? videoPlaybackId = freezed,Object? createdAt = null,Object? reply = freezed,}) {
  return _then(_PublicReviewView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,wouldBookAgain: null == wouldBookAgain ? _self.wouldBookAgain : wouldBookAgain // ignore: cast_nullable_to_non_nullable
as bool,niche: null == niche ? _self.niche : niche // ignore: cast_nullable_to_non_nullable
as ReviewNicheView,videoPlaybackId: freezed == videoPlaybackId ? _self.videoPlaybackId : videoPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as ReviewReplyView?,
  ));
}

/// Create a copy of PublicReviewView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewNicheViewCopyWith<$Res> get niche {
  
  return $ReviewNicheViewCopyWith<$Res>(_self.niche, (value) {
    return _then(_self.copyWith(niche: value));
  });
}/// Create a copy of PublicReviewView
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
