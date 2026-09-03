// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consent_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsentView {

/// id
@JsonKey(name: ConsentView.idKey_) String get id;/// userId
@JsonKey(name: ConsentView.userIdKey_) String get userId;/// channel
@JsonKey(name: ConsentView.channelKey_) ConsentChannel get channel;/// scope
@JsonKey(name: ConsentView.scopeKey_) ConsentScope get scope;/// granted
@JsonKey(name: ConsentView.grantedKey_) bool get granted;/// grantedAt
@JsonKey(name: ConsentView.grantedAtKey_) DateTime get grantedAt;/// revokedAt
@JsonKey(name: ConsentView.revokedAtKey_) DateTime? get revokedAt;/// source
@JsonKey(name: ConsentView.sourceKey_) String get source;/// metadata
@JsonKey(name: ConsentView.metadataKey_) Map<String, dynamic>? get metadata;
/// Create a copy of ConsentView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentViewCopyWith<ConsentView> get copyWith => _$ConsentViewCopyWithImpl<ConsentView>(this as ConsentView, _$identity);

  /// Serializes this ConsentView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentView&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.granted, granted) || other.granted == granted)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,channel,scope,granted,grantedAt,revokedAt,source,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ConsentView(id: $id, userId: $userId, channel: $channel, scope: $scope, granted: $granted, grantedAt: $grantedAt, revokedAt: $revokedAt, source: $source, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ConsentViewCopyWith<$Res>  {
  factory $ConsentViewCopyWith(ConsentView value, $Res Function(ConsentView) _then) = _$ConsentViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ConsentView.idKey_) String id,@JsonKey(name: ConsentView.userIdKey_) String userId,@JsonKey(name: ConsentView.channelKey_) ConsentChannel channel,@JsonKey(name: ConsentView.scopeKey_) ConsentScope scope,@JsonKey(name: ConsentView.grantedKey_) bool granted,@JsonKey(name: ConsentView.grantedAtKey_) DateTime grantedAt,@JsonKey(name: ConsentView.revokedAtKey_) DateTime? revokedAt,@JsonKey(name: ConsentView.sourceKey_) String source,@JsonKey(name: ConsentView.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ConsentViewCopyWithImpl<$Res>
    implements $ConsentViewCopyWith<$Res> {
  _$ConsentViewCopyWithImpl(this._self, this._then);

  final ConsentView _self;
  final $Res Function(ConsentView) _then;

/// Create a copy of ConsentView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? channel = null,Object? scope = null,Object? granted = null,Object? grantedAt = null,Object? revokedAt = freezed,Object? source = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ConsentChannel,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ConsentScope,granted: null == granted ? _self.granted : granted // ignore: cast_nullable_to_non_nullable
as bool,grantedAt: null == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsentView].
extension ConsentViewPatterns on ConsentView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsentView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsentView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsentView value)  $default,){
final _that = this;
switch (_that) {
case _ConsentView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsentView value)?  $default,){
final _that = this;
switch (_that) {
case _ConsentView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ConsentView.idKey_)  String id, @JsonKey(name: ConsentView.userIdKey_)  String userId, @JsonKey(name: ConsentView.channelKey_)  ConsentChannel channel, @JsonKey(name: ConsentView.scopeKey_)  ConsentScope scope, @JsonKey(name: ConsentView.grantedKey_)  bool granted, @JsonKey(name: ConsentView.grantedAtKey_)  DateTime grantedAt, @JsonKey(name: ConsentView.revokedAtKey_)  DateTime? revokedAt, @JsonKey(name: ConsentView.sourceKey_)  String source, @JsonKey(name: ConsentView.metadataKey_)  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsentView() when $default != null:
return $default(_that.id,_that.userId,_that.channel,_that.scope,_that.granted,_that.grantedAt,_that.revokedAt,_that.source,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ConsentView.idKey_)  String id, @JsonKey(name: ConsentView.userIdKey_)  String userId, @JsonKey(name: ConsentView.channelKey_)  ConsentChannel channel, @JsonKey(name: ConsentView.scopeKey_)  ConsentScope scope, @JsonKey(name: ConsentView.grantedKey_)  bool granted, @JsonKey(name: ConsentView.grantedAtKey_)  DateTime grantedAt, @JsonKey(name: ConsentView.revokedAtKey_)  DateTime? revokedAt, @JsonKey(name: ConsentView.sourceKey_)  String source, @JsonKey(name: ConsentView.metadataKey_)  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ConsentView():
return $default(_that.id,_that.userId,_that.channel,_that.scope,_that.granted,_that.grantedAt,_that.revokedAt,_that.source,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ConsentView.idKey_)  String id, @JsonKey(name: ConsentView.userIdKey_)  String userId, @JsonKey(name: ConsentView.channelKey_)  ConsentChannel channel, @JsonKey(name: ConsentView.scopeKey_)  ConsentScope scope, @JsonKey(name: ConsentView.grantedKey_)  bool granted, @JsonKey(name: ConsentView.grantedAtKey_)  DateTime grantedAt, @JsonKey(name: ConsentView.revokedAtKey_)  DateTime? revokedAt, @JsonKey(name: ConsentView.sourceKey_)  String source, @JsonKey(name: ConsentView.metadataKey_)  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ConsentView() when $default != null:
return $default(_that.id,_that.userId,_that.channel,_that.scope,_that.granted,_that.grantedAt,_that.revokedAt,_that.source,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ConsentView extends ConsentView {
  const _ConsentView({@JsonKey(name: ConsentView.idKey_) required this.id, @JsonKey(name: ConsentView.userIdKey_) required this.userId, @JsonKey(name: ConsentView.channelKey_) required this.channel, @JsonKey(name: ConsentView.scopeKey_) required this.scope, @JsonKey(name: ConsentView.grantedKey_) required this.granted, @JsonKey(name: ConsentView.grantedAtKey_) required this.grantedAt, @JsonKey(name: ConsentView.revokedAtKey_) this.revokedAt, @JsonKey(name: ConsentView.sourceKey_) required this.source, @JsonKey(name: ConsentView.metadataKey_) final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _ConsentView.fromJson(Map<String, dynamic> json) => _$ConsentViewFromJson(json);

/// id
@override@JsonKey(name: ConsentView.idKey_) final  String id;
/// userId
@override@JsonKey(name: ConsentView.userIdKey_) final  String userId;
/// channel
@override@JsonKey(name: ConsentView.channelKey_) final  ConsentChannel channel;
/// scope
@override@JsonKey(name: ConsentView.scopeKey_) final  ConsentScope scope;
/// granted
@override@JsonKey(name: ConsentView.grantedKey_) final  bool granted;
/// grantedAt
@override@JsonKey(name: ConsentView.grantedAtKey_) final  DateTime grantedAt;
/// revokedAt
@override@JsonKey(name: ConsentView.revokedAtKey_) final  DateTime? revokedAt;
/// source
@override@JsonKey(name: ConsentView.sourceKey_) final  String source;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: ConsentView.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ConsentView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentViewCopyWith<_ConsentView> get copyWith => __$ConsentViewCopyWithImpl<_ConsentView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsentViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsentView&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.granted, granted) || other.granted == granted)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,channel,scope,granted,grantedAt,revokedAt,source,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ConsentView(id: $id, userId: $userId, channel: $channel, scope: $scope, granted: $granted, grantedAt: $grantedAt, revokedAt: $revokedAt, source: $source, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ConsentViewCopyWith<$Res> implements $ConsentViewCopyWith<$Res> {
  factory _$ConsentViewCopyWith(_ConsentView value, $Res Function(_ConsentView) _then) = __$ConsentViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ConsentView.idKey_) String id,@JsonKey(name: ConsentView.userIdKey_) String userId,@JsonKey(name: ConsentView.channelKey_) ConsentChannel channel,@JsonKey(name: ConsentView.scopeKey_) ConsentScope scope,@JsonKey(name: ConsentView.grantedKey_) bool granted,@JsonKey(name: ConsentView.grantedAtKey_) DateTime grantedAt,@JsonKey(name: ConsentView.revokedAtKey_) DateTime? revokedAt,@JsonKey(name: ConsentView.sourceKey_) String source,@JsonKey(name: ConsentView.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ConsentViewCopyWithImpl<$Res>
    implements _$ConsentViewCopyWith<$Res> {
  __$ConsentViewCopyWithImpl(this._self, this._then);

  final _ConsentView _self;
  final $Res Function(_ConsentView) _then;

/// Create a copy of ConsentView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? channel = null,Object? scope = null,Object? granted = null,Object? grantedAt = null,Object? revokedAt = freezed,Object? source = null,Object? metadata = freezed,}) {
  return _then(_ConsentView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ConsentChannel,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ConsentScope,granted: null == granted ? _self.granted : granted // ignore: cast_nullable_to_non_nullable
as bool,grantedAt: null == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
