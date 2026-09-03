// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationView {

/// id
@JsonKey(name: NotificationView.idKey_) String get id;/// topic
@JsonKey(name: NotificationView.topicKey_) String get topic;/// type
@JsonKey(name: NotificationView.typeKey_) String get type;/// title
@JsonKey(name: NotificationView.titleKey_) String get title;/// body
@JsonKey(name: NotificationView.bodyKey_) String get body;/// action
@JsonKey(name: NotificationView.actionKey_) NotificationAction? get action;/// severity
@JsonKey(name: NotificationView.severityKey_) NotificationSeverity get severity;/// readAt
@JsonKey(name: NotificationView.readAtKey_) DateTime? get readAt;/// createdAt
@JsonKey(name: NotificationView.createdAtKey_) DateTime get createdAt;/// metadata
@JsonKey(name: NotificationView.metadataKey_) Map<String, dynamic>? get metadata;
/// Create a copy of NotificationView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationViewCopyWith<NotificationView> get copyWith => _$NotificationViewCopyWithImpl<NotificationView>(this as NotificationView, _$identity);

  /// Serializes this NotificationView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationView&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.action, action) || other.action == action)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topic,type,title,body,action,severity,readAt,createdAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'NotificationView(id: $id, topic: $topic, type: $type, title: $title, body: $body, action: $action, severity: $severity, readAt: $readAt, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $NotificationViewCopyWith<$Res>  {
  factory $NotificationViewCopyWith(NotificationView value, $Res Function(NotificationView) _then) = _$NotificationViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NotificationView.idKey_) String id,@JsonKey(name: NotificationView.topicKey_) String topic,@JsonKey(name: NotificationView.typeKey_) String type,@JsonKey(name: NotificationView.titleKey_) String title,@JsonKey(name: NotificationView.bodyKey_) String body,@JsonKey(name: NotificationView.actionKey_) NotificationAction? action,@JsonKey(name: NotificationView.severityKey_) NotificationSeverity severity,@JsonKey(name: NotificationView.readAtKey_) DateTime? readAt,@JsonKey(name: NotificationView.createdAtKey_) DateTime createdAt,@JsonKey(name: NotificationView.metadataKey_) Map<String, dynamic>? metadata
});


