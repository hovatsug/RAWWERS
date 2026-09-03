// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduling_slot_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchedulingSlotView {

/// startAtUtc
@JsonKey(name: SchedulingSlotView.startAtUtcKey_) DateTime get startAtUtc;/// endAtUtc
@JsonKey(name: SchedulingSlotView.endAtUtcKey_) DateTime get endAtUtc;/// timezone
@JsonKey(name: SchedulingSlotView.timezoneKey_) String get timezone;/// startLocal
@JsonKey(name: SchedulingSlotView.startLocalKey_) String get startLocal;/// endLocal
@JsonKey(name: SchedulingSlotView.endLocalKey_) String get endLocal;
/// Create a copy of SchedulingSlotView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulingSlotViewCopyWith<SchedulingSlotView> get copyWith => _$SchedulingSlotViewCopyWithImpl<SchedulingSlotView>(this as SchedulingSlotView, _$identity);

  /// Serializes this SchedulingSlotView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulingSlotView&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.startLocal, startLocal) || other.startLocal == startLocal)&&(identical(other.endLocal, endLocal) || other.endLocal == endLocal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc,timezone,startLocal,endLocal);

@override
String toString() {
  return 'SchedulingSlotView(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, timezone: $timezone, startLocal: $startLocal, endLocal: $endLocal)';
}


}

/// @nodoc
abstract mixin class $SchedulingSlotViewCopyWith<$Res>  {
  factory $SchedulingSlotViewCopyWith(SchedulingSlotView value, $Res Function(SchedulingSlotView) _then) = _$SchedulingSlotViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SchedulingSlotView.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: SchedulingSlotView.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: SchedulingSlotView.timezoneKey_) String timezone,@JsonKey(name: SchedulingSlotView.startLocalKey_) String startLocal,@JsonKey(name: SchedulingSlotView.endLocalKey_) String endLocal
});




}
/// @nodoc
class _$SchedulingSlotViewCopyWithImpl<$Res>
    implements $SchedulingSlotViewCopyWith<$Res> {
  _$SchedulingSlotViewCopyWithImpl(this._self, this._then);

  final SchedulingSlotView _self;
  final $Res Function(SchedulingSlotView) _then;

/// Create a copy of SchedulingSlotView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAtUtc = null,Object? endAtUtc = null,Object? timezone = null,Object? startLocal = null,Object? endLocal = null,}) {
  return _then(_self.copyWith(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as String,endLocal: null == endLocal ? _self.endLocal : endLocal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulingSlotView].
extension SchedulingSlotViewPatterns on SchedulingSlotView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulingSlotView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulingSlotView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulingSlotView value)  $default,){
final _that = this;
switch (_that) {
case _SchedulingSlotView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulingSlotView value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulingSlotView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingSlotView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: SchedulingSlotView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: SchedulingSlotView.timezoneKey_)  String timezone, @JsonKey(name: SchedulingSlotView.startLocalKey_)  String startLocal, @JsonKey(name: SchedulingSlotView.endLocalKey_)  String endLocal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulingSlotView() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc,_that.timezone,_that.startLocal,_that.endLocal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SchedulingSlotView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: SchedulingSlotView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: SchedulingSlotView.timezoneKey_)  String timezone, @JsonKey(name: SchedulingSlotView.startLocalKey_)  String startLocal, @JsonKey(name: SchedulingSlotView.endLocalKey_)  String endLocal)  $default,) {final _that = this;
switch (_that) {
case _SchedulingSlotView():
return $default(_that.startAtUtc,_that.endAtUtc,_that.timezone,_that.startLocal,_that.endLocal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SchedulingSlotView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: SchedulingSlotView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: SchedulingSlotView.timezoneKey_)  String timezone, @JsonKey(name: SchedulingSlotView.startLocalKey_)  String startLocal, @JsonKey(name: SchedulingSlotView.endLocalKey_)  String endLocal)?  $default,) {final _that = this;
switch (_that) {
case _SchedulingSlotView() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc,_that.timezone,_that.startLocal,_that.endLocal);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SchedulingSlotView extends SchedulingSlotView {
  const _SchedulingSlotView({@JsonKey(name: SchedulingSlotView.startAtUtcKey_) required this.startAtUtc, @JsonKey(name: SchedulingSlotView.endAtUtcKey_) required this.endAtUtc, @JsonKey(name: SchedulingSlotView.timezoneKey_) required this.timezone, @JsonKey(name: SchedulingSlotView.startLocalKey_) required this.startLocal, @JsonKey(name: SchedulingSlotView.endLocalKey_) required this.endLocal}): super._();
  factory _SchedulingSlotView.fromJson(Map<String, dynamic> json) => _$SchedulingSlotViewFromJson(json);

/// startAtUtc
@override@JsonKey(name: SchedulingSlotView.startAtUtcKey_) final  DateTime startAtUtc;
/// endAtUtc
@override@JsonKey(name: SchedulingSlotView.endAtUtcKey_) final  DateTime endAtUtc;
/// timezone
@override@JsonKey(name: SchedulingSlotView.timezoneKey_) final  String timezone;
/// startLocal
@override@JsonKey(name: SchedulingSlotView.startLocalKey_) final  String startLocal;
/// endLocal
@override@JsonKey(name: SchedulingSlotView.endLocalKey_) final  String endLocal;

/// Create a copy of SchedulingSlotView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulingSlotViewCopyWith<_SchedulingSlotView> get copyWith => __$SchedulingSlotViewCopyWithImpl<_SchedulingSlotView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchedulingSlotViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulingSlotView&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.startLocal, startLocal) || other.startLocal == startLocal)&&(identical(other.endLocal, endLocal) || other.endLocal == endLocal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc,timezone,startLocal,endLocal);

@override
String toString() {
  return 'SchedulingSlotView(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, timezone: $timezone, startLocal: $startLocal, endLocal: $endLocal)';
}


}

/// @nodoc
abstract mixin class _$SchedulingSlotViewCopyWith<$Res> implements $SchedulingSlotViewCopyWith<$Res> {
  factory _$SchedulingSlotViewCopyWith(_SchedulingSlotView value, $Res Function(_SchedulingSlotView) _then) = __$SchedulingSlotViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SchedulingSlotView.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: SchedulingSlotView.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: SchedulingSlotView.timezoneKey_) String timezone,@JsonKey(name: SchedulingSlotView.startLocalKey_) String startLocal,@JsonKey(name: SchedulingSlotView.endLocalKey_) String endLocal
});




}
/// @nodoc
class __$SchedulingSlotViewCopyWithImpl<$Res>
    implements _$SchedulingSlotViewCopyWith<$Res> {
  __$SchedulingSlotViewCopyWithImpl(this._self, this._then);

  final _SchedulingSlotView _self;
  final $Res Function(_SchedulingSlotView) _then;

/// Create a copy of SchedulingSlotView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAtUtc = null,Object? endAtUtc = null,Object? timezone = null,Object? startLocal = null,Object? endLocal = null,}) {
  return _then(_SchedulingSlotView(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as String,endLocal: null == endLocal ? _self.endLocal : endLocal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
