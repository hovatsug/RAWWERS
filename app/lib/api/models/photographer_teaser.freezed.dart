// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photographer_teaser.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotographerTeaser {

/// kind
@JsonKey(name: PhotographerTeaser.kindKey_) TeaserKind get kind;/// line
@JsonKey(name: PhotographerTeaser.lineKey_) String? get line;
/// Create a copy of PhotographerTeaser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotographerTeaserCopyWith<PhotographerTeaser> get copyWith => _$PhotographerTeaserCopyWithImpl<PhotographerTeaser>(this as PhotographerTeaser, _$identity);

  /// Serializes this PhotographerTeaser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotographerTeaser&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.line, line) || other.line == line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,line);

@override
String toString() {
  return 'PhotographerTeaser(kind: $kind, line: $line)';
}


}

/// @nodoc
abstract mixin class $PhotographerTeaserCopyWith<$Res>  {
  factory $PhotographerTeaserCopyWith(PhotographerTeaser value, $Res Function(PhotographerTeaser) _then) = _$PhotographerTeaserCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PhotographerTeaser.kindKey_) TeaserKind kind,@JsonKey(name: PhotographerTeaser.lineKey_) String? line
});




}
/// @nodoc
class _$PhotographerTeaserCopyWithImpl<$Res>
    implements $PhotographerTeaserCopyWith<$Res> {
  _$PhotographerTeaserCopyWithImpl(this._self, this._then);

  final PhotographerTeaser _self;
  final $Res Function(PhotographerTeaser) _then;

/// Create a copy of PhotographerTeaser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? line = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TeaserKind,line: freezed == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotographerTeaser].
extension PhotographerTeaserPatterns on PhotographerTeaser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotographerTeaser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotographerTeaser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotographerTeaser value)  $default,){
final _that = this;
switch (_that) {
case _PhotographerTeaser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotographerTeaser value)?  $default,){
final _that = this;
switch (_that) {
case _PhotographerTeaser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PhotographerTeaser.kindKey_)  TeaserKind kind, @JsonKey(name: PhotographerTeaser.lineKey_)  String? line)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotographerTeaser() when $default != null:
return $default(_that.kind,_that.line);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PhotographerTeaser.kindKey_)  TeaserKind kind, @JsonKey(name: PhotographerTeaser.lineKey_)  String? line)  $default,) {final _that = this;
switch (_that) {
case _PhotographerTeaser():
return $default(_that.kind,_that.line);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PhotographerTeaser.kindKey_)  TeaserKind kind, @JsonKey(name: PhotographerTeaser.lineKey_)  String? line)?  $default,) {final _that = this;
switch (_that) {
case _PhotographerTeaser() when $default != null:
return $default(_that.kind,_that.line);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PhotographerTeaser extends PhotographerTeaser {
  const _PhotographerTeaser({@JsonKey(name: PhotographerTeaser.kindKey_) required this.kind, @JsonKey(name: PhotographerTeaser.lineKey_) this.line}): super._();
  factory _PhotographerTeaser.fromJson(Map<String, dynamic> json) => _$PhotographerTeaserFromJson(json);

/// kind
@override@JsonKey(name: PhotographerTeaser.kindKey_) final  TeaserKind kind;
/// line
@override@JsonKey(name: PhotographerTeaser.lineKey_) final  String? line;

/// Create a copy of PhotographerTeaser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotographerTeaserCopyWith<_PhotographerTeaser> get copyWith => __$PhotographerTeaserCopyWithImpl<_PhotographerTeaser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotographerTeaserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotographerTeaser&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.line, line) || other.line == line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,line);

@override
String toString() {
  return 'PhotographerTeaser(kind: $kind, line: $line)';
}


}

/// @nodoc
abstract mixin class _$PhotographerTeaserCopyWith<$Res> implements $PhotographerTeaserCopyWith<$Res> {
  factory _$PhotographerTeaserCopyWith(_PhotographerTeaser value, $Res Function(_PhotographerTeaser) _then) = __$PhotographerTeaserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PhotographerTeaser.kindKey_) TeaserKind kind,@JsonKey(name: PhotographerTeaser.lineKey_) String? line
});




}
/// @nodoc
class __$PhotographerTeaserCopyWithImpl<$Res>
    implements _$PhotographerTeaserCopyWith<$Res> {
  __$PhotographerTeaserCopyWithImpl(this._self, this._then);

  final _PhotographerTeaser _self;
  final $Res Function(_PhotographerTeaser) _then;

/// Create a copy of PhotographerTeaser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? line = freezed,}) {
  return _then(_PhotographerTeaser(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TeaserKind,line: freezed == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
