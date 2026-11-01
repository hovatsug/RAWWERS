// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem_report_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProblemReportView {

/// id
@JsonKey(name: ProblemReportView.idKey_) String get id;/// gigId
@JsonKey(name: ProblemReportView.gigIdKey_) String get gigId;/// reason
@JsonKey(name: ProblemReportView.reasonKey_) ProblemReportReason get reason;/// note
@JsonKey(name: ProblemReportView.noteKey_) String? get note;/// createdAt
@JsonKey(name: ProblemReportView.createdAtKey_) DateTime get createdAt;
/// Create a copy of ProblemReportView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProblemReportViewCopyWith<ProblemReportView> get copyWith => _$ProblemReportViewCopyWithImpl<ProblemReportView>(this as ProblemReportView, _$identity);

  /// Serializes this ProblemReportView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProblemReportView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,reason,note,createdAt);

@override
String toString() {
  return 'ProblemReportView(id: $id, gigId: $gigId, reason: $reason, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProblemReportViewCopyWith<$Res>  {
  factory $ProblemReportViewCopyWith(ProblemReportView value, $Res Function(ProblemReportView) _then) = _$ProblemReportViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProblemReportView.idKey_) String id,@JsonKey(name: ProblemReportView.gigIdKey_) String gigId,@JsonKey(name: ProblemReportView.reasonKey_) ProblemReportReason reason,@JsonKey(name: ProblemReportView.noteKey_) String? note,@JsonKey(name: ProblemReportView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$ProblemReportViewCopyWithImpl<$Res>
    implements $ProblemReportViewCopyWith<$Res> {
  _$ProblemReportViewCopyWithImpl(this._self, this._then);

  final ProblemReportView _self;
  final $Res Function(ProblemReportView) _then;

/// Create a copy of ProblemReportView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gigId = null,Object? reason = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ProblemReportReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProblemReportView].
extension ProblemReportViewPatterns on ProblemReportView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProblemReportView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProblemReportView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProblemReportView value)  $default,){
final _that = this;
switch (_that) {
case _ProblemReportView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProblemReportView value)?  $default,){
final _that = this;
switch (_that) {
case _ProblemReportView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProblemReportView.idKey_)  String id, @JsonKey(name: ProblemReportView.gigIdKey_)  String gigId, @JsonKey(name: ProblemReportView.reasonKey_)  ProblemReportReason reason, @JsonKey(name: ProblemReportView.noteKey_)  String? note, @JsonKey(name: ProblemReportView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProblemReportView() when $default != null:
return $default(_that.id,_that.gigId,_that.reason,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProblemReportView.idKey_)  String id, @JsonKey(name: ProblemReportView.gigIdKey_)  String gigId, @JsonKey(name: ProblemReportView.reasonKey_)  ProblemReportReason reason, @JsonKey(name: ProblemReportView.noteKey_)  String? note, @JsonKey(name: ProblemReportView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProblemReportView():
return $default(_that.id,_that.gigId,_that.reason,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProblemReportView.idKey_)  String id, @JsonKey(name: ProblemReportView.gigIdKey_)  String gigId, @JsonKey(name: ProblemReportView.reasonKey_)  ProblemReportReason reason, @JsonKey(name: ProblemReportView.noteKey_)  String? note, @JsonKey(name: ProblemReportView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProblemReportView() when $default != null:
return $default(_that.id,_that.gigId,_that.reason,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProblemReportView extends ProblemReportView {
  const _ProblemReportView({@JsonKey(name: ProblemReportView.idKey_) required this.id, @JsonKey(name: ProblemReportView.gigIdKey_) required this.gigId, @JsonKey(name: ProblemReportView.reasonKey_) required this.reason, @JsonKey(name: ProblemReportView.noteKey_) required this.note, @JsonKey(name: ProblemReportView.createdAtKey_) required this.createdAt}): super._();
  factory _ProblemReportView.fromJson(Map<String, dynamic> json) => _$ProblemReportViewFromJson(json);

/// id
@override@JsonKey(name: ProblemReportView.idKey_) final  String id;
/// gigId
@override@JsonKey(name: ProblemReportView.gigIdKey_) final  String gigId;
/// reason
@override@JsonKey(name: ProblemReportView.reasonKey_) final  ProblemReportReason reason;
/// note
@override@JsonKey(name: ProblemReportView.noteKey_) final  String? note;
/// createdAt
@override@JsonKey(name: ProblemReportView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of ProblemReportView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProblemReportViewCopyWith<_ProblemReportView> get copyWith => __$ProblemReportViewCopyWithImpl<_ProblemReportView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProblemReportViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProblemReportView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,reason,note,createdAt);

@override
String toString() {
  return 'ProblemReportView(id: $id, gigId: $gigId, reason: $reason, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProblemReportViewCopyWith<$Res> implements $ProblemReportViewCopyWith<$Res> {
  factory _$ProblemReportViewCopyWith(_ProblemReportView value, $Res Function(_ProblemReportView) _then) = __$ProblemReportViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProblemReportView.idKey_) String id,@JsonKey(name: ProblemReportView.gigIdKey_) String gigId,@JsonKey(name: ProblemReportView.reasonKey_) ProblemReportReason reason,@JsonKey(name: ProblemReportView.noteKey_) String? note,@JsonKey(name: ProblemReportView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$ProblemReportViewCopyWithImpl<$Res>
    implements _$ProblemReportViewCopyWith<$Res> {
  __$ProblemReportViewCopyWithImpl(this._self, this._then);

  final _ProblemReportView _self;
  final $Res Function(_ProblemReportView) _then;

/// Create a copy of ProblemReportView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gigId = null,Object? reason = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_ProblemReportView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ProblemReportReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
