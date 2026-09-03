// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsCreateRequest {

/// eventName
@JsonKey(name: AnalyticsCreateRequest.eventNameKey_) String get eventName;/// properties
@JsonKey(name: AnalyticsCreateRequest.propertiesKey_) Map<String, dynamic>? get properties;/// sessionId
@JsonKey(name: AnalyticsCreateRequest.sessionIdKey_) String? get sessionId;
/// Create a copy of AnalyticsCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsCreateRequestCopyWith<AnalyticsCreateRequest> get copyWith => _$AnalyticsCreateRequestCopyWithImpl<AnalyticsCreateRequest>(this as AnalyticsCreateRequest, _$identity);

  /// Serializes this AnalyticsCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsCreateRequest&&(identical(other.eventName, eventName) || other.eventName == eventName)&&const DeepCollectionEquality().equals(other.properties, properties)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventName,const DeepCollectionEquality().hash(properties),sessionId);

@override
String toString() {
  return 'AnalyticsCreateRequest(eventName: $eventName, properties: $properties, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $AnalyticsCreateRequestCopyWith<$Res>  {
  factory $AnalyticsCreateRequestCopyWith(AnalyticsCreateRequest value, $Res Function(AnalyticsCreateRequest) _then) = _$AnalyticsCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AnalyticsCreateRequest.eventNameKey_) String eventName,@JsonKey(name: AnalyticsCreateRequest.propertiesKey_) Map<String, dynamic>? properties,@JsonKey(name: AnalyticsCreateRequest.sessionIdKey_) String? sessionId
});




}
/// @nodoc
class _$AnalyticsCreateRequestCopyWithImpl<$Res>
    implements $AnalyticsCreateRequestCopyWith<$Res> {
  _$AnalyticsCreateRequestCopyWithImpl(this._self, this._then);

  final AnalyticsCreateRequest _self;
  final $Res Function(AnalyticsCreateRequest) _then;

/// Create a copy of AnalyticsCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventName = null,Object? properties = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,properties: freezed == properties ? _self.properties : properties // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsCreateRequest].
extension AnalyticsCreateRequestPatterns on AnalyticsCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AnalyticsCreateRequest.eventNameKey_)  String eventName, @JsonKey(name: AnalyticsCreateRequest.propertiesKey_)  Map<String, dynamic>? properties, @JsonKey(name: AnalyticsCreateRequest.sessionIdKey_)  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsCreateRequest() when $default != null:
return $default(_that.eventName,_that.properties,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AnalyticsCreateRequest.eventNameKey_)  String eventName, @JsonKey(name: AnalyticsCreateRequest.propertiesKey_)  Map<String, dynamic>? properties, @JsonKey(name: AnalyticsCreateRequest.sessionIdKey_)  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsCreateRequest():
return $default(_that.eventName,_that.properties,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AnalyticsCreateRequest.eventNameKey_)  String eventName, @JsonKey(name: AnalyticsCreateRequest.propertiesKey_)  Map<String, dynamic>? properties, @JsonKey(name: AnalyticsCreateRequest.sessionIdKey_)  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsCreateRequest() when $default != null:
return $default(_that.eventName,_that.properties,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AnalyticsCreateRequest extends AnalyticsCreateRequest {
  const _AnalyticsCreateRequest({@JsonKey(name: AnalyticsCreateRequest.eventNameKey_) required this.eventName, @JsonKey(name: AnalyticsCreateRequest.propertiesKey_) final  Map<String, dynamic>? properties, @JsonKey(name: AnalyticsCreateRequest.sessionIdKey_) this.sessionId}): _properties = properties,super._();
  factory _AnalyticsCreateRequest.fromJson(Map<String, dynamic> json) => _$AnalyticsCreateRequestFromJson(json);

/// eventName
@override@JsonKey(name: AnalyticsCreateRequest.eventNameKey_) final  String eventName;
/// properties
 final  Map<String, dynamic>? _properties;
/// properties
@override@JsonKey(name: AnalyticsCreateRequest.propertiesKey_) Map<String, dynamic>? get properties {
  final value = _properties;
  if (value == null) return null;
  if (_properties is EqualUnmodifiableMapView) return _properties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// sessionId
@override@JsonKey(name: AnalyticsCreateRequest.sessionIdKey_) final  String? sessionId;

/// Create a copy of AnalyticsCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsCreateRequestCopyWith<_AnalyticsCreateRequest> get copyWith => __$AnalyticsCreateRequestCopyWithImpl<_AnalyticsCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsCreateRequest&&(identical(other.eventName, eventName) || other.eventName == eventName)&&const DeepCollectionEquality().equals(other._properties, _properties)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventName,const DeepCollectionEquality().hash(_properties),sessionId);

@override
String toString() {
  return 'AnalyticsCreateRequest(eventName: $eventName, properties: $properties, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsCreateRequestCopyWith<$Res> implements $AnalyticsCreateRequestCopyWith<$Res> {
  factory _$AnalyticsCreateRequestCopyWith(_AnalyticsCreateRequest value, $Res Function(_AnalyticsCreateRequest) _then) = __$AnalyticsCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AnalyticsCreateRequest.eventNameKey_) String eventName,@JsonKey(name: AnalyticsCreateRequest.propertiesKey_) Map<String, dynamic>? properties,@JsonKey(name: AnalyticsCreateRequest.sessionIdKey_) String? sessionId
});




}
/// @nodoc
class __$AnalyticsCreateRequestCopyWithImpl<$Res>
    implements _$AnalyticsCreateRequestCopyWith<$Res> {
  __$AnalyticsCreateRequestCopyWithImpl(this._self, this._then);

  final _AnalyticsCreateRequest _self;
  final $Res Function(_AnalyticsCreateRequest) _then;

/// Create a copy of AnalyticsCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventName = null,Object? properties = freezed,Object? sessionId = freezed,}) {
  return _then(_AnalyticsCreateRequest(
eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,properties: freezed == properties ? _self._properties : properties // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
