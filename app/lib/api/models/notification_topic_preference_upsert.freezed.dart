// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_topic_preference_upsert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationTopicPreferenceUpsert {

/// topic
@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_) String get topic;/// emailEnabled
@JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_) bool get emailEnabled;/// inappEnabled
@JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_) bool get inappEnabled;
/// Create a copy of NotificationTopicPreferenceUpsert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationTopicPreferenceUpsertCopyWith<NotificationTopicPreferenceUpsert> get copyWith => _$NotificationTopicPreferenceUpsertCopyWithImpl<NotificationTopicPreferenceUpsert>(this as NotificationTopicPreferenceUpsert, _$identity);

  /// Serializes this NotificationTopicPreferenceUpsert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationTopicPreferenceUpsert&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.inappEnabled, inappEnabled) || other.inappEnabled == inappEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,emailEnabled,inappEnabled);

@override
String toString() {
  return 'NotificationTopicPreferenceUpsert(topic: $topic, emailEnabled: $emailEnabled, inappEnabled: $inappEnabled)';
}


}

/// @nodoc
abstract mixin class $NotificationTopicPreferenceUpsertCopyWith<$Res>  {
  factory $NotificationTopicPreferenceUpsertCopyWith(NotificationTopicPreferenceUpsert value, $Res Function(NotificationTopicPreferenceUpsert) _then) = _$NotificationTopicPreferenceUpsertCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_) String topic,@JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_) bool emailEnabled,@JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_) bool inappEnabled
});




}
/// @nodoc
class _$NotificationTopicPreferenceUpsertCopyWithImpl<$Res>
    implements $NotificationTopicPreferenceUpsertCopyWith<$Res> {
  _$NotificationTopicPreferenceUpsertCopyWithImpl(this._self, this._then);

  final NotificationTopicPreferenceUpsert _self;
  final $Res Function(NotificationTopicPreferenceUpsert) _then;

/// Create a copy of NotificationTopicPreferenceUpsert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topic = null,Object? emailEnabled = null,Object? inappEnabled = null,}) {
  return _then(_self.copyWith(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,inappEnabled: null == inappEnabled ? _self.inappEnabled : inappEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationTopicPreferenceUpsert].
extension NotificationTopicPreferenceUpsertPatterns on NotificationTopicPreferenceUpsert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationTopicPreferenceUpsert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationTopicPreferenceUpsert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationTopicPreferenceUpsert value)  $default,){
final _that = this;
switch (_that) {
case _NotificationTopicPreferenceUpsert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationTopicPreferenceUpsert value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationTopicPreferenceUpsert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_)  String topic, @JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_)  bool emailEnabled, @JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_)  bool inappEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationTopicPreferenceUpsert() when $default != null:
return $default(_that.topic,_that.emailEnabled,_that.inappEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_)  String topic, @JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_)  bool emailEnabled, @JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_)  bool inappEnabled)  $default,) {final _that = this;
switch (_that) {
case _NotificationTopicPreferenceUpsert():
return $default(_that.topic,_that.emailEnabled,_that.inappEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_)  String topic, @JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_)  bool emailEnabled, @JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_)  bool inappEnabled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationTopicPreferenceUpsert() when $default != null:
return $default(_that.topic,_that.emailEnabled,_that.inappEnabled);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NotificationTopicPreferenceUpsert extends NotificationTopicPreferenceUpsert {
  const _NotificationTopicPreferenceUpsert({@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_) required this.topic, @JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_) this.emailEnabled = true, @JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_) this.inappEnabled = true}): super._();
  factory _NotificationTopicPreferenceUpsert.fromJson(Map<String, dynamic> json) => _$NotificationTopicPreferenceUpsertFromJson(json);

/// topic
@override@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_) final  String topic;
/// emailEnabled
@override@JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_) final  bool emailEnabled;
/// inappEnabled
@override@JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_) final  bool inappEnabled;

/// Create a copy of NotificationTopicPreferenceUpsert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationTopicPreferenceUpsertCopyWith<_NotificationTopicPreferenceUpsert> get copyWith => __$NotificationTopicPreferenceUpsertCopyWithImpl<_NotificationTopicPreferenceUpsert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationTopicPreferenceUpsertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationTopicPreferenceUpsert&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.inappEnabled, inappEnabled) || other.inappEnabled == inappEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,emailEnabled,inappEnabled);

@override
String toString() {
  return 'NotificationTopicPreferenceUpsert(topic: $topic, emailEnabled: $emailEnabled, inappEnabled: $inappEnabled)';
}


}

/// @nodoc
abstract mixin class _$NotificationTopicPreferenceUpsertCopyWith<$Res> implements $NotificationTopicPreferenceUpsertCopyWith<$Res> {
  factory _$NotificationTopicPreferenceUpsertCopyWith(_NotificationTopicPreferenceUpsert value, $Res Function(_NotificationTopicPreferenceUpsert) _then) = __$NotificationTopicPreferenceUpsertCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_) String topic,@JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_) bool emailEnabled,@JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_) bool inappEnabled
});




}
/// @nodoc
class __$NotificationTopicPreferenceUpsertCopyWithImpl<$Res>
    implements _$NotificationTopicPreferenceUpsertCopyWith<$Res> {
  __$NotificationTopicPreferenceUpsertCopyWithImpl(this._self, this._then);

  final _NotificationTopicPreferenceUpsert _self;
  final $Res Function(_NotificationTopicPreferenceUpsert) _then;

/// Create a copy of NotificationTopicPreferenceUpsert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topic = null,Object? emailEnabled = null,Object? inappEnabled = null,}) {
  return _then(_NotificationTopicPreferenceUpsert(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,inappEnabled: null == inappEnabled ? _self.inappEnabled : inappEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
