// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preference_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationPreferenceView {

/// timezone
@JsonKey(name: NotificationPreferenceView.timezoneKey_) String get timezone;/// quietHoursEnabled
@JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_) bool get quietHoursEnabled;/// quietStartLocal
@JsonKey(name: NotificationPreferenceView.quietStartLocalKey_) String? get quietStartLocal;/// quietEndLocal
@JsonKey(name: NotificationPreferenceView.quietEndLocalKey_) String? get quietEndLocal;/// channelEmailEnabled
@JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_) bool get channelEmailEnabled;/// channelInappEnabled
@JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_) bool get channelInappEnabled;/// digestMode
@JsonKey(name: NotificationPreferenceView.digestModeKey_) NotificationDigestMode get digestMode;
/// Create a copy of NotificationPreferenceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferenceViewCopyWith<NotificationPreferenceView> get copyWith => _$NotificationPreferenceViewCopyWithImpl<NotificationPreferenceView>(this as NotificationPreferenceView, _$identity);

  /// Serializes this NotificationPreferenceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferenceView&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.quietHoursEnabled, quietHoursEnabled) || other.quietHoursEnabled == quietHoursEnabled)&&(identical(other.quietStartLocal, quietStartLocal) || other.quietStartLocal == quietStartLocal)&&(identical(other.quietEndLocal, quietEndLocal) || other.quietEndLocal == quietEndLocal)&&(identical(other.channelEmailEnabled, channelEmailEnabled) || other.channelEmailEnabled == channelEmailEnabled)&&(identical(other.channelInappEnabled, channelInappEnabled) || other.channelInappEnabled == channelInappEnabled)&&(identical(other.digestMode, digestMode) || other.digestMode == digestMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timezone,quietHoursEnabled,quietStartLocal,quietEndLocal,channelEmailEnabled,channelInappEnabled,digestMode);

