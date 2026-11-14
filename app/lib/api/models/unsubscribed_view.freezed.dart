// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unsubscribed_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnsubscribedView {

/// topic
@JsonKey(name: UnsubscribedView.topicKey_) String get topic;/// unsubscribed
@JsonKey(name: UnsubscribedView.unsubscribedKey_) bool get unsubscribed;
/// Create a copy of UnsubscribedView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnsubscribedViewCopyWith<UnsubscribedView> get copyWith => _$UnsubscribedViewCopyWithImpl<UnsubscribedView>(this as UnsubscribedView, _$identity);

  /// Serializes this UnsubscribedView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnsubscribedView&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.unsubscribed, unsubscribed) || other.unsubscribed == unsubscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,unsubscribed);

@override
String toString() {
  return 'UnsubscribedView(topic: $topic, unsubscribed: $unsubscribed)';
}


}

/// @nodoc
abstract mixin class $UnsubscribedViewCopyWith<$Res>  {
  factory $UnsubscribedViewCopyWith(UnsubscribedView value, $Res Function(UnsubscribedView) _then) = _$UnsubscribedViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UnsubscribedView.topicKey_) String topic,@JsonKey(name: UnsubscribedView.unsubscribedKey_) bool unsubscribed
});




}
/// @nodoc
class _$UnsubscribedViewCopyWithImpl<$Res>
    implements $UnsubscribedViewCopyWith<$Res> {
  _$UnsubscribedViewCopyWithImpl(this._self, this._then);

  final UnsubscribedView _self;
  final $Res Function(UnsubscribedView) _then;

/// Create a copy of UnsubscribedView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topic = null,Object? unsubscribed = null,}) {
  return _then(_self.copyWith(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,unsubscribed: null == unsubscribed ? _self.unsubscribed : unsubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UnsubscribedView].
extension UnsubscribedViewPatterns on UnsubscribedView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnsubscribedView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnsubscribedView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnsubscribedView value)  $default,){
final _that = this;
switch (_that) {
case _UnsubscribedView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnsubscribedView value)?  $default,){
final _that = this;
switch (_that) {
case _UnsubscribedView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UnsubscribedView.topicKey_)  String topic, @JsonKey(name: UnsubscribedView.unsubscribedKey_)  bool unsubscribed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnsubscribedView() when $default != null:
return $default(_that.topic,_that.unsubscribed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UnsubscribedView.topicKey_)  String topic, @JsonKey(name: UnsubscribedView.unsubscribedKey_)  bool unsubscribed)  $default,) {final _that = this;
switch (_that) {
case _UnsubscribedView():
return $default(_that.topic,_that.unsubscribed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UnsubscribedView.topicKey_)  String topic, @JsonKey(name: UnsubscribedView.unsubscribedKey_)  bool unsubscribed)?  $default,) {final _that = this;
switch (_that) {
case _UnsubscribedView() when $default != null:
return $default(_that.topic,_that.unsubscribed);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UnsubscribedView extends UnsubscribedView {
  const _UnsubscribedView({@JsonKey(name: UnsubscribedView.topicKey_) required this.topic, @JsonKey(name: UnsubscribedView.unsubscribedKey_) required this.unsubscribed}): super._();
  factory _UnsubscribedView.fromJson(Map<String, dynamic> json) => _$UnsubscribedViewFromJson(json);

/// topic
@override@JsonKey(name: UnsubscribedView.topicKey_) final  String topic;
/// unsubscribed
@override@JsonKey(name: UnsubscribedView.unsubscribedKey_) final  bool unsubscribed;

/// Create a copy of UnsubscribedView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnsubscribedViewCopyWith<_UnsubscribedView> get copyWith => __$UnsubscribedViewCopyWithImpl<_UnsubscribedView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnsubscribedViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribedView&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.unsubscribed, unsubscribed) || other.unsubscribed == unsubscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,unsubscribed);

@override
String toString() {
  return 'UnsubscribedView(topic: $topic, unsubscribed: $unsubscribed)';
}


}

/// @nodoc
abstract mixin class _$UnsubscribedViewCopyWith<$Res> implements $UnsubscribedViewCopyWith<$Res> {
  factory _$UnsubscribedViewCopyWith(_UnsubscribedView value, $Res Function(_UnsubscribedView) _then) = __$UnsubscribedViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UnsubscribedView.topicKey_) String topic,@JsonKey(name: UnsubscribedView.unsubscribedKey_) bool unsubscribed
});




}
/// @nodoc
class __$UnsubscribedViewCopyWithImpl<$Res>
    implements _$UnsubscribedViewCopyWith<$Res> {
  __$UnsubscribedViewCopyWithImpl(this._self, this._then);

  final _UnsubscribedView _self;
  final $Res Function(_UnsubscribedView) _then;

/// Create a copy of UnsubscribedView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topic = null,Object? unsubscribed = null,}) {
  return _then(_UnsubscribedView(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,unsubscribed: null == unsubscribed ? _self.unsubscribed : unsubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
