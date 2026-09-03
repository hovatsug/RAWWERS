// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webhook_ack_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WebhookAckResponse {

/// ok
@JsonKey(name: WebhookAckResponse.okKey_) bool get ok;
/// Create a copy of WebhookAckResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebhookAckResponseCopyWith<WebhookAckResponse> get copyWith => _$WebhookAckResponseCopyWithImpl<WebhookAckResponse>(this as WebhookAckResponse, _$identity);

  /// Serializes this WebhookAckResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebhookAckResponse&&(identical(other.ok, ok) || other.ok == ok));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok);

@override
String toString() {
  return 'WebhookAckResponse(ok: $ok)';
}


}

/// @nodoc
abstract mixin class $WebhookAckResponseCopyWith<$Res>  {
  factory $WebhookAckResponseCopyWith(WebhookAckResponse value, $Res Function(WebhookAckResponse) _then) = _$WebhookAckResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: WebhookAckResponse.okKey_) bool ok
});




}
/// @nodoc
class _$WebhookAckResponseCopyWithImpl<$Res>
    implements $WebhookAckResponseCopyWith<$Res> {
  _$WebhookAckResponseCopyWithImpl(this._self, this._then);

  final WebhookAckResponse _self;
  final $Res Function(WebhookAckResponse) _then;

/// Create a copy of WebhookAckResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,}) {
  return _then(_self.copyWith(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WebhookAckResponse].
extension WebhookAckResponsePatterns on WebhookAckResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebhookAckResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebhookAckResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebhookAckResponse value)  $default,){
final _that = this;
switch (_that) {
case _WebhookAckResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebhookAckResponse value)?  $default,){
final _that = this;
switch (_that) {
case _WebhookAckResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: WebhookAckResponse.okKey_)  bool ok)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebhookAckResponse() when $default != null:
return $default(_that.ok);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: WebhookAckResponse.okKey_)  bool ok)  $default,) {final _that = this;
switch (_that) {
case _WebhookAckResponse():
return $default(_that.ok);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: WebhookAckResponse.okKey_)  bool ok)?  $default,) {final _that = this;
switch (_that) {
case _WebhookAckResponse() when $default != null:
return $default(_that.ok);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _WebhookAckResponse extends WebhookAckResponse {
  const _WebhookAckResponse({@JsonKey(name: WebhookAckResponse.okKey_) required this.ok}): super._();
  factory _WebhookAckResponse.fromJson(Map<String, dynamic> json) => _$WebhookAckResponseFromJson(json);

/// ok
@override@JsonKey(name: WebhookAckResponse.okKey_) final  bool ok;

/// Create a copy of WebhookAckResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebhookAckResponseCopyWith<_WebhookAckResponse> get copyWith => __$WebhookAckResponseCopyWithImpl<_WebhookAckResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebhookAckResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebhookAckResponse&&(identical(other.ok, ok) || other.ok == ok));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok);

@override
String toString() {
  return 'WebhookAckResponse(ok: $ok)';
}


}

/// @nodoc
abstract mixin class _$WebhookAckResponseCopyWith<$Res> implements $WebhookAckResponseCopyWith<$Res> {
  factory _$WebhookAckResponseCopyWith(_WebhookAckResponse value, $Res Function(_WebhookAckResponse) _then) = __$WebhookAckResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: WebhookAckResponse.okKey_) bool ok
});




}
/// @nodoc
class __$WebhookAckResponseCopyWithImpl<$Res>
    implements _$WebhookAckResponseCopyWith<$Res> {
  __$WebhookAckResponseCopyWithImpl(this._self, this._then);

  final _WebhookAckResponse _self;
  final $Res Function(_WebhookAckResponse) _then;

/// Create a copy of WebhookAckResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,}) {
  return _then(_WebhookAckResponse(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
