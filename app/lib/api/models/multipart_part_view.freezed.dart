// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multipart_part_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultipartPartView {

/// partNumber
@JsonKey(name: MultipartPartView.partNumberKey_) int get partNumber;/// size
@JsonKey(name: MultipartPartView.sizeKey_) int get size;
/// Create a copy of MultipartPartView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultipartPartViewCopyWith<MultipartPartView> get copyWith => _$MultipartPartViewCopyWithImpl<MultipartPartView>(this as MultipartPartView, _$identity);

  /// Serializes this MultipartPartView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultipartPartView&&(identical(other.partNumber, partNumber) || other.partNumber == partNumber)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partNumber,size);

@override
String toString() {
  return 'MultipartPartView(partNumber: $partNumber, size: $size)';
}


}

/// @nodoc
abstract mixin class $MultipartPartViewCopyWith<$Res>  {
  factory $MultipartPartViewCopyWith(MultipartPartView value, $Res Function(MultipartPartView) _then) = _$MultipartPartViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MultipartPartView.partNumberKey_) int partNumber,@JsonKey(name: MultipartPartView.sizeKey_) int size
});




}
/// @nodoc
class _$MultipartPartViewCopyWithImpl<$Res>
    implements $MultipartPartViewCopyWith<$Res> {
  _$MultipartPartViewCopyWithImpl(this._self, this._then);

  final MultipartPartView _self;
  final $Res Function(MultipartPartView) _then;

/// Create a copy of MultipartPartView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partNumber = null,Object? size = null,}) {
  return _then(_self.copyWith(
partNumber: null == partNumber ? _self.partNumber : partNumber // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MultipartPartView].
extension MultipartPartViewPatterns on MultipartPartView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultipartPartView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultipartPartView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultipartPartView value)  $default,){
final _that = this;
switch (_that) {
case _MultipartPartView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultipartPartView value)?  $default,){
final _that = this;
switch (_that) {
case _MultipartPartView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartView.partNumberKey_)  int partNumber, @JsonKey(name: MultipartPartView.sizeKey_)  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultipartPartView() when $default != null:
return $default(_that.partNumber,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MultipartPartView.partNumberKey_)  int partNumber, @JsonKey(name: MultipartPartView.sizeKey_)  int size)  $default,) {final _that = this;
switch (_that) {
case _MultipartPartView():
return $default(_that.partNumber,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MultipartPartView.partNumberKey_)  int partNumber, @JsonKey(name: MultipartPartView.sizeKey_)  int size)?  $default,) {final _that = this;
switch (_that) {
case _MultipartPartView() when $default != null:
return $default(_that.partNumber,_that.size);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MultipartPartView extends MultipartPartView {
  const _MultipartPartView({@JsonKey(name: MultipartPartView.partNumberKey_) required this.partNumber, @JsonKey(name: MultipartPartView.sizeKey_) required this.size}): super._();
  factory _MultipartPartView.fromJson(Map<String, dynamic> json) => _$MultipartPartViewFromJson(json);

/// partNumber
@override@JsonKey(name: MultipartPartView.partNumberKey_) final  int partNumber;
/// size
@override@JsonKey(name: MultipartPartView.sizeKey_) final  int size;

/// Create a copy of MultipartPartView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultipartPartViewCopyWith<_MultipartPartView> get copyWith => __$MultipartPartViewCopyWithImpl<_MultipartPartView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultipartPartViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultipartPartView&&(identical(other.partNumber, partNumber) || other.partNumber == partNumber)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partNumber,size);

@override
String toString() {
  return 'MultipartPartView(partNumber: $partNumber, size: $size)';
}


}

/// @nodoc
abstract mixin class _$MultipartPartViewCopyWith<$Res> implements $MultipartPartViewCopyWith<$Res> {
  factory _$MultipartPartViewCopyWith(_MultipartPartView value, $Res Function(_MultipartPartView) _then) = __$MultipartPartViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MultipartPartView.partNumberKey_) int partNumber,@JsonKey(name: MultipartPartView.sizeKey_) int size
});




}
/// @nodoc
class __$MultipartPartViewCopyWithImpl<$Res>
    implements _$MultipartPartViewCopyWith<$Res> {
  __$MultipartPartViewCopyWithImpl(this._self, this._then);

  final _MultipartPartView _self;
  final $Res Function(_MultipartPartView) _then;

/// Create a copy of MultipartPartView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partNumber = null,Object? size = null,}) {
  return _then(_MultipartPartView(
partNumber: null == partNumber ? _self.partNumber : partNumber // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
