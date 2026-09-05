// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_exception_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailabilityExceptionItem {

/// startAtUtc
@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_) DateTime get startAtUtc;/// endAtUtc
@JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_) DateTime get endAtUtc;/// reason
@JsonKey(name: AvailabilityExceptionItem.reasonKey_) String? get reason;
/// Create a copy of AvailabilityExceptionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityExceptionItemCopyWith<AvailabilityExceptionItem> get copyWith => _$AvailabilityExceptionItemCopyWithImpl<AvailabilityExceptionItem>(this as AvailabilityExceptionItem, _$identity);

  /// Serializes this AvailabilityExceptionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityExceptionItem&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc,reason);

@override
String toString() {
  return 'AvailabilityExceptionItem(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AvailabilityExceptionItemCopyWith<$Res>  {
  factory $AvailabilityExceptionItemCopyWith(AvailabilityExceptionItem value, $Res Function(AvailabilityExceptionItem) _then) = _$AvailabilityExceptionItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: AvailabilityExceptionItem.reasonKey_) String? reason
});




}
/// @nodoc
class _$AvailabilityExceptionItemCopyWithImpl<$Res>
    implements $AvailabilityExceptionItemCopyWith<$Res> {
  _$AvailabilityExceptionItemCopyWithImpl(this._self, this._then);

  final AvailabilityExceptionItem _self;
  final $Res Function(AvailabilityExceptionItem) _then;

/// Create a copy of AvailabilityExceptionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAtUtc = null,Object? endAtUtc = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityExceptionItem].
extension AvailabilityExceptionItemPatterns on AvailabilityExceptionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityExceptionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityExceptionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityExceptionItem value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityExceptionItem value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityExceptionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: AvailabilityExceptionItem.reasonKey_)  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityExceptionItem() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: AvailabilityExceptionItem.reasonKey_)  String? reason)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionItem():
return $default(_that.startAtUtc,_that.endAtUtc,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: AvailabilityExceptionItem.reasonKey_)  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityExceptionItem() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc,_that.reason);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailabilityExceptionItem extends AvailabilityExceptionItem {
  const _AvailabilityExceptionItem({@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_) required this.startAtUtc, @JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_) required this.endAtUtc, @JsonKey(name: AvailabilityExceptionItem.reasonKey_) this.reason}): super._();
  factory _AvailabilityExceptionItem.fromJson(Map<String, dynamic> json) => _$AvailabilityExceptionItemFromJson(json);

/// startAtUtc
@override@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_) final  DateTime startAtUtc;
/// endAtUtc
@override@JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_) final  DateTime endAtUtc;
/// reason
@override@JsonKey(name: AvailabilityExceptionItem.reasonKey_) final  String? reason;

/// Create a copy of AvailabilityExceptionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityExceptionItemCopyWith<_AvailabilityExceptionItem> get copyWith => __$AvailabilityExceptionItemCopyWithImpl<_AvailabilityExceptionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityExceptionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityExceptionItem&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc,reason);

@override
String toString() {
  return 'AvailabilityExceptionItem(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityExceptionItemCopyWith<$Res> implements $AvailabilityExceptionItemCopyWith<$Res> {
  factory _$AvailabilityExceptionItemCopyWith(_AvailabilityExceptionItem value, $Res Function(_AvailabilityExceptionItem) _then) = __$AvailabilityExceptionItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: AvailabilityExceptionItem.reasonKey_) String? reason
});




}
/// @nodoc
class __$AvailabilityExceptionItemCopyWithImpl<$Res>
    implements _$AvailabilityExceptionItemCopyWith<$Res> {
  __$AvailabilityExceptionItemCopyWithImpl(this._self, this._then);

  final _AvailabilityExceptionItem _self;
  final $Res Function(_AvailabilityExceptionItem) _then;

/// Create a copy of AvailabilityExceptionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAtUtc = null,Object? endAtUtc = null,Object? reason = freezed,}) {
  return _then(_AvailabilityExceptionItem(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
