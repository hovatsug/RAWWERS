// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_currency_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayCurrencyUpdateRequest {

/// displayCurrency
@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_) String? get displayCurrency;
/// Create a copy of DisplayCurrencyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayCurrencyUpdateRequestCopyWith<DisplayCurrencyUpdateRequest> get copyWith => _$DisplayCurrencyUpdateRequestCopyWithImpl<DisplayCurrencyUpdateRequest>(this as DisplayCurrencyUpdateRequest, _$identity);

  /// Serializes this DisplayCurrencyUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayCurrencyUpdateRequest&&(identical(other.displayCurrency, displayCurrency) || other.displayCurrency == displayCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayCurrency);

@override
String toString() {
  return 'DisplayCurrencyUpdateRequest(displayCurrency: $displayCurrency)';
}


}

/// @nodoc
abstract mixin class $DisplayCurrencyUpdateRequestCopyWith<$Res>  {
  factory $DisplayCurrencyUpdateRequestCopyWith(DisplayCurrencyUpdateRequest value, $Res Function(DisplayCurrencyUpdateRequest) _then) = _$DisplayCurrencyUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_) String? displayCurrency
});




}
/// @nodoc
class _$DisplayCurrencyUpdateRequestCopyWithImpl<$Res>
    implements $DisplayCurrencyUpdateRequestCopyWith<$Res> {
  _$DisplayCurrencyUpdateRequestCopyWithImpl(this._self, this._then);

  final DisplayCurrencyUpdateRequest _self;
  final $Res Function(DisplayCurrencyUpdateRequest) _then;

/// Create a copy of DisplayCurrencyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayCurrency = freezed,}) {
  return _then(_self.copyWith(
displayCurrency: freezed == displayCurrency ? _self.displayCurrency : displayCurrency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayCurrencyUpdateRequest].
extension DisplayCurrencyUpdateRequestPatterns on DisplayCurrencyUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayCurrencyUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayCurrencyUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayCurrencyUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _DisplayCurrencyUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayCurrencyUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayCurrencyUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_)  String? displayCurrency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayCurrencyUpdateRequest() when $default != null:
return $default(_that.displayCurrency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_)  String? displayCurrency)  $default,) {final _that = this;
switch (_that) {
case _DisplayCurrencyUpdateRequest():
return $default(_that.displayCurrency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_)  String? displayCurrency)?  $default,) {final _that = this;
switch (_that) {
case _DisplayCurrencyUpdateRequest() when $default != null:
return $default(_that.displayCurrency);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisplayCurrencyUpdateRequest extends DisplayCurrencyUpdateRequest {
  const _DisplayCurrencyUpdateRequest({@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_) this.displayCurrency}): super._();
  factory _DisplayCurrencyUpdateRequest.fromJson(Map<String, dynamic> json) => _$DisplayCurrencyUpdateRequestFromJson(json);

/// displayCurrency
@override@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_) final  String? displayCurrency;

/// Create a copy of DisplayCurrencyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayCurrencyUpdateRequestCopyWith<_DisplayCurrencyUpdateRequest> get copyWith => __$DisplayCurrencyUpdateRequestCopyWithImpl<_DisplayCurrencyUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayCurrencyUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayCurrencyUpdateRequest&&(identical(other.displayCurrency, displayCurrency) || other.displayCurrency == displayCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayCurrency);

@override
String toString() {
  return 'DisplayCurrencyUpdateRequest(displayCurrency: $displayCurrency)';
}


}

/// @nodoc
abstract mixin class _$DisplayCurrencyUpdateRequestCopyWith<$Res> implements $DisplayCurrencyUpdateRequestCopyWith<$Res> {
  factory _$DisplayCurrencyUpdateRequestCopyWith(_DisplayCurrencyUpdateRequest value, $Res Function(_DisplayCurrencyUpdateRequest) _then) = __$DisplayCurrencyUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisplayCurrencyUpdateRequest.displayCurrencyKey_) String? displayCurrency
});




}
/// @nodoc
class __$DisplayCurrencyUpdateRequestCopyWithImpl<$Res>
    implements _$DisplayCurrencyUpdateRequestCopyWith<$Res> {
  __$DisplayCurrencyUpdateRequestCopyWithImpl(this._self, this._then);

  final _DisplayCurrencyUpdateRequest _self;
  final $Res Function(_DisplayCurrencyUpdateRequest) _then;

/// Create a copy of DisplayCurrencyUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayCurrency = freezed,}) {
  return _then(_DisplayCurrencyUpdateRequest(
displayCurrency: freezed == displayCurrency ? _self.displayCurrency : displayCurrency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
