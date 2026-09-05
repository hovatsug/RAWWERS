// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationAction {

/// label
@JsonKey(name: NotificationAction.labelKey_) String? get label;/// url
@JsonKey(name: NotificationAction.urlKey_) String? get url;
/// Create a copy of NotificationAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationActionCopyWith<NotificationAction> get copyWith => _$NotificationActionCopyWithImpl<NotificationAction>(this as NotificationAction, _$identity);

  /// Serializes this NotificationAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationAction&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'NotificationAction(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class $NotificationActionCopyWith<$Res>  {
  factory $NotificationActionCopyWith(NotificationAction value, $Res Function(NotificationAction) _then) = _$NotificationActionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NotificationAction.labelKey_) String? label,@JsonKey(name: NotificationAction.urlKey_) String? url
});




}
/// @nodoc
class _$NotificationActionCopyWithImpl<$Res>
    implements $NotificationActionCopyWith<$Res> {
  _$NotificationActionCopyWithImpl(this._self, this._then);

  final NotificationAction _self;
  final $Res Function(NotificationAction) _then;

/// Create a copy of NotificationAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = freezed,Object? url = freezed,}) {
  return _then(_self.copyWith(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationAction].
extension NotificationActionPatterns on NotificationAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationAction value)  $default,){
final _that = this;
switch (_that) {
case _NotificationAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationAction value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationAction.labelKey_)  String? label, @JsonKey(name: NotificationAction.urlKey_)  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationAction() when $default != null:
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationAction.labelKey_)  String? label, @JsonKey(name: NotificationAction.urlKey_)  String? url)  $default,) {final _that = this;
switch (_that) {
case _NotificationAction():
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NotificationAction.labelKey_)  String? label, @JsonKey(name: NotificationAction.urlKey_)  String? url)?  $default,) {final _that = this;
switch (_that) {
case _NotificationAction() when $default != null:
return $default(_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NotificationAction extends NotificationAction {
  const _NotificationAction({@JsonKey(name: NotificationAction.labelKey_) this.label, @JsonKey(name: NotificationAction.urlKey_) this.url}): super._();
  factory _NotificationAction.fromJson(Map<String, dynamic> json) => _$NotificationActionFromJson(json);

/// label
@override@JsonKey(name: NotificationAction.labelKey_) final  String? label;
/// url
@override@JsonKey(name: NotificationAction.urlKey_) final  String? url;

/// Create a copy of NotificationAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationActionCopyWith<_NotificationAction> get copyWith => __$NotificationActionCopyWithImpl<_NotificationAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationAction&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'NotificationAction(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$NotificationActionCopyWith<$Res> implements $NotificationActionCopyWith<$Res> {
  factory _$NotificationActionCopyWith(_NotificationAction value, $Res Function(_NotificationAction) _then) = __$NotificationActionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NotificationAction.labelKey_) String? label,@JsonKey(name: NotificationAction.urlKey_) String? url
});




}
/// @nodoc
class __$NotificationActionCopyWithImpl<$Res>
    implements _$NotificationActionCopyWith<$Res> {
  __$NotificationActionCopyWithImpl(this._self, this._then);

  final _NotificationAction _self;
  final $Res Function(_NotificationAction) _then;

/// Create a copy of NotificationAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = freezed,Object? url = freezed,}) {
  return _then(_NotificationAction(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
