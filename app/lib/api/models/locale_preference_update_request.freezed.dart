// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locale_preference_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalePreferenceUpdateRequest {

/// locale
@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_) String get locale;
/// Create a copy of LocalePreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalePreferenceUpdateRequestCopyWith<LocalePreferenceUpdateRequest> get copyWith => _$LocalePreferenceUpdateRequestCopyWithImpl<LocalePreferenceUpdateRequest>(this as LocalePreferenceUpdateRequest, _$identity);

  /// Serializes this LocalePreferenceUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalePreferenceUpdateRequest&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locale);

@override
String toString() {
  return 'LocalePreferenceUpdateRequest(locale: $locale)';
}


}

/// @nodoc
abstract mixin class $LocalePreferenceUpdateRequestCopyWith<$Res>  {
  factory $LocalePreferenceUpdateRequestCopyWith(LocalePreferenceUpdateRequest value, $Res Function(LocalePreferenceUpdateRequest) _then) = _$LocalePreferenceUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_) String locale
});




}
/// @nodoc
class _$LocalePreferenceUpdateRequestCopyWithImpl<$Res>
    implements $LocalePreferenceUpdateRequestCopyWith<$Res> {
  _$LocalePreferenceUpdateRequestCopyWithImpl(this._self, this._then);

  final LocalePreferenceUpdateRequest _self;
  final $Res Function(LocalePreferenceUpdateRequest) _then;

/// Create a copy of LocalePreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,}) {
  return _then(_self.copyWith(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalePreferenceUpdateRequest].
extension LocalePreferenceUpdateRequestPatterns on LocalePreferenceUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalePreferenceUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalePreferenceUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalePreferenceUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _LocalePreferenceUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalePreferenceUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LocalePreferenceUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_)  String locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalePreferenceUpdateRequest() when $default != null:
return $default(_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_)  String locale)  $default,) {final _that = this;
switch (_that) {
case _LocalePreferenceUpdateRequest():
return $default(_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_)  String locale)?  $default,) {final _that = this;
switch (_that) {
case _LocalePreferenceUpdateRequest() when $default != null:
return $default(_that.locale);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _LocalePreferenceUpdateRequest extends LocalePreferenceUpdateRequest {
  const _LocalePreferenceUpdateRequest({@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_) required this.locale}): super._();
  factory _LocalePreferenceUpdateRequest.fromJson(Map<String, dynamic> json) => _$LocalePreferenceUpdateRequestFromJson(json);

/// locale
@override@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_) final  String locale;

/// Create a copy of LocalePreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalePreferenceUpdateRequestCopyWith<_LocalePreferenceUpdateRequest> get copyWith => __$LocalePreferenceUpdateRequestCopyWithImpl<_LocalePreferenceUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalePreferenceUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalePreferenceUpdateRequest&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locale);

@override
String toString() {
  return 'LocalePreferenceUpdateRequest(locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$LocalePreferenceUpdateRequestCopyWith<$Res> implements $LocalePreferenceUpdateRequestCopyWith<$Res> {
  factory _$LocalePreferenceUpdateRequestCopyWith(_LocalePreferenceUpdateRequest value, $Res Function(_LocalePreferenceUpdateRequest) _then) = __$LocalePreferenceUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: LocalePreferenceUpdateRequest.localeKey_) String locale
});




}
/// @nodoc
class __$LocalePreferenceUpdateRequestCopyWithImpl<$Res>
    implements _$LocalePreferenceUpdateRequestCopyWith<$Res> {
  __$LocalePreferenceUpdateRequestCopyWithImpl(this._self, this._then);

  final _LocalePreferenceUpdateRequest _self;
  final $Res Function(_LocalePreferenceUpdateRequest) _then;

/// Create a copy of LocalePreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,}) {
  return _then(_LocalePreferenceUpdateRequest(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
