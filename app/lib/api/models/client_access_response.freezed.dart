// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_access_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientAccessResponse {

/// enabled
@JsonKey(name: ClientAccessResponse.enabledKey_) bool get enabled;/// reason
@JsonKey(name: ClientAccessResponse.reasonKey_) String get reason;/// waitlistAvailable
@JsonKey(name: ClientAccessResponse.waitlistAvailableKey_) bool get waitlistAvailable;
/// Create a copy of ClientAccessResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientAccessResponseCopyWith<ClientAccessResponse> get copyWith => _$ClientAccessResponseCopyWithImpl<ClientAccessResponse>(this as ClientAccessResponse, _$identity);

  /// Serializes this ClientAccessResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientAccessResponse&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.waitlistAvailable, waitlistAvailable) || other.waitlistAvailable == waitlistAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,reason,waitlistAvailable);

@override
String toString() {
  return 'ClientAccessResponse(enabled: $enabled, reason: $reason, waitlistAvailable: $waitlistAvailable)';
}


}

/// @nodoc
abstract mixin class $ClientAccessResponseCopyWith<$Res>  {
  factory $ClientAccessResponseCopyWith(ClientAccessResponse value, $Res Function(ClientAccessResponse) _then) = _$ClientAccessResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientAccessResponse.enabledKey_) bool enabled,@JsonKey(name: ClientAccessResponse.reasonKey_) String reason,@JsonKey(name: ClientAccessResponse.waitlistAvailableKey_) bool waitlistAvailable
});




}
/// @nodoc
class _$ClientAccessResponseCopyWithImpl<$Res>
    implements $ClientAccessResponseCopyWith<$Res> {
  _$ClientAccessResponseCopyWithImpl(this._self, this._then);

  final ClientAccessResponse _self;
  final $Res Function(ClientAccessResponse) _then;

/// Create a copy of ClientAccessResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? reason = null,Object? waitlistAvailable = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,waitlistAvailable: null == waitlistAvailable ? _self.waitlistAvailable : waitlistAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientAccessResponse].
extension ClientAccessResponsePatterns on ClientAccessResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientAccessResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientAccessResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientAccessResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientAccessResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientAccessResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientAccessResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAccessResponse.enabledKey_)  bool enabled, @JsonKey(name: ClientAccessResponse.reasonKey_)  String reason, @JsonKey(name: ClientAccessResponse.waitlistAvailableKey_)  bool waitlistAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientAccessResponse() when $default != null:
return $default(_that.enabled,_that.reason,_that.waitlistAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientAccessResponse.enabledKey_)  bool enabled, @JsonKey(name: ClientAccessResponse.reasonKey_)  String reason, @JsonKey(name: ClientAccessResponse.waitlistAvailableKey_)  bool waitlistAvailable)  $default,) {final _that = this;
switch (_that) {
case _ClientAccessResponse():
return $default(_that.enabled,_that.reason,_that.waitlistAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientAccessResponse.enabledKey_)  bool enabled, @JsonKey(name: ClientAccessResponse.reasonKey_)  String reason, @JsonKey(name: ClientAccessResponse.waitlistAvailableKey_)  bool waitlistAvailable)?  $default,) {final _that = this;
switch (_that) {
case _ClientAccessResponse() when $default != null:
return $default(_that.enabled,_that.reason,_that.waitlistAvailable);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientAccessResponse extends ClientAccessResponse {
  const _ClientAccessResponse({@JsonKey(name: ClientAccessResponse.enabledKey_) required this.enabled, @JsonKey(name: ClientAccessResponse.reasonKey_) required this.reason, @JsonKey(name: ClientAccessResponse.waitlistAvailableKey_) this.waitlistAvailable = true}): super._();
  factory _ClientAccessResponse.fromJson(Map<String, dynamic> json) => _$ClientAccessResponseFromJson(json);

/// enabled
@override@JsonKey(name: ClientAccessResponse.enabledKey_) final  bool enabled;
/// reason
@override@JsonKey(name: ClientAccessResponse.reasonKey_) final  String reason;
/// waitlistAvailable
@override@JsonKey(name: ClientAccessResponse.waitlistAvailableKey_) final  bool waitlistAvailable;

/// Create a copy of ClientAccessResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientAccessResponseCopyWith<_ClientAccessResponse> get copyWith => __$ClientAccessResponseCopyWithImpl<_ClientAccessResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientAccessResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientAccessResponse&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.waitlistAvailable, waitlistAvailable) || other.waitlistAvailable == waitlistAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,reason,waitlistAvailable);

@override
String toString() {
  return 'ClientAccessResponse(enabled: $enabled, reason: $reason, waitlistAvailable: $waitlistAvailable)';
}


}

/// @nodoc
abstract mixin class _$ClientAccessResponseCopyWith<$Res> implements $ClientAccessResponseCopyWith<$Res> {
  factory _$ClientAccessResponseCopyWith(_ClientAccessResponse value, $Res Function(_ClientAccessResponse) _then) = __$ClientAccessResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientAccessResponse.enabledKey_) bool enabled,@JsonKey(name: ClientAccessResponse.reasonKey_) String reason,@JsonKey(name: ClientAccessResponse.waitlistAvailableKey_) bool waitlistAvailable
});




}
/// @nodoc
class __$ClientAccessResponseCopyWithImpl<$Res>
    implements _$ClientAccessResponseCopyWith<$Res> {
  __$ClientAccessResponseCopyWithImpl(this._self, this._then);

  final _ClientAccessResponse _self;
  final $Res Function(_ClientAccessResponse) _then;

/// Create a copy of ClientAccessResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? reason = null,Object? waitlistAvailable = null,}) {
  return _then(_ClientAccessResponse(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,waitlistAvailable: null == waitlistAvailable ? _self.waitlistAvailable : waitlistAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
