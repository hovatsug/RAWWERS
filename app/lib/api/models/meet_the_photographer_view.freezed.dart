// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meet_the_photographer_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeetThePhotographerView {

/// video
@JsonKey(name: MeetThePhotographerView.videoKey_) PresentationVideoView? get video;/// interview
@JsonKey(name: MeetThePhotographerView.interviewKey_) List<MeetInterviewItem>? get interview;
/// Create a copy of MeetThePhotographerView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetThePhotographerViewCopyWith<MeetThePhotographerView> get copyWith => _$MeetThePhotographerViewCopyWithImpl<MeetThePhotographerView>(this as MeetThePhotographerView, _$identity);

  /// Serializes this MeetThePhotographerView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetThePhotographerView&&(identical(other.video, video) || other.video == video)&&const DeepCollectionEquality().equals(other.interview, interview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,video,const DeepCollectionEquality().hash(interview));

@override
String toString() {
  return 'MeetThePhotographerView(video: $video, interview: $interview)';
}


}

/// @nodoc
abstract mixin class $MeetThePhotographerViewCopyWith<$Res>  {
  factory $MeetThePhotographerViewCopyWith(MeetThePhotographerView value, $Res Function(MeetThePhotographerView) _then) = _$MeetThePhotographerViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MeetThePhotographerView.videoKey_) PresentationVideoView? video,@JsonKey(name: MeetThePhotographerView.interviewKey_) List<MeetInterviewItem>? interview
});


$PresentationVideoViewCopyWith<$Res>? get video;

}
/// @nodoc
class _$MeetThePhotographerViewCopyWithImpl<$Res>
    implements $MeetThePhotographerViewCopyWith<$Res> {
  _$MeetThePhotographerViewCopyWithImpl(this._self, this._then);

  final MeetThePhotographerView _self;
  final $Res Function(MeetThePhotographerView) _then;

/// Create a copy of MeetThePhotographerView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? video = freezed,Object? interview = freezed,}) {
  return _then(_self.copyWith(
video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as PresentationVideoView?,interview: freezed == interview ? _self.interview : interview // ignore: cast_nullable_to_non_nullable
as List<MeetInterviewItem>?,
  ));
}
/// Create a copy of MeetThePhotographerView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresentationVideoViewCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $PresentationVideoViewCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeetThePhotographerView].
extension MeetThePhotographerViewPatterns on MeetThePhotographerView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetThePhotographerView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetThePhotographerView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetThePhotographerView value)  $default,){
final _that = this;
switch (_that) {
case _MeetThePhotographerView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetThePhotographerView value)?  $default,){
final _that = this;
switch (_that) {
case _MeetThePhotographerView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MeetThePhotographerView.videoKey_)  PresentationVideoView? video, @JsonKey(name: MeetThePhotographerView.interviewKey_)  List<MeetInterviewItem>? interview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetThePhotographerView() when $default != null:
return $default(_that.video,_that.interview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MeetThePhotographerView.videoKey_)  PresentationVideoView? video, @JsonKey(name: MeetThePhotographerView.interviewKey_)  List<MeetInterviewItem>? interview)  $default,) {final _that = this;
switch (_that) {
case _MeetThePhotographerView():
return $default(_that.video,_that.interview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MeetThePhotographerView.videoKey_)  PresentationVideoView? video, @JsonKey(name: MeetThePhotographerView.interviewKey_)  List<MeetInterviewItem>? interview)?  $default,) {final _that = this;
switch (_that) {
case _MeetThePhotographerView() when $default != null:
return $default(_that.video,_that.interview);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MeetThePhotographerView extends MeetThePhotographerView {
  const _MeetThePhotographerView({@JsonKey(name: MeetThePhotographerView.videoKey_) this.video, @JsonKey(name: MeetThePhotographerView.interviewKey_) final  List<MeetInterviewItem>? interview}): _interview = interview,super._();
  factory _MeetThePhotographerView.fromJson(Map<String, dynamic> json) => _$MeetThePhotographerViewFromJson(json);

/// video
@override@JsonKey(name: MeetThePhotographerView.videoKey_) final  PresentationVideoView? video;
/// interview
 final  List<MeetInterviewItem>? _interview;
/// interview
@override@JsonKey(name: MeetThePhotographerView.interviewKey_) List<MeetInterviewItem>? get interview {
  final value = _interview;
  if (value == null) return null;
  if (_interview is EqualUnmodifiableListView) return _interview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MeetThePhotographerView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetThePhotographerViewCopyWith<_MeetThePhotographerView> get copyWith => __$MeetThePhotographerViewCopyWithImpl<_MeetThePhotographerView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeetThePhotographerViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetThePhotographerView&&(identical(other.video, video) || other.video == video)&&const DeepCollectionEquality().equals(other._interview, _interview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,video,const DeepCollectionEquality().hash(_interview));

@override
String toString() {
  return 'MeetThePhotographerView(video: $video, interview: $interview)';
}


}

/// @nodoc
abstract mixin class _$MeetThePhotographerViewCopyWith<$Res> implements $MeetThePhotographerViewCopyWith<$Res> {
  factory _$MeetThePhotographerViewCopyWith(_MeetThePhotographerView value, $Res Function(_MeetThePhotographerView) _then) = __$MeetThePhotographerViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MeetThePhotographerView.videoKey_) PresentationVideoView? video,@JsonKey(name: MeetThePhotographerView.interviewKey_) List<MeetInterviewItem>? interview
});


@override $PresentationVideoViewCopyWith<$Res>? get video;

}
/// @nodoc
class __$MeetThePhotographerViewCopyWithImpl<$Res>
    implements _$MeetThePhotographerViewCopyWith<$Res> {
  __$MeetThePhotographerViewCopyWithImpl(this._self, this._then);

  final _MeetThePhotographerView _self;
  final $Res Function(_MeetThePhotographerView) _then;

/// Create a copy of MeetThePhotographerView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? video = freezed,Object? interview = freezed,}) {
  return _then(_MeetThePhotographerView(
video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as PresentationVideoView?,interview: freezed == interview ? _self._interview : interview // ignore: cast_nullable_to_non_nullable
as List<MeetInterviewItem>?,
  ));
}

/// Create a copy of MeetThePhotographerView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresentationVideoViewCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $PresentationVideoViewCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}
}

// dart format on
