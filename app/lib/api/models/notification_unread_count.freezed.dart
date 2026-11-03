// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_unread_count.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationUnreadCount {

/// count
@JsonKey(name: NotificationUnreadCount.countKey_) int get count;
/// Create a copy of NotificationUnreadCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationUnreadCountCopyWith<NotificationUnreadCount> get copyWith => _$NotificationUnreadCountCopyWithImpl<NotificationUnreadCount>(this as NotificationUnreadCount, _$identity);

  /// Serializes this NotificationUnreadCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationUnreadCount&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'NotificationUnreadCount(count: $count)';
}


}

/// @nodoc
abstract mixin class $NotificationUnreadCountCopyWith<$Res>  {
  factory $NotificationUnreadCountCopyWith(NotificationUnreadCount value, $Res Function(NotificationUnreadCount) _then) = _$NotificationUnreadCountCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NotificationUnreadCount.countKey_) int count
});




}
/// @nodoc
class _$NotificationUnreadCountCopyWithImpl<$Res>
    implements $NotificationUnreadCountCopyWith<$Res> {
  _$NotificationUnreadCountCopyWithImpl(this._self, this._then);

  final NotificationUnreadCount _self;
  final $Res Function(NotificationUnreadCount) _then;

/// Create a copy of NotificationUnreadCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationUnreadCount].
extension NotificationUnreadCountPatterns on NotificationUnreadCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationUnreadCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationUnreadCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationUnreadCount value)  $default,){
final _that = this;
switch (_that) {
case _NotificationUnreadCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationUnreadCount value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationUnreadCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationUnreadCount.countKey_)  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationUnreadCount() when $default != null:
return $default(_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationUnreadCount.countKey_)  int count)  $default,) {final _that = this;
switch (_that) {
case _NotificationUnreadCount():
return $default(_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NotificationUnreadCount.countKey_)  int count)?  $default,) {final _that = this;
switch (_that) {
case _NotificationUnreadCount() when $default != null:
return $default(_that.count);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NotificationUnreadCount extends NotificationUnreadCount {
  const _NotificationUnreadCount({@JsonKey(name: NotificationUnreadCount.countKey_) required this.count}): super._();
  factory _NotificationUnreadCount.fromJson(Map<String, dynamic> json) => _$NotificationUnreadCountFromJson(json);

/// count
@override@JsonKey(name: NotificationUnreadCount.countKey_) final  int count;

/// Create a copy of NotificationUnreadCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationUnreadCountCopyWith<_NotificationUnreadCount> get copyWith => __$NotificationUnreadCountCopyWithImpl<_NotificationUnreadCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationUnreadCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationUnreadCount&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'NotificationUnreadCount(count: $count)';
}


}

/// @nodoc
abstract mixin class _$NotificationUnreadCountCopyWith<$Res> implements $NotificationUnreadCountCopyWith<$Res> {
  factory _$NotificationUnreadCountCopyWith(_NotificationUnreadCount value, $Res Function(_NotificationUnreadCount) _then) = __$NotificationUnreadCountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NotificationUnreadCount.countKey_) int count
});




}
/// @nodoc
class __$NotificationUnreadCountCopyWithImpl<$Res>
    implements _$NotificationUnreadCountCopyWith<$Res> {
  __$NotificationUnreadCountCopyWithImpl(this._self, this._then);

  final _NotificationUnreadCount _self;
  final $Res Function(_NotificationUnreadCount) _then;

/// Create a copy of NotificationUnreadCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(_NotificationUnreadCount(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
