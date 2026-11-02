// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_booking_marketing_settings_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateBookingMarketingSettingsRequest {

/// allowMarketing
@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_) bool? get allowMarketing;/// includesChildren
@JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_) bool? get includesChildren;
/// Create a copy of UpdateBookingMarketingSettingsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateBookingMarketingSettingsRequestCopyWith<UpdateBookingMarketingSettingsRequest> get copyWith => _$UpdateBookingMarketingSettingsRequestCopyWithImpl<UpdateBookingMarketingSettingsRequest>(this as UpdateBookingMarketingSettingsRequest, _$identity);

  /// Serializes this UpdateBookingMarketingSettingsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateBookingMarketingSettingsRequest&&(identical(other.allowMarketing, allowMarketing) || other.allowMarketing == allowMarketing)&&(identical(other.includesChildren, includesChildren) || other.includesChildren == includesChildren));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowMarketing,includesChildren);

@override
String toString() {
  return 'UpdateBookingMarketingSettingsRequest(allowMarketing: $allowMarketing, includesChildren: $includesChildren)';
}


}

/// @nodoc
abstract mixin class $UpdateBookingMarketingSettingsRequestCopyWith<$Res>  {
  factory $UpdateBookingMarketingSettingsRequestCopyWith(UpdateBookingMarketingSettingsRequest value, $Res Function(UpdateBookingMarketingSettingsRequest) _then) = _$UpdateBookingMarketingSettingsRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_) bool? allowMarketing,@JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_) bool? includesChildren
});




}
/// @nodoc
class _$UpdateBookingMarketingSettingsRequestCopyWithImpl<$Res>
    implements $UpdateBookingMarketingSettingsRequestCopyWith<$Res> {
  _$UpdateBookingMarketingSettingsRequestCopyWithImpl(this._self, this._then);

  final UpdateBookingMarketingSettingsRequest _self;
  final $Res Function(UpdateBookingMarketingSettingsRequest) _then;

/// Create a copy of UpdateBookingMarketingSettingsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allowMarketing = freezed,Object? includesChildren = freezed,}) {
  return _then(_self.copyWith(
allowMarketing: freezed == allowMarketing ? _self.allowMarketing : allowMarketing // ignore: cast_nullable_to_non_nullable
as bool?,includesChildren: freezed == includesChildren ? _self.includesChildren : includesChildren // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateBookingMarketingSettingsRequest].
extension UpdateBookingMarketingSettingsRequestPatterns on UpdateBookingMarketingSettingsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateBookingMarketingSettingsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateBookingMarketingSettingsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateBookingMarketingSettingsRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateBookingMarketingSettingsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateBookingMarketingSettingsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateBookingMarketingSettingsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_)  bool? allowMarketing, @JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_)  bool? includesChildren)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateBookingMarketingSettingsRequest() when $default != null:
return $default(_that.allowMarketing,_that.includesChildren);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_)  bool? allowMarketing, @JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_)  bool? includesChildren)  $default,) {final _that = this;
switch (_that) {
case _UpdateBookingMarketingSettingsRequest():
return $default(_that.allowMarketing,_that.includesChildren);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_)  bool? allowMarketing, @JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_)  bool? includesChildren)?  $default,) {final _that = this;
switch (_that) {
case _UpdateBookingMarketingSettingsRequest() when $default != null:
return $default(_that.allowMarketing,_that.includesChildren);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpdateBookingMarketingSettingsRequest extends UpdateBookingMarketingSettingsRequest {
  const _UpdateBookingMarketingSettingsRequest({@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_) this.allowMarketing, @JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_) this.includesChildren}): super._();
  factory _UpdateBookingMarketingSettingsRequest.fromJson(Map<String, dynamic> json) => _$UpdateBookingMarketingSettingsRequestFromJson(json);

/// allowMarketing
@override@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_) final  bool? allowMarketing;
/// includesChildren
@override@JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_) final  bool? includesChildren;

/// Create a copy of UpdateBookingMarketingSettingsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateBookingMarketingSettingsRequestCopyWith<_UpdateBookingMarketingSettingsRequest> get copyWith => __$UpdateBookingMarketingSettingsRequestCopyWithImpl<_UpdateBookingMarketingSettingsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateBookingMarketingSettingsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateBookingMarketingSettingsRequest&&(identical(other.allowMarketing, allowMarketing) || other.allowMarketing == allowMarketing)&&(identical(other.includesChildren, includesChildren) || other.includesChildren == includesChildren));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowMarketing,includesChildren);

@override
String toString() {
  return 'UpdateBookingMarketingSettingsRequest(allowMarketing: $allowMarketing, includesChildren: $includesChildren)';
}


}

/// @nodoc
abstract mixin class _$UpdateBookingMarketingSettingsRequestCopyWith<$Res> implements $UpdateBookingMarketingSettingsRequestCopyWith<$Res> {
  factory _$UpdateBookingMarketingSettingsRequestCopyWith(_UpdateBookingMarketingSettingsRequest value, $Res Function(_UpdateBookingMarketingSettingsRequest) _then) = __$UpdateBookingMarketingSettingsRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_) bool? allowMarketing,@JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_) bool? includesChildren
});




}
/// @nodoc
class __$UpdateBookingMarketingSettingsRequestCopyWithImpl<$Res>
    implements _$UpdateBookingMarketingSettingsRequestCopyWith<$Res> {
  __$UpdateBookingMarketingSettingsRequestCopyWithImpl(this._self, this._then);

  final _UpdateBookingMarketingSettingsRequest _self;
  final $Res Function(_UpdateBookingMarketingSettingsRequest) _then;

/// Create a copy of UpdateBookingMarketingSettingsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allowMarketing = freezed,Object? includesChildren = freezed,}) {
  return _then(_UpdateBookingMarketingSettingsRequest(
allowMarketing: freezed == allowMarketing ? _self.allowMarketing : allowMarketing // ignore: cast_nullable_to_non_nullable
as bool?,includesChildren: freezed == includesChildren ? _self.includesChildren : includesChildren // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
