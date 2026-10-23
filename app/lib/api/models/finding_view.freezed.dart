// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finding_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FindingView {

/// id
@JsonKey(name: FindingView.idKey_) String get id;/// gigId
@JsonKey(name: FindingView.gigIdKey_) String get gigId;/// status
@JsonKey(name: FindingView.statusKey_) String get status;/// reason
@JsonKey(name: FindingView.reasonKey_) String get reason;/// note
@JsonKey(name: FindingView.noteKey_) String get note;/// severe
@JsonKey(name: FindingView.severeKey_) bool get severe;/// createdAt
@JsonKey(name: FindingView.createdAtKey_) String get createdAt;/// firstSeenAt
@JsonKey(name: FindingView.firstSeenAtKey_) String? get firstSeenAt;/// windowEndsAt
@JsonKey(name: FindingView.windowEndsAtKey_) String get windowEndsAt;/// response
@JsonKey(name: FindingView.responseKey_) String? get response;/// decisionNote
@JsonKey(name: FindingView.decisionNoteKey_) String? get decisionNote;/// consequence
@JsonKey(name: FindingView.consequenceKey_) String? get consequence;/// strikeNumber
@JsonKey(name: FindingView.strikeNumberKey_) int? get strikeNumber;
/// Create a copy of FindingView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FindingViewCopyWith<FindingView> get copyWith => _$FindingViewCopyWithImpl<FindingView>(this as FindingView, _$identity);

  /// Serializes this FindingView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FindingView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.severe, severe) || other.severe == severe)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.firstSeenAt, firstSeenAt) || other.firstSeenAt == firstSeenAt)&&(identical(other.windowEndsAt, windowEndsAt) || other.windowEndsAt == windowEndsAt)&&(identical(other.response, response) || other.response == response)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.consequence, consequence) || other.consequence == consequence)&&(identical(other.strikeNumber, strikeNumber) || other.strikeNumber == strikeNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,status,reason,note,severe,createdAt,firstSeenAt,windowEndsAt,response,decisionNote,consequence,strikeNumber);

@override
String toString() {
  return 'FindingView(id: $id, gigId: $gigId, status: $status, reason: $reason, note: $note, severe: $severe, createdAt: $createdAt, firstSeenAt: $firstSeenAt, windowEndsAt: $windowEndsAt, response: $response, decisionNote: $decisionNote, consequence: $consequence, strikeNumber: $strikeNumber)';
}


}

