// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'response_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResponseIn {

/// text
@JsonKey(name: ResponseIn.textKey_) String get text;
/// Create a copy of ResponseIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResponseInCopyWith<ResponseIn> get copyWith => _$ResponseInCopyWithImpl<ResponseIn>(this as ResponseIn, _$identity);

  /// Serializes this ResponseIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResponseIn&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'ResponseIn(text: $text)';
}


}

/// @nodoc
abstract mixin class $ResponseInCopyWith<$Res>  {
  factory $ResponseInCopyWith(ResponseIn value, $Res Function(ResponseIn) _then) = _$ResponseInCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ResponseIn.textKey_) String text
});




}
/// @nodoc
class _$ResponseInCopyWithImpl<$Res>
    implements $ResponseInCopyWith<$Res> {
  _$ResponseInCopyWithImpl(this._self, this._then);

  final ResponseIn _self;
  final $Res Function(ResponseIn) _then;

/// Create a copy of ResponseIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResponseIn].
extension ResponseInPatterns on ResponseIn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResponseIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResponseIn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResponseIn value)  $default,){
final _that = this;
switch (_that) {
case _ResponseIn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResponseIn value)?  $default,){
final _that = this;
switch (_that) {
case _ResponseIn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ResponseIn.textKey_)  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResponseIn() when $default != null:
return $default(_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ResponseIn.textKey_)  String text)  $default,) {final _that = this;
switch (_that) {
case _ResponseIn():
return $default(_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ResponseIn.textKey_)  String text)?  $default,) {final _that = this;
switch (_that) {
case _ResponseIn() when $default != null:
return $default(_that.text);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ResponseIn extends ResponseIn {
  const _ResponseIn({@JsonKey(name: ResponseIn.textKey_) required this.text}): super._();
  factory _ResponseIn.fromJson(Map<String, dynamic> json) => _$ResponseInFromJson(json);

/// text
@override@JsonKey(name: ResponseIn.textKey_) final  String text;

/// Create a copy of ResponseIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResponseInCopyWith<_ResponseIn> get copyWith => __$ResponseInCopyWithImpl<_ResponseIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResponseInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResponseIn&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'ResponseIn(text: $text)';
}


}

/// @nodoc
abstract mixin class _$ResponseInCopyWith<$Res> implements $ResponseInCopyWith<$Res> {
  factory _$ResponseInCopyWith(_ResponseIn value, $Res Function(_ResponseIn) _then) = __$ResponseInCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ResponseIn.textKey_) String text
});




}
/// @nodoc
class __$ResponseInCopyWithImpl<$Res>
    implements _$ResponseInCopyWith<$Res> {
  __$ResponseInCopyWithImpl(this._self, this._then);

  final _ResponseIn _self;
  final $Res Function(_ResponseIn) _then;

/// Create a copy of ResponseIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(_ResponseIn(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