$NotificationActionCopyWith<$Res>? get action;

}
/// @nodoc
class _$NotificationViewCopyWithImpl<$Res>
    implements $NotificationViewCopyWith<$Res> {
  _$NotificationViewCopyWithImpl(this._self, this._then);

  final NotificationView _self;
  final $Res Function(NotificationView) _then;

/// Create a copy of NotificationView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? topic = null,Object? type = null,Object? title = null,Object? body = null,Object? action = freezed,Object? severity = null,Object? readAt = freezed,Object? createdAt = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as NotificationAction?,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as NotificationSeverity,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of NotificationView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationActionCopyWith<$Res>? get action {
    if (_self.action == null) {
    return null;
  }

  return $NotificationActionCopyWith<$Res>(_self.action!, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationView].
extension NotificationViewPatterns on NotificationView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationView value)  $default,){
final _that = this;
switch (_that) {
case _NotificationView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationView value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationView.idKey_)  String id, @JsonKey(name: NotificationView.topicKey_)  String topic, @JsonKey(name: NotificationView.typeKey_)  String type, @JsonKey(name: NotificationView.titleKey_)  String title, @JsonKey(name: NotificationView.bodyKey_)  String body, @JsonKey(name: NotificationView.actionKey_)  NotificationAction? action, @JsonKey(name: NotificationView.severityKey_)  NotificationSeverity severity, @JsonKey(name: NotificationView.readAtKey_)  DateTime? readAt, @JsonKey(name: NotificationView.createdAtKey_)  DateTime createdAt, @JsonKey(name: NotificationView.metadataKey_)  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationView() when $default != null:
return $default(_that.id,_that.topic,_that.type,_that.title,_that.body,_that.action,_that.severity,_that.readAt,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationView.idKey_)  String id, @JsonKey(name: NotificationView.topicKey_)  String topic, @JsonKey(name: NotificationView.typeKey_)  String type, @JsonKey(name: NotificationView.titleKey_)  String title, @JsonKey(name: NotificationView.bodyKey_)  String body, @JsonKey(name: NotificationView.actionKey_)  NotificationAction? action, @JsonKey(name: NotificationView.severityKey_)  NotificationSeverity severity, @JsonKey(name: NotificationView.readAtKey_)  DateTime? readAt, @JsonKey(name: NotificationView.createdAtKey_)  DateTime createdAt, @JsonKey(name: NotificationView.metadataKey_)  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _NotificationView():
return $default(_that.id,_that.topic,_that.type,_that.title,_that.body,_that.action,_that.severity,_that.readAt,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NotificationView.idKey_)  String id, @JsonKey(name: NotificationView.topicKey_)  String topic, @JsonKey(name: NotificationView.typeKey_)  String type, @JsonKey(name: NotificationView.titleKey_)  String title, @JsonKey(name: NotificationView.bodyKey_)  String body, @JsonKey(name: NotificationView.actionKey_)  NotificationAction? action, @JsonKey(name: NotificationView.severityKey_)  NotificationSeverity severity, @JsonKey(name: NotificationView.readAtKey_)  DateTime? readAt, @JsonKey(name: NotificationView.createdAtKey_)  DateTime createdAt, @JsonKey(name: NotificationView.metadataKey_)  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _NotificationView() when $default != null:
return $default(_that.id,_that.topic,_that.type,_that.title,_that.body,_that.action,_that.severity,_that.readAt,_that.createdAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NotificationView extends NotificationView {
  const _NotificationView({@JsonKey(name: NotificationView.idKey_) required this.id, @JsonKey(name: NotificationView.topicKey_) required this.topic, @JsonKey(name: NotificationView.typeKey_) required this.type, @JsonKey(name: NotificationView.titleKey_) required this.title, @JsonKey(name: NotificationView.bodyKey_) required this.body, @JsonKey(name: NotificationView.actionKey_) this.action, @JsonKey(name: NotificationView.severityKey_) required this.severity, @JsonKey(name: NotificationView.readAtKey_) required this.readAt, @JsonKey(name: NotificationView.createdAtKey_) required this.createdAt, @JsonKey(name: NotificationView.metadataKey_) final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _NotificationView.fromJson(Map<String, dynamic> json) => _$NotificationViewFromJson(json);

/// id
@override@JsonKey(name: NotificationView.idKey_) final  String id;
/// topic
@override@JsonKey(name: NotificationView.topicKey_) final  String topic;
/// type
@override@JsonKey(name: NotificationView.typeKey_) final  String type;
/// title
@override@JsonKey(name: NotificationView.titleKey_) final  String title;
/// body
@override@JsonKey(name: NotificationView.bodyKey_) final  String body;
/// action
@override@JsonKey(name: NotificationView.actionKey_) final  NotificationAction? action;
/// severity
@override@JsonKey(name: NotificationView.severityKey_) final  NotificationSeverity severity;
/// readAt
@override@JsonKey(name: NotificationView.readAtKey_) final  DateTime? readAt;
/// createdAt
@override@JsonKey(name: NotificationView.createdAtKey_) final  DateTime createdAt;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: NotificationView.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of NotificationView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationViewCopyWith<_NotificationView> get copyWith => __$NotificationViewCopyWithImpl<_NotificationView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationView&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.action, action) || other.action == action)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topic,type,title,body,action,severity,readAt,createdAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'NotificationView(id: $id, topic: $topic, type: $type, title: $title, body: $body, action: $action, severity: $severity, readAt: $readAt, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$NotificationViewCopyWith<$Res> implements $NotificationViewCopyWith<$Res> {
  factory _$NotificationViewCopyWith(_NotificationView value, $Res Function(_NotificationView) _then) = __$NotificationViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NotificationView.idKey_) String id,@JsonKey(name: NotificationView.topicKey_) String topic,@JsonKey(name: NotificationView.typeKey_) String type,@JsonKey(name: NotificationView.titleKey_) String title,@JsonKey(name: NotificationView.bodyKey_) String body,@JsonKey(name: NotificationView.actionKey_) NotificationAction? action,@JsonKey(name: NotificationView.severityKey_) NotificationSeverity severity,@JsonKey(name: NotificationView.readAtKey_) DateTime? readAt,@JsonKey(name: NotificationView.createdAtKey_) DateTime createdAt,@JsonKey(name: NotificationView.metadataKey_) Map<String, dynamic>? metadata
});


@override $NotificationActionCopyWith<$Res>? get action;

}
/// @nodoc
class __$NotificationViewCopyWithImpl<$Res>
    implements _$NotificationViewCopyWith<$Res> {
  __$NotificationViewCopyWithImpl(this._self, this._then);

  final _NotificationView _self;
  final $Res Function(_NotificationView) _then;

/// Create a copy of NotificationView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? topic = null,Object? type = null,Object? title = null,Object? body = null,Object? action = freezed,Object? severity = null,Object? readAt = freezed,Object? createdAt = null,Object? metadata = freezed,}) {
  return _then(_NotificationView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as NotificationAction?,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as NotificationSeverity,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of NotificationView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationActionCopyWith<$Res>? get action {
    if (_self.action == null) {
    return null;
  }

  return $NotificationActionCopyWith<$Res>(_self.action!, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}

// dart format on
