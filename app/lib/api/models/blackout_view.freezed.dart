// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blackout_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlackoutView {

/// id
@JsonKey(name: BlackoutView.idKey_) String get id;/// startAt
@JsonKey(name: BlackoutView.startAtKey_) DateTime get startAt;/// endAt
@JsonKey(name: BlackoutView.endAtKey_) DateTime get endAt;/// reason
@JsonKey(name: BlackoutView.reasonKey_) String? get reason;/// deprecationNotice
@JsonKey(name: BlackoutView.deprecationNoticeKey_) String? get deprecationNotice;
/// Create a copy of BlackoutView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlackoutViewCopyWith<BlackoutView> get copyWith => _$BlackoutViewCopyWithImpl<BlackoutView>(this as BlackoutView, _$identity);

  /// Serializes this BlackoutView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlackoutView&&(identical(other.id, id) || other.id == id)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.deprecationNotice, deprecationNotice) || other.deprecationNotice == deprecationNotice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startAt,endAt,reason,deprecationNotice);

@override
String toString() {
  return 'BlackoutView(id: $id, startAt: $startAt, endAt: $endAt, reason: $reason, deprecationNotice: $deprecationNotice)';
}


}

/// @nodoc
abstract mixin class $BlackoutViewCopyWith<$Res>  {
  factory $BlackoutViewCopyWith(BlackoutView value, $Res Function(BlackoutView) _then) = _$BlackoutViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BlackoutView.idKey_) String id,@JsonKey(name: BlackoutView.startAtKey_) DateTime startAt,@JsonKey(name: BlackoutView.endAtKey_) DateTime endAt,@JsonKey(name: BlackoutView.reasonKey_) String? reason,@JsonKey(name: BlackoutView.deprecationNoticeKey_) String? deprecationNotice
});




}
/// @nodoc
class _$BlackoutViewCopyWithImpl<$Res>
    implements $BlackoutViewCopyWith<$Res> {
  _$BlackoutViewCopyWithImpl(this._self, this._then);

  final BlackoutView _self;
  final $Res Function(BlackoutView) _then;

/// Create a copy of BlackoutView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startAt = null,Object? endAt = null,Object? reason = freezed,Object? deprecationNotice = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,deprecationNotice: freezed == deprecationNotice ? _self.deprecationNotice : deprecationNotice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlackoutView].
extension BlackoutViewPatterns on BlackoutView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlackoutView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlackoutView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlackoutView value)  $default,){
final _that = this;
switch (_that) {
case _BlackoutView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlackoutView value)?  $default,){
final _that = this;
switch (_that) {
case _BlackoutView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BlackoutView.idKey_)  String id, @JsonKey(name: BlackoutView.startAtKey_)  DateTime startAt, @JsonKey(name: BlackoutView.endAtKey_)  DateTime endAt, @JsonKey(name: BlackoutView.reasonKey_)  String? reason, @JsonKey(name: BlackoutView.deprecationNoticeKey_)  String? deprecationNotice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlackoutView() when $default != null:
return $default(_that.id,_that.startAt,_that.endAt,_that.reason,_that.deprecationNotice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BlackoutView.idKey_)  String id, @JsonKey(name: BlackoutView.startAtKey_)  DateTime startAt, @JsonKey(name: BlackoutView.endAtKey_)  DateTime endAt, @JsonKey(name: BlackoutView.reasonKey_)  String? reason, @JsonKey(name: BlackoutView.deprecationNoticeKey_)  String? deprecationNotice)  $default,) {final _that = this;
switch (_that) {
case _BlackoutView():
return $default(_that.id,_that.startAt,_that.endAt,_that.reason,_that.deprecationNotice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BlackoutView.idKey_)  String id, @JsonKey(name: BlackoutView.startAtKey_)  DateTime startAt, @JsonKey(name: BlackoutView.endAtKey_)  DateTime endAt, @JsonKey(name: BlackoutView.reasonKey_)  String? reason, @JsonKey(name: BlackoutView.deprecationNoticeKey_)  String? deprecationNotice)?  $default,) {final _that = this;
switch (_that) {
case _BlackoutView() when $default != null:
return $default(_that.id,_that.startAt,_that.endAt,_that.reason,_that.deprecationNotice);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BlackoutView extends BlackoutView {
  const _BlackoutView({@JsonKey(name: BlackoutView.idKey_) required this.id, @JsonKey(name: BlackoutView.startAtKey_) required this.startAt, @JsonKey(name: BlackoutView.endAtKey_) required this.endAt, @JsonKey(name: BlackoutView.reasonKey_) this.reason, @JsonKey(name: BlackoutView.deprecationNoticeKey_) this.deprecationNotice}): super._();
  factory _BlackoutView.fromJson(Map<String, dynamic> json) => _$BlackoutViewFromJson(json);

/// id
@override@JsonKey(name: BlackoutView.idKey_) final  String id;
/// startAt
@override@JsonKey(name: BlackoutView.startAtKey_) final  DateTime startAt;
/// endAt
@override@JsonKey(name: BlackoutView.endAtKey_) final  DateTime endAt;
/// reason
@override@JsonKey(name: BlackoutView.reasonKey_) final  String? reason;
/// deprecationNotice
@override@JsonKey(name: BlackoutView.deprecationNoticeKey_) final  String? deprecationNotice;

/// Create a copy of BlackoutView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlackoutViewCopyWith<_BlackoutView> get copyWith => __$BlackoutViewCopyWithImpl<_BlackoutView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlackoutViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlackoutView&&(identical(other.id, id) || other.id == id)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.deprecationNotice, deprecationNotice) || other.deprecationNotice == deprecationNotice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startAt,endAt,reason,deprecationNotice);

@override
String toString() {
  return 'BlackoutView(id: $id, startAt: $startAt, endAt: $endAt, reason: $reason, deprecationNotice: $deprecationNotice)';
}


}

/// @nodoc
abstract mixin class _$BlackoutViewCopyWith<$Res> implements $BlackoutViewCopyWith<$Res> {
  factory _$BlackoutViewCopyWith(_BlackoutView value, $Res Function(_BlackoutView) _then) = __$BlackoutViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BlackoutView.idKey_) String id,@JsonKey(name: BlackoutView.startAtKey_) DateTime startAt,@JsonKey(name: BlackoutView.endAtKey_) DateTime endAt,@JsonKey(name: BlackoutView.reasonKey_) String? reason,@JsonKey(name: BlackoutView.deprecationNoticeKey_) String? deprecationNotice
});




}
/// @nodoc
class __$BlackoutViewCopyWithImpl<$Res>
    implements _$BlackoutViewCopyWith<$Res> {
  __$BlackoutViewCopyWithImpl(this._self, this._then);

  final _BlackoutView _self;
  final $Res Function(_BlackoutView) _then;

/// Create a copy of BlackoutView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startAt = null,Object? endAt = null,Object? reason = freezed,Object? deprecationNotice = freezed,}) {
  return _then(_BlackoutView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,deprecationNotice: freezed == deprecationNotice ? _self.deprecationNotice : deprecationNotice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
