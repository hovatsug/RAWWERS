// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_exception_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityExceptionView {

/// startAtUtc
@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_) DateTime get startAtUtc;/// endAtUtc
@JsonKey(name: AvailabilityExceptionView.endAtUtcKey_) DateTime get endAtUtc;/// reason
@JsonKey(name: AvailabilityExceptionView.reasonKey_) String? get reason;/// id
@JsonKey(name: AvailabilityExceptionView.idKey_) String get id;/// proUserId
@JsonKey(name: AvailabilityExceptionView.proUserIdKey_) String get proUserId;/// createdAt
@JsonKey(name: AvailabilityExceptionView.createdAtKey_) DateTime get createdAt;
/// Create a copy of AvailabilityExceptionView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityExceptionViewCopyWith<AvailabilityExceptionView> get copyWith => _$AvailabilityExceptionViewCopyWithImpl<AvailabilityExceptionView>(this as AvailabilityExceptionView, _$identity);

  /// Serializes this AvailabilityExceptionView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityExceptionView&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc,reason,id,proUserId,createdAt);

@override
String toString() {
  return 'AvailabilityExceptionView(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, reason: $reason, id: $id, proUserId: $proUserId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AvailabilityExceptionViewCopyWith<$Res>  {
  factory $AvailabilityExceptionViewCopyWith(AvailabilityExceptionView value, $Res Function(AvailabilityExceptionView) _then) = _$AvailabilityExceptionViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: AvailabilityExceptionView.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: AvailabilityExceptionView.reasonKey_) String? reason,@JsonKey(name: AvailabilityExceptionView.idKey_) String id,@JsonKey(name: AvailabilityExceptionView.proUserIdKey_) String proUserId,@JsonKey(name: AvailabilityExceptionView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$AvailabilityExceptionViewCopyWithImpl<$Res>
    implements $AvailabilityExceptionViewCopyWith<$Res> {
  _$AvailabilityExceptionViewCopyWithImpl(this._self, this._then);

  final AvailabilityExceptionView _self;
  final $Res Function(AvailabilityExceptionView) _then;

/// Create a copy of AvailabilityExceptionView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAtUtc = null,Object? endAtUtc = null,Object? reason = freezed,Object? id = null,Object? proUserId = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityExceptionView].
extension AvailabilityExceptionViewPatterns on AvailabilityExceptionView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityExceptionView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityExceptionView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityExceptionView value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityExceptionView value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: AvailabilityExceptionView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: AvailabilityExceptionView.reasonKey_)  String? reason, @JsonKey(name: AvailabilityExceptionView.idKey_)  String id, @JsonKey(name: AvailabilityExceptionView.proUserIdKey_)  String proUserId, @JsonKey(name: AvailabilityExceptionView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityExceptionView() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc,_that.reason,_that.id,_that.proUserId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: AvailabilityExceptionView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: AvailabilityExceptionView.reasonKey_)  String? reason, @JsonKey(name: AvailabilityExceptionView.idKey_)  String id, @JsonKey(name: AvailabilityExceptionView.proUserIdKey_)  String proUserId, @JsonKey(name: AvailabilityExceptionView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionView():
return $default(_that.startAtUtc,_that.endAtUtc,_that.reason,_that.id,_that.proUserId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: AvailabilityExceptionView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: AvailabilityExceptionView.reasonKey_)  String? reason, @JsonKey(name: AvailabilityExceptionView.idKey_)  String id, @JsonKey(name: AvailabilityExceptionView.proUserIdKey_)  String proUserId, @JsonKey(name: AvailabilityExceptionView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionView() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc,_that.reason,_that.id,_that.proUserId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityExceptionView extends AvailabilityExceptionView {
  const _AvailabilityExceptionView({@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_) required this.startAtUtc, @JsonKey(name: AvailabilityExceptionView.endAtUtcKey_) required this.endAtUtc, @JsonKey(name: AvailabilityExceptionView.reasonKey_) this.reason, @JsonKey(name: AvailabilityExceptionView.idKey_) required this.id, @JsonKey(name: AvailabilityExceptionView.proUserIdKey_) required this.proUserId, @JsonKey(name: AvailabilityExceptionView.createdAtKey_) required this.createdAt}): super._();
  factory _AvailabilityExceptionView.fromJson(Map<String, dynamic> json) => _$AvailabilityExceptionViewFromJson(json);

/// startAtUtc
@override@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_) final  DateTime startAtUtc;
/// endAtUtc
@override@JsonKey(name: AvailabilityExceptionView.endAtUtcKey_) final  DateTime endAtUtc;
/// reason
@override@JsonKey(name: AvailabilityExceptionView.reasonKey_) final  String? reason;
/// id
@override@JsonKey(name: AvailabilityExceptionView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: AvailabilityExceptionView.proUserIdKey_) final  String proUserId;
/// createdAt
@override@JsonKey(name: AvailabilityExceptionView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of AvailabilityExceptionView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityExceptionViewCopyWith<_AvailabilityExceptionView> get copyWith => __$AvailabilityExceptionViewCopyWithImpl<_AvailabilityExceptionView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityExceptionViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityExceptionView&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc,reason,id,proUserId,createdAt);

@override
String toString() {
  return 'AvailabilityExceptionView(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, reason: $reason, id: $id, proUserId: $proUserId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityExceptionViewCopyWith<$Res> implements $AvailabilityExceptionViewCopyWith<$Res> {
  factory _$AvailabilityExceptionViewCopyWith(_AvailabilityExceptionView value, $Res Function(_AvailabilityExceptionView) _then) = __$AvailabilityExceptionViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityExceptionView.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: AvailabilityExceptionView.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: AvailabilityExceptionView.reasonKey_) String? reason,@JsonKey(name: AvailabilityExceptionView.idKey_) String id,@JsonKey(name: AvailabilityExceptionView.proUserIdKey_) String proUserId,@JsonKey(name: AvailabilityExceptionView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$AvailabilityExceptionViewCopyWithImpl<$Res>
    implements _$AvailabilityExceptionViewCopyWith<$Res> {
  __$AvailabilityExceptionViewCopyWithImpl(this._self, this._then);

  final _AvailabilityExceptionView _self;
  final $Res Function(_AvailabilityExceptionView) _then;

/// Create a copy of AvailabilityExceptionView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAtUtc = null,Object? endAtUtc = null,Object? reason = freezed,Object? id = null,Object? proUserId = null,Object? createdAt = null,}) {
  return _then(_AvailabilityExceptionView(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
