// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_derivative_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaDerivativeView {

/// kind
@JsonKey(name: MediaDerivativeView.kindKey_) String get kind;
/// Create a copy of MediaDerivativeView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaDerivativeViewCopyWith<MediaDerivativeView> get copyWith => _$MediaDerivativeViewCopyWithImpl<MediaDerivativeView>(this as MediaDerivativeView, _$identity);

  /// Serializes this MediaDerivativeView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaDerivativeView&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind);

@override
String toString() {
  return 'MediaDerivativeView(kind: $kind)';
}


}

/// @nodoc
abstract mixin class $MediaDerivativeViewCopyWith<$Res>  {
  factory $MediaDerivativeViewCopyWith(MediaDerivativeView value, $Res Function(MediaDerivativeView) _then) = _$MediaDerivativeViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MediaDerivativeView.kindKey_) String kind
});




}
/// @nodoc
class _$MediaDerivativeViewCopyWithImpl<$Res>
    implements $MediaDerivativeViewCopyWith<$Res> {
  _$MediaDerivativeViewCopyWithImpl(this._self, this._then);

  final MediaDerivativeView _self;
  final $Res Function(MediaDerivativeView) _then;

/// Create a copy of MediaDerivativeView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaDerivativeView].
extension MediaDerivativeViewPatterns on MediaDerivativeView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaDerivativeView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaDerivativeView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaDerivativeView value)  $default,){
final _that = this;
switch (_that) {
case _MediaDerivativeView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaDerivativeView value)?  $default,){
final _that = this;
switch (_that) {
case _MediaDerivativeView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MediaDerivativeView.kindKey_)  String kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaDerivativeView() when $default != null:
return $default(_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MediaDerivativeView.kindKey_)  String kind)  $default,) {final _that = this;
switch (_that) {
case _MediaDerivativeView():
return $default(_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MediaDerivativeView.kindKey_)  String kind)?  $default,) {final _that = this;
switch (_that) {
case _MediaDerivativeView() when $default != null:
return $default(_that.kind);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MediaDerivativeView extends MediaDerivativeView {
  const _MediaDerivativeView({@JsonKey(name: MediaDerivativeView.kindKey_) required this.kind}): super._();
  factory _MediaDerivativeView.fromJson(Map<String, dynamic> json) => _$MediaDerivativeViewFromJson(json);

/// kind
@override@JsonKey(name: MediaDerivativeView.kindKey_) final  String kind;

/// Create a copy of MediaDerivativeView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaDerivativeViewCopyWith<_MediaDerivativeView> get copyWith => __$MediaDerivativeViewCopyWithImpl<_MediaDerivativeView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaDerivativeViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaDerivativeView&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind);

@override
String toString() {
  return 'MediaDerivativeView(kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$MediaDerivativeViewCopyWith<$Res> implements $MediaDerivativeViewCopyWith<$Res> {
  factory _$MediaDerivativeViewCopyWith(_MediaDerivativeView value, $Res Function(_MediaDerivativeView) _then) = __$MediaDerivativeViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MediaDerivativeView.kindKey_) String kind
});




}
/// @nodoc
class __$MediaDerivativeViewCopyWithImpl<$Res>
    implements _$MediaDerivativeViewCopyWith<$Res> {
  __$MediaDerivativeViewCopyWithImpl(this._self, this._then);

  final _MediaDerivativeView _self;
  final $Res Function(_MediaDerivativeView) _then;

/// Create a copy of MediaDerivativeView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(_MediaDerivativeView(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
