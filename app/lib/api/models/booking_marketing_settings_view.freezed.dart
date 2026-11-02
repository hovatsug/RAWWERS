// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_marketing_settings_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingMarketingSettingsView {

/// allowMarketing
@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_) bool get allowMarketing;/// includesChildren
@JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_) bool get includesChildren;/// locked
@JsonKey(name: BookingMarketingSettingsView.lockedKey_) bool get locked;/// optedIn
@JsonKey(name: BookingMarketingSettingsView.optedInKey_) bool get optedIn;
/// Create a copy of BookingMarketingSettingsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingMarketingSettingsViewCopyWith<BookingMarketingSettingsView> get copyWith => _$BookingMarketingSettingsViewCopyWithImpl<BookingMarketingSettingsView>(this as BookingMarketingSettingsView, _$identity);

  /// Serializes this BookingMarketingSettingsView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingMarketingSettingsView&&(identical(other.allowMarketing, allowMarketing) || other.allowMarketing == allowMarketing)&&(identical(other.includesChildren, includesChildren) || other.includesChildren == includesChildren)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.optedIn, optedIn) || other.optedIn == optedIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowMarketing,includesChildren,locked,optedIn);

@override
String toString() {
  return 'BookingMarketingSettingsView(allowMarketing: $allowMarketing, includesChildren: $includesChildren, locked: $locked, optedIn: $optedIn)';
}


}

/// @nodoc
abstract mixin class $BookingMarketingSettingsViewCopyWith<$Res>  {
  factory $BookingMarketingSettingsViewCopyWith(BookingMarketingSettingsView value, $Res Function(BookingMarketingSettingsView) _then) = _$BookingMarketingSettingsViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_) bool allowMarketing,@JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_) bool includesChildren,@JsonKey(name: BookingMarketingSettingsView.lockedKey_) bool locked,@JsonKey(name: BookingMarketingSettingsView.optedInKey_) bool optedIn
});




}
/// @nodoc
class _$BookingMarketingSettingsViewCopyWithImpl<$Res>
    implements $BookingMarketingSettingsViewCopyWith<$Res> {
  _$BookingMarketingSettingsViewCopyWithImpl(this._self, this._then);

  final BookingMarketingSettingsView _self;
  final $Res Function(BookingMarketingSettingsView) _then;

/// Create a copy of BookingMarketingSettingsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allowMarketing = null,Object? includesChildren = null,Object? locked = null,Object? optedIn = null,}) {
  return _then(_self.copyWith(
allowMarketing: null == allowMarketing ? _self.allowMarketing : allowMarketing // ignore: cast_nullable_to_non_nullable
as bool,includesChildren: null == includesChildren ? _self.includesChildren : includesChildren // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,optedIn: null == optedIn ? _self.optedIn : optedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingMarketingSettingsView].
extension BookingMarketingSettingsViewPatterns on BookingMarketingSettingsView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingMarketingSettingsView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingMarketingSettingsView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingMarketingSettingsView value)  $default,){
final _that = this;
switch (_that) {
case _BookingMarketingSettingsView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingMarketingSettingsView value)?  $default,){
final _that = this;
switch (_that) {
case _BookingMarketingSettingsView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_)  bool allowMarketing, @JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_)  bool includesChildren, @JsonKey(name: BookingMarketingSettingsView.lockedKey_)  bool locked, @JsonKey(name: BookingMarketingSettingsView.optedInKey_)  bool optedIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingMarketingSettingsView() when $default != null:
return $default(_that.allowMarketing,_that.includesChildren,_that.locked,_that.optedIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_)  bool allowMarketing, @JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_)  bool includesChildren, @JsonKey(name: BookingMarketingSettingsView.lockedKey_)  bool locked, @JsonKey(name: BookingMarketingSettingsView.optedInKey_)  bool optedIn)  $default,) {final _that = this;
switch (_that) {
case _BookingMarketingSettingsView():
return $default(_that.allowMarketing,_that.includesChildren,_that.locked,_that.optedIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_)  bool allowMarketing, @JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_)  bool includesChildren, @JsonKey(name: BookingMarketingSettingsView.lockedKey_)  bool locked, @JsonKey(name: BookingMarketingSettingsView.optedInKey_)  bool optedIn)?  $default,) {final _that = this;
switch (_that) {
case _BookingMarketingSettingsView() when $default != null:
return $default(_that.allowMarketing,_that.includesChildren,_that.locked,_that.optedIn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingMarketingSettingsView extends BookingMarketingSettingsView {
  const _BookingMarketingSettingsView({@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_) required this.allowMarketing, @JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_) required this.includesChildren, @JsonKey(name: BookingMarketingSettingsView.lockedKey_) required this.locked, @JsonKey(name: BookingMarketingSettingsView.optedInKey_) required this.optedIn}): super._();
  factory _BookingMarketingSettingsView.fromJson(Map<String, dynamic> json) => _$BookingMarketingSettingsViewFromJson(json);

/// allowMarketing
@override@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_) final  bool allowMarketing;
/// includesChildren
@override@JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_) final  bool includesChildren;
/// locked
@override@JsonKey(name: BookingMarketingSettingsView.lockedKey_) final  bool locked;
/// optedIn
@override@JsonKey(name: BookingMarketingSettingsView.optedInKey_) final  bool optedIn;

/// Create a copy of BookingMarketingSettingsView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingMarketingSettingsViewCopyWith<_BookingMarketingSettingsView> get copyWith => __$BookingMarketingSettingsViewCopyWithImpl<_BookingMarketingSettingsView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingMarketingSettingsViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingMarketingSettingsView&&(identical(other.allowMarketing, allowMarketing) || other.allowMarketing == allowMarketing)&&(identical(other.includesChildren, includesChildren) || other.includesChildren == includesChildren)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.optedIn, optedIn) || other.optedIn == optedIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowMarketing,includesChildren,locked,optedIn);

@override
String toString() {
  return 'BookingMarketingSettingsView(allowMarketing: $allowMarketing, includesChildren: $includesChildren, locked: $locked, optedIn: $optedIn)';
}


}

/// @nodoc
abstract mixin class _$BookingMarketingSettingsViewCopyWith<$Res> implements $BookingMarketingSettingsViewCopyWith<$Res> {
  factory _$BookingMarketingSettingsViewCopyWith(_BookingMarketingSettingsView value, $Res Function(_BookingMarketingSettingsView) _then) = __$BookingMarketingSettingsViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_) bool allowMarketing,@JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_) bool includesChildren,@JsonKey(name: BookingMarketingSettingsView.lockedKey_) bool locked,@JsonKey(name: BookingMarketingSettingsView.optedInKey_) bool optedIn
});




}
/// @nodoc
class __$BookingMarketingSettingsViewCopyWithImpl<$Res>
    implements _$BookingMarketingSettingsViewCopyWith<$Res> {
  __$BookingMarketingSettingsViewCopyWithImpl(this._self, this._then);

  final _BookingMarketingSettingsView _self;
  final $Res Function(_BookingMarketingSettingsView) _then;

/// Create a copy of BookingMarketingSettingsView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allowMarketing = null,Object? includesChildren = null,Object? locked = null,Object? optedIn = null,}) {
  return _then(_BookingMarketingSettingsView(
allowMarketing: null == allowMarketing ? _self.allowMarketing : allowMarketing // ignore: cast_nullable_to_non_nullable
as bool,includesChildren: null == includesChildren ? _self.includesChildren : includesChildren // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,optedIn: null == optedIn ? _self.optedIn : optedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
