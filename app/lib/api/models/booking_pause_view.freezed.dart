// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_pause_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingPauseView {

/// reason
@JsonKey(name: BookingPauseView.reasonKey_) String get reason;/// since
@JsonKey(name: BookingPauseView.sinceKey_) String get since;
/// Create a copy of BookingPauseView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingPauseViewCopyWith<BookingPauseView> get copyWith => _$BookingPauseViewCopyWithImpl<BookingPauseView>(this as BookingPauseView, _$identity);

  /// Serializes this BookingPauseView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingPauseView&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.since, since) || other.since == since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,since);

@override
String toString() {
  return 'BookingPauseView(reason: $reason, since: $since)';
}


}

/// @nodoc
abstract mixin class $BookingPauseViewCopyWith<$Res>  {
  factory $BookingPauseViewCopyWith(BookingPauseView value, $Res Function(BookingPauseView) _then) = _$BookingPauseViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingPauseView.reasonKey_) String reason,@JsonKey(name: BookingPauseView.sinceKey_) String since
});




}
/// @nodoc
class _$BookingPauseViewCopyWithImpl<$Res>
    implements $BookingPauseViewCopyWith<$Res> {
  _$BookingPauseViewCopyWithImpl(this._self, this._then);

  final BookingPauseView _self;
  final $Res Function(BookingPauseView) _then;

/// Create a copy of BookingPauseView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? since = null,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingPauseView].
extension BookingPauseViewPatterns on BookingPauseView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingPauseView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingPauseView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingPauseView value)  $default,){
final _that = this;
switch (_that) {
case _BookingPauseView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingPauseView value)?  $default,){
final _that = this;
switch (_that) {
case _BookingPauseView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingPauseView.reasonKey_)  String reason, @JsonKey(name: BookingPauseView.sinceKey_)  String since)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingPauseView() when $default != null:
return $default(_that.reason,_that.since);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingPauseView.reasonKey_)  String reason, @JsonKey(name: BookingPauseView.sinceKey_)  String since)  $default,) {final _that = this;
switch (_that) {
case _BookingPauseView():
return $default(_that.reason,_that.since);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingPauseView.reasonKey_)  String reason, @JsonKey(name: BookingPauseView.sinceKey_)  String since)?  $default,) {final _that = this;
switch (_that) {
case _BookingPauseView() when $default != null:
return $default(_that.reason,_that.since);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingPauseView extends BookingPauseView {
  const _BookingPauseView({@JsonKey(name: BookingPauseView.reasonKey_) required this.reason, @JsonKey(name: BookingPauseView.sinceKey_) required this.since}): super._();
  factory _BookingPauseView.fromJson(Map<String, dynamic> json) => _$BookingPauseViewFromJson(json);

/// reason
@override@JsonKey(name: BookingPauseView.reasonKey_) final  String reason;
/// since
@override@JsonKey(name: BookingPauseView.sinceKey_) final  String since;

/// Create a copy of BookingPauseView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingPauseViewCopyWith<_BookingPauseView> get copyWith => __$BookingPauseViewCopyWithImpl<_BookingPauseView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingPauseViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingPauseView&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.since, since) || other.since == since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,since);

@override
String toString() {
  return 'BookingPauseView(reason: $reason, since: $since)';
}


}

/// @nodoc
abstract mixin class _$BookingPauseViewCopyWith<$Res> implements $BookingPauseViewCopyWith<$Res> {
  factory _$BookingPauseViewCopyWith(_BookingPauseView value, $Res Function(_BookingPauseView) _then) = __$BookingPauseViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingPauseView.reasonKey_) String reason,@JsonKey(name: BookingPauseView.sinceKey_) String since
});




}
/// @nodoc
class __$BookingPauseViewCopyWithImpl<$Res>
    implements _$BookingPauseViewCopyWith<$Res> {
  __$BookingPauseViewCopyWithImpl(this._self, this._then);

  final _BookingPauseView _self;
  final $Res Function(_BookingPauseView) _then;

/// Create a copy of BookingPauseView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? since = null,}) {
  return _then(_BookingPauseView(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