@override
String toString() {
  return 'NotificationPreferenceView(timezone: $timezone, quietHoursEnabled: $quietHoursEnabled, quietStartLocal: $quietStartLocal, quietEndLocal: $quietEndLocal, channelEmailEnabled: $channelEmailEnabled, channelInappEnabled: $channelInappEnabled, digestMode: $digestMode)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferenceViewCopyWith<$Res>  {
  factory $NotificationPreferenceViewCopyWith(NotificationPreferenceView value, $Res Function(NotificationPreferenceView) _then) = _$NotificationPreferenceViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NotificationPreferenceView.timezoneKey_) String timezone,@JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_) bool quietHoursEnabled,@JsonKey(name: NotificationPreferenceView.quietStartLocalKey_) String? quietStartLocal,@JsonKey(name: NotificationPreferenceView.quietEndLocalKey_) String? quietEndLocal,@JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_) bool channelEmailEnabled,@JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_) bool channelInappEnabled,@JsonKey(name: NotificationPreferenceView.digestModeKey_) NotificationDigestMode digestMode
});




}
/// @nodoc
class _$NotificationPreferenceViewCopyWithImpl<$Res>
    implements $NotificationPreferenceViewCopyWith<$Res> {
  _$NotificationPreferenceViewCopyWithImpl(this._self, this._then);

  final NotificationPreferenceView _self;
  final $Res Function(NotificationPreferenceView) _then;

/// Create a copy of NotificationPreferenceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timezone = null,Object? quietHoursEnabled = null,Object? quietStartLocal = freezed,Object? quietEndLocal = freezed,Object? channelEmailEnabled = null,Object? channelInappEnabled = null,Object? digestMode = null,}) {
  return _then(_self.copyWith(
timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietStartLocal: freezed == quietStartLocal ? _self.quietStartLocal : quietStartLocal // ignore: cast_nullable_to_non_nullable
as String?,quietEndLocal: freezed == quietEndLocal ? _self.quietEndLocal : quietEndLocal // ignore: cast_nullable_to_non_nullable
as String?,channelEmailEnabled: null == channelEmailEnabled ? _self.channelEmailEnabled : channelEmailEnabled // ignore: cast_nullable_to_non_nullable
as bool,channelInappEnabled: null == channelInappEnabled ? _self.channelInappEnabled : channelInappEnabled // ignore: cast_nullable_to_non_nullable
as bool,digestMode: null == digestMode ? _self.digestMode : digestMode // ignore: cast_nullable_to_non_nullable
as NotificationDigestMode,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferenceView].
extension NotificationPreferenceViewPatterns on NotificationPreferenceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferenceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferenceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferenceView value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferenceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferenceView value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferenceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationPreferenceView.timezoneKey_)  String timezone, @JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_)  bool quietHoursEnabled, @JsonKey(name: NotificationPreferenceView.quietStartLocalKey_)  String? quietStartLocal, @JsonKey(name: NotificationPreferenceView.quietEndLocalKey_)  String? quietEndLocal, @JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_)  bool channelEmailEnabled, @JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_)  bool channelInappEnabled, @JsonKey(name: NotificationPreferenceView.digestModeKey_)  NotificationDigestMode digestMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferenceView() when $default != null:
return $default(_that.timezone,_that.quietHoursEnabled,_that.quietStartLocal,_that.quietEndLocal,_that.channelEmailEnabled,_that.channelInappEnabled,_that.digestMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NotificationPreferenceView.timezoneKey_)  String timezone, @JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_)  bool quietHoursEnabled, @JsonKey(name: NotificationPreferenceView.quietStartLocalKey_)  String? quietStartLocal, @JsonKey(name: NotificationPreferenceView.quietEndLocalKey_)  String? quietEndLocal, @JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_)  bool channelEmailEnabled, @JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_)  bool channelInappEnabled, @JsonKey(name: NotificationPreferenceView.digestModeKey_)  NotificationDigestMode digestMode)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferenceView():
return $default(_that.timezone,_that.quietHoursEnabled,_that.quietStartLocal,_that.quietEndLocal,_that.channelEmailEnabled,_that.channelInappEnabled,_that.digestMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NotificationPreferenceView.timezoneKey_)  String timezone, @JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_)  bool quietHoursEnabled, @JsonKey(name: NotificationPreferenceView.quietStartLocalKey_)  String? quietStartLocal, @JsonKey(name: NotificationPreferenceView.quietEndLocalKey_)  String? quietEndLocal, @JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_)  bool channelEmailEnabled, @JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_)  bool channelInappEnabled, @JsonKey(name: NotificationPreferenceView.digestModeKey_)  NotificationDigestMode digestMode)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferenceView() when $default != null:
return $default(_that.timezone,_that.quietHoursEnabled,_that.quietStartLocal,_that.quietEndLocal,_that.channelEmailEnabled,_that.channelInappEnabled,_that.digestMode);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NotificationPreferenceView extends NotificationPreferenceView {
  const _NotificationPreferenceView({@JsonKey(name: NotificationPreferenceView.timezoneKey_) required this.timezone, @JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_) required this.quietHoursEnabled, @JsonKey(name: NotificationPreferenceView.quietStartLocalKey_) this.quietStartLocal, @JsonKey(name: NotificationPreferenceView.quietEndLocalKey_) this.quietEndLocal, @JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_) required this.channelEmailEnabled, @JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_) required this.channelInappEnabled, @JsonKey(name: NotificationPreferenceView.digestModeKey_) required this.digestMode}): super._();
  factory _NotificationPreferenceView.fromJson(Map<String, dynamic> json) => _$NotificationPreferenceViewFromJson(json);

/// timezone
@override@JsonKey(name: NotificationPreferenceView.timezoneKey_) final  String timezone;
/// quietHoursEnabled
@override@JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_) final  bool quietHoursEnabled;
/// quietStartLocal
@override@JsonKey(name: NotificationPreferenceView.quietStartLocalKey_) final  String? quietStartLocal;
/// quietEndLocal
@override@JsonKey(name: NotificationPreferenceView.quietEndLocalKey_) final  String? quietEndLocal;
/// channelEmailEnabled
@override@JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_) final  bool channelEmailEnabled;
/// channelInappEnabled
@override@JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_) final  bool channelInappEnabled;
/// digestMode
@override@JsonKey(name: NotificationPreferenceView.digestModeKey_) final  NotificationDigestMode digestMode;

