// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unsubscribe_all_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnsubscribeAllLink {

/// k
@JsonKey(name: UnsubscribeAllLink.kKey_) String get k;/// s
@JsonKey(name: UnsubscribeAllLink.sKey_) String get s;
/// Create a copy of UnsubscribeAllLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnsubscribeAllLinkCopyWith<UnsubscribeAllLink> get copyWith => _$UnsubscribeAllLinkCopyWithImpl<UnsubscribeAllLink>(this as UnsubscribeAllLink, _$identity);

  /// Serializes this UnsubscribeAllLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnsubscribeAllLink&&(identical(other.k, k) || other.k == k)&&(identical(other.s, s) || other.s == s));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,k,s);

@override
String toString() {
  return 'UnsubscribeAllLink(k: $k, s: $s)';
}


}

/// @nodoc
abstract mixin class $UnsubscribeAllLinkCopyWith<$Res>  {
  factory $UnsubscribeAllLinkCopyWith(UnsubscribeAllLink value, $Res Function(UnsubscribeAllLink) _then) = _$UnsubscribeAllLinkCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UnsubscribeAllLink.kKey_) String k,@JsonKey(name: UnsubscribeAllLink.sKey_) String s
});




}
/// @nodoc
class _$UnsubscribeAllLinkCopyWithImpl<$Res>
    implements $UnsubscribeAllLinkCopyWith<$Res> {
  _$UnsubscribeAllLinkCopyWithImpl(this._self, this._then);

  final UnsubscribeAllLink _self;
  final $Res Function(UnsubscribeAllLink) _then;

/// Create a copy of UnsubscribeAllLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? k = null,Object? s = null,}) {
  return _then(_self.copyWith(
k: null == k ? _self.k : k // ignore: cast_nullable_to_non_nullable
as String,s: null == s ? _self.s : s // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UnsubscribeAllLink].
extension UnsubscribeAllLinkPatterns on UnsubscribeAllLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnsubscribeAllLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnsubscribeAllLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnsubscribeAllLink value)  $default,){
final _that = this;
switch (_that) {
case _UnsubscribeAllLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnsubscribeAllLink value)?  $default,){
final _that = this;
switch (_that) {
case _UnsubscribeAllLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UnsubscribeAllLink.kKey_)  String k, @JsonKey(name: UnsubscribeAllLink.sKey_)  String s)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnsubscribeAllLink() when $default != null:
return $default(_that.k,_that.s);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UnsubscribeAllLink.kKey_)  String k, @JsonKey(name: UnsubscribeAllLink.sKey_)  String s)  $default,) {final _that = this;
switch (_that) {
case _UnsubscribeAllLink():
return $default(_that.k,_that.s);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UnsubscribeAllLink.kKey_)  String k, @JsonKey(name: UnsubscribeAllLink.sKey_)  String s)?  $default,) {final _that = this;
switch (_that) {
case _UnsubscribeAllLink() when $default != null:
return $default(_that.k,_that.s);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UnsubscribeAllLink extends UnsubscribeAllLink {
  const _UnsubscribeAllLink({@JsonKey(name: UnsubscribeAllLink.kKey_) required this.k, @JsonKey(name: UnsubscribeAllLink.sKey_) required this.s}): super._();
  factory _UnsubscribeAllLink.fromJson(Map<String, dynamic> json) => _$UnsubscribeAllLinkFromJson(json);

/// k
@override@JsonKey(name: UnsubscribeAllLink.kKey_) final  String k;
/// s
@override@JsonKey(name: UnsubscribeAllLink.sKey_) final  String s;

/// Create a copy of UnsubscribeAllLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnsubscribeAllLinkCopyWith<_UnsubscribeAllLink> get copyWith => __$UnsubscribeAllLinkCopyWithImpl<_UnsubscribeAllLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnsubscribeAllLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribeAllLink&&(identical(other.k, k) || other.k == k)&&(identical(other.s, s) || other.s == s));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,k,s);

@override
String toString() {
  return 'UnsubscribeAllLink(k: $k, s: $s)';
}


}

/// @nodoc
abstract mixin class _$UnsubscribeAllLinkCopyWith<$Res> implements $UnsubscribeAllLinkCopyWith<$Res> {
  factory _$UnsubscribeAllLinkCopyWith(_UnsubscribeAllLink value, $Res Function(_UnsubscribeAllLink) _then) = __$UnsubscribeAllLinkCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UnsubscribeAllLink.kKey_) String k,@JsonKey(name: UnsubscribeAllLink.sKey_) String s
});




}
/// @nodoc
class __$UnsubscribeAllLinkCopyWithImpl<$Res>
    implements _$UnsubscribeAllLinkCopyWith<$Res> {
  __$UnsubscribeAllLinkCopyWithImpl(this._self, this._then);

  final _UnsubscribeAllLink _self;
  final $Res Function(_UnsubscribeAllLink) _then;

/// Create a copy of UnsubscribeAllLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? k = null,Object? s = null,}) {
  return _then(_UnsubscribeAllLink(
k: null == k ? _self.k : k // ignore: cast_nullable_to_non_nullable
as String,s: null == s ? _self.s : s // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
