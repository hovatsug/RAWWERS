// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_device_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryDeviceView {

/// id
@JsonKey(name: DeliveryDeviceView.idKey_) String get id;/// deviceName
@JsonKey(name: DeliveryDeviceView.deviceNameKey_) String get deviceName;/// tokenPrefix
@JsonKey(name: DeliveryDeviceView.tokenPrefixKey_) String get tokenPrefix;/// pluginVersion
@JsonKey(name: DeliveryDeviceView.pluginVersionKey_) String? get pluginVersion;/// createdAt
@JsonKey(name: DeliveryDeviceView.createdAtKey_) DateTime get createdAt;/// lastUsedAt
@JsonKey(name: DeliveryDeviceView.lastUsedAtKey_) DateTime get lastUsedAt;
/// Create a copy of DeliveryDeviceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryDeviceViewCopyWith<DeliveryDeviceView> get copyWith => _$DeliveryDeviceViewCopyWithImpl<DeliveryDeviceView>(this as DeliveryDeviceView, _$identity);

  /// Serializes this DeliveryDeviceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryDeviceView&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.tokenPrefix, tokenPrefix) || other.tokenPrefix == tokenPrefix)&&(identical(other.pluginVersion, pluginVersion) || other.pluginVersion == pluginVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceName,tokenPrefix,pluginVersion,createdAt,lastUsedAt);

