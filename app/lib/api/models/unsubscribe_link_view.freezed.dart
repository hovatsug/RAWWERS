// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unsubscribe_link_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnsubscribeLinkView {

/// topic
@JsonKey(name: UnsubscribeLinkView.topicKey_) String get topic;/// topicLabel
@JsonKey(name: UnsubscribeLinkView.topicLabelKey_) String get topicLabel;/// all
@JsonKey(name: UnsubscribeLinkView.allKey_) UnsubscribeAllLink get all;
/// Create a copy of UnsubscribeLinkView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnsubscribeLinkViewCopyWith<UnsubscribeLinkView> get copyWith => _$UnsubscribeLinkViewCopyWithImpl<UnsubscribeLinkView>(this as UnsubscribeLinkView, _$identity);

  /// Serializes this UnsubscribeLinkView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnsubscribeLinkView&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.topicLabel, topicLabel) || other.topicLabel == topicLabel)&&(identical(other.all, all) || other.all == all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,topicLabel,all);

@override
String toString() {
  return 'UnsubscribeLinkView(topic: $topic, topicLabel: $topicLabel, all: $all)';
}


}

/// @nodoc
abstract mixin class $UnsubscribeLinkViewCopyWith<$Res>  {
  factory $UnsubscribeLinkViewCopyWith(UnsubscribeLinkView value, $Res Function(UnsubscribeLinkView) _then) = _$UnsubscribeLinkViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UnsubscribeLinkView.topicKey_) String topic,@JsonKey(name: UnsubscribeLinkView.topicLabelKey_) String topicLabel,@JsonKey(name: UnsubscribeLinkView.allKey_) UnsubscribeAllLink all
});


$UnsubscribeAllLinkCopyWith<$Res> get all;

}
/// @nodoc
class _$UnsubscribeLinkViewCopyWithImpl<$Res>
    implements $UnsubscribeLinkViewCopyWith<$Res> {
  _$UnsubscribeLinkViewCopyWithImpl(this._self, this._then);

  final UnsubscribeLinkView _self;
  final $Res Function(UnsubscribeLinkView) _then;

/// Create a copy of UnsubscribeLinkView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topic = null,Object? topicLabel = null,Object? all = null,}) {
  return _then(_self.copyWith(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,topicLabel: null == topicLabel ? _self.topicLabel : topicLabel // ignore: cast_nullable_to_non_nullable
as String,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as UnsubscribeAllLink,
  ));
}
/// Create a copy of UnsubscribeLinkView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnsubscribeAllLinkCopyWith<$Res> get all {
  
  return $UnsubscribeAllLinkCopyWith<$Res>(_self.all, (value) {
    return _then(_self.copyWith(all: value));
  });
}
}


/// Adds pattern-matching-related methods to [UnsubscribeLinkView].
extension UnsubscribeLinkViewPatterns on UnsubscribeLinkView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnsubscribeLinkView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnsubscribeLinkView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnsubscribeLinkView value)  $default,){
final _that = this;
switch (_that) {
case _UnsubscribeLinkView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnsubscribeLinkView value)?  $default,){
final _that = this;
switch (_that) {
case _UnsubscribeLinkView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UnsubscribeLinkView.topicKey_)  String topic, @JsonKey(name: UnsubscribeLinkView.topicLabelKey_)  String topicLabel, @JsonKey(name: UnsubscribeLinkView.allKey_)  UnsubscribeAllLink all)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnsubscribeLinkView() when $default != null:
return $default(_that.topic,_that.topicLabel,_that.all);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UnsubscribeLinkView.topicKey_)  String topic, @JsonKey(name: UnsubscribeLinkView.topicLabelKey_)  String topicLabel, @JsonKey(name: UnsubscribeLinkView.allKey_)  UnsubscribeAllLink all)  $default,) {final _that = this;
switch (_that) {
case _UnsubscribeLinkView():
return $default(_that.topic,_that.topicLabel,_that.all);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UnsubscribeLinkView.topicKey_)  String topic, @JsonKey(name: UnsubscribeLinkView.topicLabelKey_)  String topicLabel, @JsonKey(name: UnsubscribeLinkView.allKey_)  UnsubscribeAllLink all)?  $default,) {final _that = this;
switch (_that) {
case _UnsubscribeLinkView() when $default != null:
return $default(_that.topic,_that.topicLabel,_that.all);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UnsubscribeLinkView extends UnsubscribeLinkView {
  const _UnsubscribeLinkView({@JsonKey(name: UnsubscribeLinkView.topicKey_) required this.topic, @JsonKey(name: UnsubscribeLinkView.topicLabelKey_) required this.topicLabel, @JsonKey(name: UnsubscribeLinkView.allKey_) required this.all}): super._();
  factory _UnsubscribeLinkView.fromJson(Map<String, dynamic> json) => _$UnsubscribeLinkViewFromJson(json);

/// topic
@override@JsonKey(name: UnsubscribeLinkView.topicKey_) final  String topic;
/// topicLabel
@override@JsonKey(name: UnsubscribeLinkView.topicLabelKey_) final  String topicLabel;
/// all
@override@JsonKey(name: UnsubscribeLinkView.allKey_) final  UnsubscribeAllLink all;

/// Create a copy of UnsubscribeLinkView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnsubscribeLinkViewCopyWith<_UnsubscribeLinkView> get copyWith => __$UnsubscribeLinkViewCopyWithImpl<_UnsubscribeLinkView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnsubscribeLinkViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribeLinkView&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.topicLabel, topicLabel) || other.topicLabel == topicLabel)&&(identical(other.all, all) || other.all == all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,topicLabel,all);

@override
String toString() {
  return 'UnsubscribeLinkView(topic: $topic, topicLabel: $topicLabel, all: $all)';
}


}

/// @nodoc
abstract mixin class _$UnsubscribeLinkViewCopyWith<$Res> implements $UnsubscribeLinkViewCopyWith<$Res> {
  factory _$UnsubscribeLinkViewCopyWith(_UnsubscribeLinkView value, $Res Function(_UnsubscribeLinkView) _then) = __$UnsubscribeLinkViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UnsubscribeLinkView.topicKey_) String topic,@JsonKey(name: UnsubscribeLinkView.topicLabelKey_) String topicLabel,@JsonKey(name: UnsubscribeLinkView.allKey_) UnsubscribeAllLink all
});


@override $UnsubscribeAllLinkCopyWith<$Res> get all;

}
/// @nodoc
class __$UnsubscribeLinkViewCopyWithImpl<$Res>
    implements _$UnsubscribeLinkViewCopyWith<$Res> {
  __$UnsubscribeLinkViewCopyWithImpl(this._self, this._then);

  final _UnsubscribeLinkView _self;
  final $Res Function(_UnsubscribeLinkView) _then;

/// Create a copy of UnsubscribeLinkView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topic = null,Object? topicLabel = null,Object? all = null,}) {
  return _then(_UnsubscribeLinkView(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,topicLabel: null == topicLabel ? _self.topicLabel : topicLabel // ignore: cast_nullable_to_non_nullable
as String,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as UnsubscribeAllLink,
  ));
}

/// Create a copy of UnsubscribeLinkView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnsubscribeAllLinkCopyWith<$Res> get all {
  
  return $UnsubscribeAllLinkCopyWith<$Res>(_self.all, (value) {
    return _then(_self.copyWith(all: value));
  });
}
}

// dart format on
