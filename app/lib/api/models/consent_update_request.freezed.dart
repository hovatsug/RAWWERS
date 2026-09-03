// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consent_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsentUpdateRequest {

/// channel
@JsonKey(name: ConsentUpdateRequest.channelKey_) ConsentChannel get channel;/// scope
@JsonKey(name: ConsentUpdateRequest.scopeKey_) ConsentScope get scope;/// granted
@JsonKey(name: ConsentUpdateRequest.grantedKey_) bool get granted;/// source
@JsonKey(name: ConsentUpdateRequest.sourceKey_) String get source;/// metadata
@JsonKey(name: ConsentUpdateRequest.metadataKey_) Map<String, dynamic>? get metadata;
/// Create a copy of ConsentUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentUpdateRequestCopyWith<ConsentUpdateRequest> get copyWith => _$ConsentUpdateRequestCopyWithImpl<ConsentUpdateRequest>(this as ConsentUpdateRequest, _$identity);

  /// Serializes this ConsentUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentUpdateRequest&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.granted, granted) || other.granted == granted)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channel,scope,granted,source,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ConsentUpdateRequest(channel: $channel, scope: $scope, granted: $granted, source: $source, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ConsentUpdateRequestCopyWith<$Res>  {
  factory $ConsentUpdateRequestCopyWith(ConsentUpdateRequest value, $Res Function(ConsentUpdateRequest) _then) = _$ConsentUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ConsentUpdateRequest.channelKey_) ConsentChannel channel,@JsonKey(name: ConsentUpdateRequest.scopeKey_) ConsentScope scope,@JsonKey(name: ConsentUpdateRequest.grantedKey_) bool granted,@JsonKey(name: ConsentUpdateRequest.sourceKey_) String source,@JsonKey(name: ConsentUpdateRequest.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ConsentUpdateRequestCopyWithImpl<$Res>
    implements $ConsentUpdateRequestCopyWith<$Res> {
  _$ConsentUpdateRequestCopyWithImpl(this._self, this._then);

  final ConsentUpdateRequest _self;
  final $Res Function(ConsentUpdateRequest) _then;

/// Create a copy of ConsentUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channel = null,Object? scope = null,Object? granted = null,Object? source = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ConsentChannel,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ConsentScope,granted: null == granted ? _self.granted : granted // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsentUpdateRequest].
extension ConsentUpdateRequestPatterns on ConsentUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsentUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsentUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsentUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ConsentUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsentUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ConsentUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ConsentUpdateRequest.channelKey_)  ConsentChannel channel, @JsonKey(name: ConsentUpdateRequest.scopeKey_)  ConsentScope scope, @JsonKey(name: ConsentUpdateRequest.grantedKey_)  bool granted, @JsonKey(name: ConsentUpdateRequest.sourceKey_)  String source, @JsonKey(name: ConsentUpdateRequest.metadataKey_)  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsentUpdateRequest() when $default != null:
return $default(_that.channel,_that.scope,_that.granted,_that.source,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ConsentUpdateRequest.channelKey_)  ConsentChannel channel, @JsonKey(name: ConsentUpdateRequest.scopeKey_)  ConsentScope scope, @JsonKey(name: ConsentUpdateRequest.grantedKey_)  bool granted, @JsonKey(name: ConsentUpdateRequest.sourceKey_)  String source, @JsonKey(name: ConsentUpdateRequest.metadataKey_)  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ConsentUpdateRequest():
return $default(_that.channel,_that.scope,_that.granted,_that.source,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ConsentUpdateRequest.channelKey_)  ConsentChannel channel, @JsonKey(name: ConsentUpdateRequest.scopeKey_)  ConsentScope scope, @JsonKey(name: ConsentUpdateRequest.grantedKey_)  bool granted, @JsonKey(name: ConsentUpdateRequest.sourceKey_)  String source, @JsonKey(name: ConsentUpdateRequest.metadataKey_)  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ConsentUpdateRequest() when $default != null:
return $default(_that.channel,_that.scope,_that.granted,_that.source,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ConsentUpdateRequest extends ConsentUpdateRequest {
  const _ConsentUpdateRequest({@JsonKey(name: ConsentUpdateRequest.channelKey_) required this.channel, @JsonKey(name: ConsentUpdateRequest.scopeKey_) required this.scope, @JsonKey(name: ConsentUpdateRequest.grantedKey_) required this.granted, @JsonKey(name: ConsentUpdateRequest.sourceKey_) this.source = 'in_app_toggle', @JsonKey(name: ConsentUpdateRequest.metadataKey_) final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _ConsentUpdateRequest.fromJson(Map<String, dynamic> json) => _$ConsentUpdateRequestFromJson(json);

/// channel
@override@JsonKey(name: ConsentUpdateRequest.channelKey_) final  ConsentChannel channel;
/// scope
@override@JsonKey(name: ConsentUpdateRequest.scopeKey_) final  ConsentScope scope;
/// granted
@override@JsonKey(name: ConsentUpdateRequest.grantedKey_) final  bool granted;
/// source
@override@JsonKey(name: ConsentUpdateRequest.sourceKey_) final  String source;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: ConsentUpdateRequest.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ConsentUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentUpdateRequestCopyWith<_ConsentUpdateRequest> get copyWith => __$ConsentUpdateRequestCopyWithImpl<_ConsentUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsentUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsentUpdateRequest&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.granted, granted) || other.granted == granted)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channel,scope,granted,source,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ConsentUpdateRequest(channel: $channel, scope: $scope, granted: $granted, source: $source, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ConsentUpdateRequestCopyWith<$Res> implements $ConsentUpdateRequestCopyWith<$Res> {
  factory _$ConsentUpdateRequestCopyWith(_ConsentUpdateRequest value, $Res Function(_ConsentUpdateRequest) _then) = __$ConsentUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ConsentUpdateRequest.channelKey_) ConsentChannel channel,@JsonKey(name: ConsentUpdateRequest.scopeKey_) ConsentScope scope,@JsonKey(name: ConsentUpdateRequest.grantedKey_) bool granted,@JsonKey(name: ConsentUpdateRequest.sourceKey_) String source,@JsonKey(name: ConsentUpdateRequest.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ConsentUpdateRequestCopyWithImpl<$Res>
    implements _$ConsentUpdateRequestCopyWith<$Res> {
  __$ConsentUpdateRequestCopyWithImpl(this._self, this._then);

  final _ConsentUpdateRequest _self;
  final $Res Function(_ConsentUpdateRequest) _then;

/// Create a copy of ConsentUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channel = null,Object? scope = null,Object? granted = null,Object? source = null,Object? metadata = freezed,}) {
  return _then(_ConsentUpdateRequest(
channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ConsentChannel,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ConsentScope,granted: null == granted ? _self.granted : granted // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