@override
String toString() {
  return 'DeliveryDeviceView(id: $id, deviceName: $deviceName, tokenPrefix: $tokenPrefix, pluginVersion: $pluginVersion, createdAt: $createdAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class $DeliveryDeviceViewCopyWith<$Res>  {
  factory $DeliveryDeviceViewCopyWith(DeliveryDeviceView value, $Res Function(DeliveryDeviceView) _then) = _$DeliveryDeviceViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DeliveryDeviceView.idKey_) String id,@JsonKey(name: DeliveryDeviceView.deviceNameKey_) String deviceName,@JsonKey(name: DeliveryDeviceView.tokenPrefixKey_) String tokenPrefix,@JsonKey(name: DeliveryDeviceView.pluginVersionKey_) String? pluginVersion,@JsonKey(name: DeliveryDeviceView.createdAtKey_) DateTime createdAt,@JsonKey(name: DeliveryDeviceView.lastUsedAtKey_) DateTime lastUsedAt
});




}
/// @nodoc
class _$DeliveryDeviceViewCopyWithImpl<$Res>
    implements $DeliveryDeviceViewCopyWith<$Res> {
  _$DeliveryDeviceViewCopyWithImpl(this._self, this._then);

  final DeliveryDeviceView _self;
  final $Res Function(DeliveryDeviceView) _then;

/// Create a copy of DeliveryDeviceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceName = null,Object? tokenPrefix = null,Object? pluginVersion = freezed,Object? createdAt = null,Object? lastUsedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,tokenPrefix: null == tokenPrefix ? _self.tokenPrefix : tokenPrefix // ignore: cast_nullable_to_non_nullable
as String,pluginVersion: freezed == pluginVersion ? _self.pluginVersion : pluginVersion // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryDeviceView].
extension DeliveryDeviceViewPatterns on DeliveryDeviceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryDeviceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryDeviceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryDeviceView value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryDeviceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryDeviceView value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryDeviceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DeliveryDeviceView.idKey_)  String id, @JsonKey(name: DeliveryDeviceView.deviceNameKey_)  String deviceName, @JsonKey(name: DeliveryDeviceView.tokenPrefixKey_)  String tokenPrefix, @JsonKey(name: DeliveryDeviceView.pluginVersionKey_)  String? pluginVersion, @JsonKey(name: DeliveryDeviceView.createdAtKey_)  DateTime createdAt, @JsonKey(name: DeliveryDeviceView.lastUsedAtKey_)  DateTime lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryDeviceView() when $default != null:
return $default(_that.id,_that.deviceName,_that.tokenPrefix,_that.pluginVersion,_that.createdAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DeliveryDeviceView.idKey_)  String id, @JsonKey(name: DeliveryDeviceView.deviceNameKey_)  String deviceName, @JsonKey(name: DeliveryDeviceView.tokenPrefixKey_)  String tokenPrefix, @JsonKey(name: DeliveryDeviceView.pluginVersionKey_)  String? pluginVersion, @JsonKey(name: DeliveryDeviceView.createdAtKey_)  DateTime createdAt, @JsonKey(name: DeliveryDeviceView.lastUsedAtKey_)  DateTime lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _DeliveryDeviceView():
return $default(_that.id,_that.deviceName,_that.tokenPrefix,_that.pluginVersion,_that.createdAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DeliveryDeviceView.idKey_)  String id, @JsonKey(name: DeliveryDeviceView.deviceNameKey_)  String deviceName, @JsonKey(name: DeliveryDeviceView.tokenPrefixKey_)  String tokenPrefix, @JsonKey(name: DeliveryDeviceView.pluginVersionKey_)  String? pluginVersion, @JsonKey(name: DeliveryDeviceView.createdAtKey_)  DateTime createdAt, @JsonKey(name: DeliveryDeviceView.lastUsedAtKey_)  DateTime lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryDeviceView() when $default != null:
return $default(_that.id,_that.deviceName,_that.tokenPrefix,_that.pluginVersion,_that.createdAt,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DeliveryDeviceView extends DeliveryDeviceView {
  const _DeliveryDeviceView({@JsonKey(name: DeliveryDeviceView.idKey_) required this.id, @JsonKey(name: DeliveryDeviceView.deviceNameKey_) required this.deviceName, @JsonKey(name: DeliveryDeviceView.tokenPrefixKey_) required this.tokenPrefix, @JsonKey(name: DeliveryDeviceView.pluginVersionKey_) this.pluginVersion, @JsonKey(name: DeliveryDeviceView.createdAtKey_) required this.createdAt, @JsonKey(name: DeliveryDeviceView.lastUsedAtKey_) required this.lastUsedAt}): super._();
  factory _DeliveryDeviceView.fromJson(Map<String, dynamic> json) => _$DeliveryDeviceViewFromJson(json);

/// id
@override@JsonKey(name: DeliveryDeviceView.idKey_) final  String id;
/// deviceName
@override@JsonKey(name: DeliveryDeviceView.deviceNameKey_) final  String deviceName;
/// tokenPrefix
@override@JsonKey(name: DeliveryDeviceView.tokenPrefixKey_) final  String tokenPrefix;
/// pluginVersion
@override@JsonKey(name: DeliveryDeviceView.pluginVersionKey_) final  String? pluginVersion;
/// createdAt
@override@JsonKey(name: DeliveryDeviceView.createdAtKey_) final  DateTime createdAt;
/// lastUsedAt
@override@JsonKey(name: DeliveryDeviceView.lastUsedAtKey_) final  DateTime lastUsedAt;

/// Create a copy of DeliveryDeviceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryDeviceViewCopyWith<_DeliveryDeviceView> get copyWith => __$DeliveryDeviceViewCopyWithImpl<_DeliveryDeviceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryDeviceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryDeviceView&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.tokenPrefix, tokenPrefix) || other.tokenPrefix == tokenPrefix)&&(identical(other.pluginVersion, pluginVersion) || other.pluginVersion == pluginVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceName,tokenPrefix,pluginVersion,createdAt,lastUsedAt);

@override
String toString() {
  return 'DeliveryDeviceView(id: $id, deviceName: $deviceName, tokenPrefix: $tokenPrefix, pluginVersion: $pluginVersion, createdAt: $createdAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$DeliveryDeviceViewCopyWith<$Res> implements $DeliveryDeviceViewCopyWith<$Res> {
  factory _$DeliveryDeviceViewCopyWith(_DeliveryDeviceView value, $Res Function(_DeliveryDeviceView) _then) = __$DeliveryDeviceViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DeliveryDeviceView.idKey_) String id,@JsonKey(name: DeliveryDeviceView.deviceNameKey_) String deviceName,@JsonKey(name: DeliveryDeviceView.tokenPrefixKey_) String tokenPrefix,@JsonKey(name: DeliveryDeviceView.pluginVersionKey_) String? pluginVersion,@JsonKey(name: DeliveryDeviceView.createdAtKey_) DateTime createdAt,@JsonKey(name: DeliveryDeviceView.lastUsedAtKey_) DateTime lastUsedAt
});




}
/// @nodoc
class __$DeliveryDeviceViewCopyWithImpl<$Res>
    implements _$DeliveryDeviceViewCopyWith<$Res> {
  __$DeliveryDeviceViewCopyWithImpl(this._self, this._then);

  final _DeliveryDeviceView _self;
  final $Res Function(_DeliveryDeviceView) _then;

/// Create a copy of DeliveryDeviceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceName = null,Object? tokenPrefix = null,Object? pluginVersion = freezed,Object? createdAt = null,Object? lastUsedAt = null,}) {
  return _then(_DeliveryDeviceView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,tokenPrefix: null == tokenPrefix ? _self.tokenPrefix : tokenPrefix // ignore: cast_nullable_to_non_nullable
as String,pluginVersion: freezed == pluginVersion ? _self.pluginVersion : pluginVersion // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