/// @nodoc
abstract mixin class $FindingViewCopyWith<$Res>  {
  factory $FindingViewCopyWith(FindingView value, $Res Function(FindingView) _then) = _$FindingViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: FindingView.idKey_) String id,@JsonKey(name: FindingView.gigIdKey_) String gigId,@JsonKey(name: FindingView.statusKey_) String status,@JsonKey(name: FindingView.reasonKey_) String reason,@JsonKey(name: FindingView.noteKey_) String note,@JsonKey(name: FindingView.severeKey_) bool severe,@JsonKey(name: FindingView.createdAtKey_) String createdAt,@JsonKey(name: FindingView.firstSeenAtKey_) String? firstSeenAt,@JsonKey(name: FindingView.windowEndsAtKey_) String windowEndsAt,@JsonKey(name: FindingView.responseKey_) String? response,@JsonKey(name: FindingView.decisionNoteKey_) String? decisionNote,@JsonKey(name: FindingView.consequenceKey_) String? consequence,@JsonKey(name: FindingView.strikeNumberKey_) int? strikeNumber
});




}
/// @nodoc
class _$FindingViewCopyWithImpl<$Res>
    implements $FindingViewCopyWith<$Res> {
  _$FindingViewCopyWithImpl(this._self, this._then);

  final FindingView _self;
  final $Res Function(FindingView) _then;

/// Create a copy of FindingView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gigId = null,Object? status = null,Object? reason = null,Object? note = null,Object? severe = null,Object? createdAt = null,Object? firstSeenAt = freezed,Object? windowEndsAt = null,Object? response = freezed,Object? decisionNote = freezed,Object? consequence = freezed,Object? strikeNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,severe: null == severe ? _self.severe : severe // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,firstSeenAt: freezed == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as String?,windowEndsAt: null == windowEndsAt ? _self.windowEndsAt : windowEndsAt // ignore: cast_nullable_to_non_nullable
as String,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: freezed == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String?,consequence: freezed == consequence ? _self.consequence : consequence // ignore: cast_nullable_to_non_nullable
as String?,strikeNumber: freezed == strikeNumber ? _self.strikeNumber : strikeNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [FindingView].
extension FindingViewPatterns on FindingView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FindingView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FindingView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FindingView value)  $default,){
final _that = this;
switch (_that) {
case _FindingView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FindingView value)?  $default,){
final _that = this;
switch (_that) {
case _FindingView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: FindingView.idKey_)  String id, @JsonKey(name: FindingView.gigIdKey_)  String gigId, @JsonKey(name: FindingView.statusKey_)  String status, @JsonKey(name: FindingView.reasonKey_)  String reason, @JsonKey(name: FindingView.noteKey_)  String note, @JsonKey(name: FindingView.severeKey_)  bool severe, @JsonKey(name: FindingView.createdAtKey_)  String createdAt, @JsonKey(name: FindingView.firstSeenAtKey_)  String? firstSeenAt, @JsonKey(name: FindingView.windowEndsAtKey_)  String windowEndsAt, @JsonKey(name: FindingView.responseKey_)  String? response, @JsonKey(name: FindingView.decisionNoteKey_)  String? decisionNote, @JsonKey(name: FindingView.consequenceKey_)  String? consequence, @JsonKey(name: FindingView.strikeNumberKey_)  int? strikeNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FindingView() when $default != null:
return $default(_that.id,_that.gigId,_that.status,_that.reason,_that.note,_that.severe,_that.createdAt,_that.firstSeenAt,_that.windowEndsAt,_that.response,_that.decisionNote,_that.consequence,_that.strikeNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: FindingView.idKey_)  String id, @JsonKey(name: FindingView.gigIdKey_)  String gigId, @JsonKey(name: FindingView.statusKey_)  String status, @JsonKey(name: FindingView.reasonKey_)  String reason, @JsonKey(name: FindingView.noteKey_)  String note, @JsonKey(name: FindingView.severeKey_)  bool severe, @JsonKey(name: FindingView.createdAtKey_)  String createdAt, @JsonKey(name: FindingView.firstSeenAtKey_)  String? firstSeenAt, @JsonKey(name: FindingView.windowEndsAtKey_)  String windowEndsAt, @JsonKey(name: FindingView.responseKey_)  String? response, @JsonKey(name: FindingView.decisionNoteKey_)  String? decisionNote, @JsonKey(name: FindingView.consequenceKey_)  String? consequence, @JsonKey(name: FindingView.strikeNumberKey_)  int? strikeNumber)  $default,) {final _that = this;
switch (_that) {
case _FindingView():
return $default(_that.id,_that.gigId,_that.status,_that.reason,_that.note,_that.severe,_that.createdAt,_that.firstSeenAt,_that.windowEndsAt,_that.response,_that.decisionNote,_that.consequence,_that.strikeNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: FindingView.idKey_)  String id, @JsonKey(name: FindingView.gigIdKey_)  String gigId, @JsonKey(name: FindingView.statusKey_)  String status, @JsonKey(name: FindingView.reasonKey_)  String reason, @JsonKey(name: FindingView.noteKey_)  String note, @JsonKey(name: FindingView.severeKey_)  bool severe, @JsonKey(name: FindingView.createdAtKey_)  String createdAt, @JsonKey(name: FindingView.firstSeenAtKey_)  String? firstSeenAt, @JsonKey(name: FindingView.windowEndsAtKey_)  String windowEndsAt, @JsonKey(name: FindingView.responseKey_)  String? response, @JsonKey(name: FindingView.decisionNoteKey_)  String? decisionNote, @JsonKey(name: FindingView.consequenceKey_)  String? consequence, @JsonKey(name: FindingView.strikeNumberKey_)  int? strikeNumber)?  $default,) {final _that = this;
switch (_that) {
case _FindingView() when $default != null:
return $default(_that.id,_that.gigId,_that.status,_that.reason,_that.note,_that.severe,_that.createdAt,_that.firstSeenAt,_that.windowEndsAt,_that.response,_that.decisionNote,_that.consequence,_that.strikeNumber);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _FindingView extends FindingView {
  const _FindingView({@JsonKey(name: FindingView.idKey_) required this.id, @JsonKey(name: FindingView.gigIdKey_) required this.gigId, @JsonKey(name: FindingView.statusKey_) required this.status, @JsonKey(name: FindingView.reasonKey_) required this.reason, @JsonKey(name: FindingView.noteKey_) required this.note, @JsonKey(name: FindingView.severeKey_) required this.severe, @JsonKey(name: FindingView.createdAtKey_) required this.createdAt, @JsonKey(name: FindingView.firstSeenAtKey_) this.firstSeenAt, @JsonKey(name: FindingView.windowEndsAtKey_) required this.windowEndsAt, @JsonKey(name: FindingView.responseKey_) this.response, @JsonKey(name: FindingView.decisionNoteKey_) this.decisionNote, @JsonKey(name: FindingView.consequenceKey_) this.consequence, @JsonKey(name: FindingView.strikeNumberKey_) this.strikeNumber}): super._();
  factory _FindingView.fromJson(Map<String, dynamic> json) => _$FindingViewFromJson(json);

/// id
@override@JsonKey(name: FindingView.idKey_) final  String id;
/// gigId
@override@JsonKey(name: FindingView.gigIdKey_) final  String gigId;
/// status
@override@JsonKey(name: FindingView.statusKey_) final  String status;
/// reason
@override@JsonKey(name: FindingView.reasonKey_) final  String reason;
/// note
@override@JsonKey(name: FindingView.noteKey_) final  String note;
/// severe
@override@JsonKey(name: FindingView.severeKey_) final  bool severe;
/// createdAt
@override@JsonKey(name: FindingView.createdAtKey_) final  String createdAt;
/// firstSeenAt
@override@JsonKey(name: FindingView.firstSeenAtKey_) final  String? firstSeenAt;
/// windowEndsAt
@override@JsonKey(name: FindingView.windowEndsAtKey_) final  String windowEndsAt;
/// response
@override@JsonKey(name: FindingView.responseKey_) final  String? response;
/// decisionNote
@override@JsonKey(name: FindingView.decisionNoteKey_) final  String? decisionNote;
/// consequence
@override@JsonKey(name: FindingView.consequenceKey_) final  String? consequence;
/// strikeNumber
@override@JsonKey(name: FindingView.strikeNumberKey_) final  int? strikeNumber;

/// Create a copy of FindingView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FindingViewCopyWith<_FindingView> get copyWith => __$FindingViewCopyWithImpl<_FindingView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FindingViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FindingView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.severe, severe) || other.severe == severe)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.firstSeenAt, firstSeenAt) || other.firstSeenAt == firstSeenAt)&&(identical(other.windowEndsAt, windowEndsAt) || other.windowEndsAt == windowEndsAt)&&(identical(other.response, response) || other.response == response)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.consequence, consequence) || other.consequence == consequence)&&(identical(other.strikeNumber, strikeNumber) || other.strikeNumber == strikeNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,status,reason,note,severe,createdAt,firstSeenAt,windowEndsAt,response,decisionNote,consequence,strikeNumber);

@override
String toString() {
  return 'FindingView(id: $id, gigId: $gigId, status: $status, reason: $reason, note: $note, severe: $severe, createdAt: $createdAt, firstSeenAt: $firstSeenAt, windowEndsAt: $windowEndsAt, response: $response, decisionNote: $decisionNote, consequence: $consequence, strikeNumber: $strikeNumber)';
}


}

/// @nodoc
abstract mixin class _$FindingViewCopyWith<$Res> implements $FindingViewCopyWith<$Res> {
  factory _$FindingViewCopyWith(_FindingView value, $Res Function(_FindingView) _then) = __$FindingViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: FindingView.idKey_) String id,@JsonKey(name: FindingView.gigIdKey_) String gigId,@JsonKey(name: FindingView.statusKey_) String status,@JsonKey(name: FindingView.reasonKey_) String reason,@JsonKey(name: FindingView.noteKey_) String note,@JsonKey(name: FindingView.severeKey_) bool severe,@JsonKey(name: FindingView.createdAtKey_) String createdAt,@JsonKey(name: FindingView.firstSeenAtKey_) String? firstSeenAt,@JsonKey(name: FindingView.windowEndsAtKey_) String windowEndsAt,@JsonKey(name: FindingView.responseKey_) String? response,@JsonKey(name: FindingView.decisionNoteKey_) String? decisionNote,@JsonKey(name: FindingView.consequenceKey_) String? consequence,@JsonKey(name: FindingView.strikeNumberKey_) int? strikeNumber
});




}
/// @nodoc
class __$FindingViewCopyWithImpl<$Res>
    implements _$FindingViewCopyWith<$Res> {
  __$FindingViewCopyWithImpl(this._self, this._then);

  final _FindingView _self;
  final $Res Function(_FindingView) _then;

/// Create a copy of FindingView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gigId = null,Object? status = null,Object? reason = null,Object? note = null,Object? severe = null,Object? createdAt = null,Object? firstSeenAt = freezed,Object? windowEndsAt = null,Object? response = freezed,Object? decisionNote = freezed,Object? consequence = freezed,Object? strikeNumber = freezed,}) {
  return _then(_FindingView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,severe: null == severe ? _self.severe : severe // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,firstSeenAt: freezed == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as String?,windowEndsAt: null == windowEndsAt ? _self.windowEndsAt : windowEndsAt // ignore: cast_nullable_to_non_nullable
as String,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: freezed == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String?,consequence: freezed == consequence ? _self.consequence : consequence // ignore: cast_nullable_to_non_nullable
as String?,strikeNumber: freezed == strikeNumber ? _self.strikeNumber : strikeNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