/// Create a copy of NotificationPreferenceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferenceViewCopyWith<_NotificationPreferenceView> get copyWith => __$NotificationPreferenceViewCopyWithImpl<_NotificationPreferenceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferenceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferenceView&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.quietHoursEnabled, quietHoursEnabled) || other.quietHoursEnabled == quietHoursEnabled)&&(identical(other.quietStartLocal, quietStartLocal) || other.quietStartLocal == quietStartLocal)&&(identical(other.quietEndLocal, quietEndLocal) || other.quietEndLocal == quietEndLocal)&&(identical(other.channelEmailEnabled, channelEmailEnabled) || other.channelEmailEnabled == channelEmailEnabled)&&(identical(other.channelInappEnabled, channelInappEnabled) || other.channelInappEnabled == channelInappEnabled)&&(identical(other.digestMode, digestMode) || other.digestMode == digestMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timezone,quietHoursEnabled,quietStartLocal,quietEndLocal,channelEmailEnabled,channelInappEnabled,digestMode);

@override
String toString() {
  return 'NotificationPreferenceView(timezone: $timezone, quietHoursEnabled: $quietHoursEnabled, quietStartLocal: $quietStartLocal, quietEndLocal: $quietEndLocal, channelEmailEnabled: $channelEmailEnabled, channelInappEnabled: $channelInappEnabled, digestMode: $digestMode)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferenceViewCopyWith<$Res> implements $NotificationPreferenceViewCopyWith<$Res> {
  factory _$NotificationPreferenceViewCopyWith(_NotificationPreferenceView value, $Res Function(_NotificationPreferenceView) _then) = __$NotificationPreferenceViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NotificationPreferenceView.timezoneKey_) String timezone,@JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_) bool quietHoursEnabled,@JsonKey(name: NotificationPreferenceView.quietStartLocalKey_) String? quietStartLocal,@JsonKey(name: NotificationPreferenceView.quietEndLocalKey_) String? quietEndLocal,@JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_) bool channelEmailEnabled,@JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_) bool channelInappEnabled,@JsonKey(name: NotificationPreferenceView.digestModeKey_) NotificationDigestMode digestMode
});




}
/// @nodoc
class __$NotificationPreferenceViewCopyWithImpl<$Res>
    implements _$NotificationPreferenceViewCopyWith<$Res> {
  __$NotificationPreferenceViewCopyWithImpl(this._self, this._then);

  final _NotificationPreferenceView _self;
  final $Res Function(_NotificationPreferenceView) _then;

/// Create a copy of NotificationPreferenceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timezone = null,Object? quietHoursEnabled = null,Object? quietStartLocal = freezed,Object? quietEndLocal = freezed,Object? channelEmailEnabled = null,Object? channelInappEnabled = null,Object? digestMode = null,}) {
  return _then(_NotificationPreferenceView(
timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietStartLocal: freezed == quietStartLocal ? _self.quietStartLocal : quietStartLocal // ignore: cast_nullable_to_non_nullable
as String?,quietEndLocal: freezed == quietEndLocal ? _self.quietEndLocal : quietEndLocal // ignore: cast_nullable_to_non_nullable
as String?,channelEmailEnabled: null == channelEmailEnabled ? _self.channelEmailEnabled : channelEmailEnabled // ignore: cast_nullable_to_non_nullable
as bool,channelInappEnabled: null == channelInappEnabled ? _self.channelInappEnabled : channelInappEnabled // ignore: cast_nullable_to_non_nullable
as bool,digestMode: null == digestMode ? _self.digestMode : digestMode // ignore: cast_nullable_to_non_nullable
as NotificationDigestMode,
  ));
}


}

// dart format on
