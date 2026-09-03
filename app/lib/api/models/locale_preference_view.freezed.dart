// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locale_preference_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalePreferenceView {

/// userId
@JsonKey(name: LocalePreferenceView.userIdKey_) String get userId;/// locale
@JsonKey(name: LocalePreferenceView.localeKey_) String get locale;
/// Create a copy of LocalePreferenceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalePreferenceViewCopyWith<LocalePreferenceView> get copyWith => _$LocalePreferenceViewCopyWithImpl<LocalePreferenceView>(this as LocalePreferenceView, _$identity);

  /// Serializes this LocalePreferenceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalePreferenceView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,locale);

@override
String toString() {
  return 'LocalePreferenceView(userId: $userId, locale: $locale)';
}


}

/// @nodoc
abstract mixin class $LocalePreferenceViewCopyWith<$Res>  {
  factory $LocalePreferenceViewCopyWith(LocalePreferenceView value, $Res Function(LocalePreferenceView) _then) = _$LocalePreferenceViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: LocalePreferenceView.userIdKey_) String userId,@JsonKey(name: LocalePreferenceView.localeKey_) String locale
});




}
/// @nodoc
class _$LocalePreferenceViewCopyWithImpl<$Res>
    implements $LocalePreferenceViewCopyWith<$Res> {
  _$LocalePreferenceViewCopyWithImpl(this._self, this._then);

  final LocalePreferenceView _self;
  final $Res Function(LocalePreferenceView) _then;

/// Create a copy of LocalePreferenceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? locale = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalePreferenceView].
extension LocalePreferenceViewPatterns on LocalePreferenceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalePreferenceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalePreferenceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalePreferenceView value)  $default,){
final _that = this;
switch (_that) {
case _LocalePreferenceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalePreferenceView value)?  $default,){
final _that = this;
switch (_that) {
case _LocalePreferenceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: LocalePreferenceView.userIdKey_)  String userId, @JsonKey(name: LocalePreferenceView.localeKey_)  String locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalePreferenceView() when $default != null:
return $default(_that.userId,_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: LocalePreferenceView.userIdKey_)  String userId, @JsonKey(name: LocalePreferenceView.localeKey_)  String locale)  $default,) {final _that = this;
switch (_that) {
case _LocalePreferenceView():
return $default(_that.userId,_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: LocalePreferenceView.userIdKey_)  String userId, @JsonKey(name: LocalePreferenceView.localeKey_)  String locale)?  $default,) {final _that = this;
switch (_that) {
case _LocalePreferenceView() when $default != null:
return $default(_that.userId,_that.locale);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _LocalePreferenceView extends LocalePreferenceView {
  const _LocalePreferenceView({@JsonKey(name: LocalePreferenceView.userIdKey_) required this.userId, @JsonKey(name: LocalePreferenceView.localeKey_) required this.locale}): super._();
  factory _LocalePreferenceView.fromJson(Map<String, dynamic> json) => _$LocalePreferenceViewFromJson(json);

/// userId
@override@JsonKey(name: LocalePreferenceView.userIdKey_) final  String userId;
/// locale
@override@JsonKey(name: LocalePreferenceView.localeKey_) final  String locale;

/// Create a copy of LocalePreferenceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalePreferenceViewCopyWith<_LocalePreferenceView> get copyWith => __$LocalePreferenceViewCopyWithImpl<_LocalePreferenceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalePreferenceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalePreferenceView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,locale);

@override
String toString() {
  return 'LocalePreferenceView(userId: $userId, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$LocalePreferenceViewCopyWith<$Res> implements $LocalePreferenceViewCopyWith<$Res> {
  factory _$LocalePreferenceViewCopyWith(_LocalePreferenceView value, $Res Function(_LocalePreferenceView) _then) = __$LocalePreferenceViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: LocalePreferenceView.userIdKey_) String userId,@JsonKey(name: LocalePreferenceView.localeKey_) String locale
});




}
/// @nodoc
class __$LocalePreferenceViewCopyWithImpl<$Res>
    implements _$LocalePreferenceViewCopyWith<$Res> {
  __$LocalePreferenceViewCopyWithImpl(this._self, this._then);

  final _LocalePreferenceView _self;
  final $Res Function(_LocalePreferenceView) _then;

/// Create a copy of LocalePreferenceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? locale = null,}) {
  return _then(_LocalePreferenceView(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
