// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raww_entry_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawwEntryView {

/// id
@JsonKey(name: RawwEntryView.idKey_) String get id;/// kind
@JsonKey(name: RawwEntryView.kindKey_) String get kind;/// amount
@JsonKey(name: RawwEntryView.amountKey_) int get amount;/// status
@JsonKey(name: RawwEntryView.statusKey_) String get status;/// gigId
@JsonKey(name: RawwEntryView.gigIdKey_) String? get gigId;/// sourceType
@JsonKey(name: RawwEntryView.sourceTypeKey_) String get sourceType;/// note
@JsonKey(name: RawwEntryView.noteKey_) String? get note;/// createdAt
@JsonKey(name: RawwEntryView.createdAtKey_) DateTime get createdAt;
/// Create a copy of RawwEntryView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawwEntryViewCopyWith<RawwEntryView> get copyWith => _$RawwEntryViewCopyWithImpl<RawwEntryView>(this as RawwEntryView, _$identity);

  /// Serializes this RawwEntryView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawwEntryView&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,amount,status,gigId,sourceType,note,createdAt);

@override
String toString() {
  return 'RawwEntryView(id: $id, kind: $kind, amount: $amount, status: $status, gigId: $gigId, sourceType: $sourceType, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RawwEntryViewCopyWith<$Res>  {
  factory $RawwEntryViewCopyWith(RawwEntryView value, $Res Function(RawwEntryView) _then) = _$RawwEntryViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: RawwEntryView.idKey_) String id,@JsonKey(name: RawwEntryView.kindKey_) String kind,@JsonKey(name: RawwEntryView.amountKey_) int amount,@JsonKey(name: RawwEntryView.statusKey_) String status,@JsonKey(name: RawwEntryView.gigIdKey_) String? gigId,@JsonKey(name: RawwEntryView.sourceTypeKey_) String sourceType,@JsonKey(name: RawwEntryView.noteKey_) String? note,@JsonKey(name: RawwEntryView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$RawwEntryViewCopyWithImpl<$Res>
    implements $RawwEntryViewCopyWith<$Res> {
  _$RawwEntryViewCopyWithImpl(this._self, this._then);

  final RawwEntryView _self;
  final $Res Function(RawwEntryView) _then;

/// Create a copy of RawwEntryView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? amount = null,Object? status = null,Object? gigId = freezed,Object? sourceType = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RawwEntryView].
extension RawwEntryViewPatterns on RawwEntryView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawwEntryView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawwEntryView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawwEntryView value)  $default,){
final _that = this;
switch (_that) {
case _RawwEntryView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawwEntryView value)?  $default,){
final _that = this;
switch (_that) {
case _RawwEntryView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: RawwEntryView.idKey_)  String id, @JsonKey(name: RawwEntryView.kindKey_)  String kind, @JsonKey(name: RawwEntryView.amountKey_)  int amount, @JsonKey(name: RawwEntryView.statusKey_)  String status, @JsonKey(name: RawwEntryView.gigIdKey_)  String? gigId, @JsonKey(name: RawwEntryView.sourceTypeKey_)  String sourceType, @JsonKey(name: RawwEntryView.noteKey_)  String? note, @JsonKey(name: RawwEntryView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawwEntryView() when $default != null:
return $default(_that.id,_that.kind,_that.amount,_that.status,_that.gigId,_that.sourceType,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: RawwEntryView.idKey_)  String id, @JsonKey(name: RawwEntryView.kindKey_)  String kind, @JsonKey(name: RawwEntryView.amountKey_)  int amount, @JsonKey(name: RawwEntryView.statusKey_)  String status, @JsonKey(name: RawwEntryView.gigIdKey_)  String? gigId, @JsonKey(name: RawwEntryView.sourceTypeKey_)  String sourceType, @JsonKey(name: RawwEntryView.noteKey_)  String? note, @JsonKey(name: RawwEntryView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _RawwEntryView():
return $default(_that.id,_that.kind,_that.amount,_that.status,_that.gigId,_that.sourceType,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: RawwEntryView.idKey_)  String id, @JsonKey(name: RawwEntryView.kindKey_)  String kind, @JsonKey(name: RawwEntryView.amountKey_)  int amount, @JsonKey(name: RawwEntryView.statusKey_)  String status, @JsonKey(name: RawwEntryView.gigIdKey_)  String? gigId, @JsonKey(name: RawwEntryView.sourceTypeKey_)  String sourceType, @JsonKey(name: RawwEntryView.noteKey_)  String? note, @JsonKey(name: RawwEntryView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RawwEntryView() when $default != null:
return $default(_that.id,_that.kind,_that.amount,_that.status,_that.gigId,_that.sourceType,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _RawwEntryView extends RawwEntryView {
  const _RawwEntryView({@JsonKey(name: RawwEntryView.idKey_) required this.id, @JsonKey(name: RawwEntryView.kindKey_) required this.kind, @JsonKey(name: RawwEntryView.amountKey_) required this.amount, @JsonKey(name: RawwEntryView.statusKey_) required this.status, @JsonKey(name: RawwEntryView.gigIdKey_) this.gigId, @JsonKey(name: RawwEntryView.sourceTypeKey_) required this.sourceType, @JsonKey(name: RawwEntryView.noteKey_) this.note, @JsonKey(name: RawwEntryView.createdAtKey_) required this.createdAt}): super._();
  factory _RawwEntryView.fromJson(Map<String, dynamic> json) => _$RawwEntryViewFromJson(json);

/// id
@override@JsonKey(name: RawwEntryView.idKey_) final  String id;
/// kind
@override@JsonKey(name: RawwEntryView.kindKey_) final  String kind;
/// amount
@override@JsonKey(name: RawwEntryView.amountKey_) final  int amount;
/// status
@override@JsonKey(name: RawwEntryView.statusKey_) final  String status;
/// gigId
@override@JsonKey(name: RawwEntryView.gigIdKey_) final  String? gigId;
/// sourceType
@override@JsonKey(name: RawwEntryView.sourceTypeKey_) final  String sourceType;
/// note
@override@JsonKey(name: RawwEntryView.noteKey_) final  String? note;
/// createdAt
@override@JsonKey(name: RawwEntryView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of RawwEntryView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawwEntryViewCopyWith<_RawwEntryView> get copyWith => __$RawwEntryViewCopyWithImpl<_RawwEntryView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawwEntryViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawwEntryView&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,amount,status,gigId,sourceType,note,createdAt);

@override
String toString() {
  return 'RawwEntryView(id: $id, kind: $kind, amount: $amount, status: $status, gigId: $gigId, sourceType: $sourceType, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RawwEntryViewCopyWith<$Res> implements $RawwEntryViewCopyWith<$Res> {
  factory _$RawwEntryViewCopyWith(_RawwEntryView value, $Res Function(_RawwEntryView) _then) = __$RawwEntryViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: RawwEntryView.idKey_) String id,@JsonKey(name: RawwEntryView.kindKey_) String kind,@JsonKey(name: RawwEntryView.amountKey_) int amount,@JsonKey(name: RawwEntryView.statusKey_) String status,@JsonKey(name: RawwEntryView.gigIdKey_) String? gigId,@JsonKey(name: RawwEntryView.sourceTypeKey_) String sourceType,@JsonKey(name: RawwEntryView.noteKey_) String? note,@JsonKey(name: RawwEntryView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$RawwEntryViewCopyWithImpl<$Res>
    implements _$RawwEntryViewCopyWith<$Res> {
  __$RawwEntryViewCopyWithImpl(this._self, this._then);

  final _RawwEntryView _self;
  final $Res Function(_RawwEntryView) _then;

/// Create a copy of RawwEntryView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? amount = null,Object? status = null,Object? gigId = freezed,Object? sourceType = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_RawwEntryView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
