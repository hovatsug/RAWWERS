// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_request_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingRequestView {

/// id
@JsonKey(name: BookingRequestView.idKey_) String get id;/// proUserId
@JsonKey(name: BookingRequestView.proUserIdKey_) String get proUserId;/// clientUserId
@JsonKey(name: BookingRequestView.clientUserIdKey_) String get clientUserId;/// packageId
@JsonKey(name: BookingRequestView.packageIdKey_) String get packageId;/// requestedStart
@JsonKey(name: BookingRequestView.requestedStartKey_) DateTime get requestedStart;/// requestedEnd
@JsonKey(name: BookingRequestView.requestedEndKey_) DateTime get requestedEnd;/// locationText
@JsonKey(name: BookingRequestView.locationTextKey_) String? get locationText;/// notes
@JsonKey(name: BookingRequestView.notesKey_) String? get notes;/// status
@JsonKey(name: BookingRequestView.statusKey_) BookingRequestStatus get status;/// expiresAt
@JsonKey(name: BookingRequestView.expiresAtKey_) DateTime get expiresAt;
/// Create a copy of BookingRequestView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingRequestViewCopyWith<BookingRequestView> get copyWith => _$BookingRequestViewCopyWithImpl<BookingRequestView>(this as BookingRequestView, _$identity);

  /// Serializes this BookingRequestView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingRequestView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,packageId,requestedStart,requestedEnd,locationText,notes,status,expiresAt);

@override
String toString() {
  return 'BookingRequestView(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes, status: $status, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $BookingRequestViewCopyWith<$Res>  {
  factory $BookingRequestViewCopyWith(BookingRequestView value, $Res Function(BookingRequestView) _then) = _$BookingRequestViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingRequestView.idKey_) String id,@JsonKey(name: BookingRequestView.proUserIdKey_) String proUserId,@JsonKey(name: BookingRequestView.clientUserIdKey_) String clientUserId,@JsonKey(name: BookingRequestView.packageIdKey_) String packageId,@JsonKey(name: BookingRequestView.requestedStartKey_) DateTime requestedStart,@JsonKey(name: BookingRequestView.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: BookingRequestView.locationTextKey_) String? locationText,@JsonKey(name: BookingRequestView.notesKey_) String? notes,@JsonKey(name: BookingRequestView.statusKey_) BookingRequestStatus status,@JsonKey(name: BookingRequestView.expiresAtKey_) DateTime expiresAt
});




}
/// @nodoc
class _$BookingRequestViewCopyWithImpl<$Res>
    implements $BookingRequestViewCopyWith<$Res> {
  _$BookingRequestViewCopyWithImpl(this._self, this._then);

  final BookingRequestView _self;
  final $Res Function(BookingRequestView) _then;

/// Create a copy of BookingRequestView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = null,Object? packageId = null,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? notes = freezed,Object? status = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,requestedStart: null == requestedStart ? _self.requestedStart : requestedStart // ignore: cast_nullable_to_non_nullable
as DateTime,requestedEnd: null == requestedEnd ? _self.requestedEnd : requestedEnd // ignore: cast_nullable_to_non_nullable
as DateTime,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingRequestStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingRequestView].
extension BookingRequestViewPatterns on BookingRequestView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingRequestView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingRequestView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingRequestView value)  $default,){
final _that = this;
switch (_that) {
case _BookingRequestView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingRequestView value)?  $default,){
final _that = this;
switch (_that) {
case _BookingRequestView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestView.idKey_)  String id, @JsonKey(name: BookingRequestView.proUserIdKey_)  String proUserId, @JsonKey(name: BookingRequestView.clientUserIdKey_)  String clientUserId, @JsonKey(name: BookingRequestView.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestView.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestView.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestView.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestView.notesKey_)  String? notes, @JsonKey(name: BookingRequestView.statusKey_)  BookingRequestStatus status, @JsonKey(name: BookingRequestView.expiresAtKey_)  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingRequestView() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes,_that.status,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestView.idKey_)  String id, @JsonKey(name: BookingRequestView.proUserIdKey_)  String proUserId, @JsonKey(name: BookingRequestView.clientUserIdKey_)  String clientUserId, @JsonKey(name: BookingRequestView.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestView.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestView.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestView.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestView.notesKey_)  String? notes, @JsonKey(name: BookingRequestView.statusKey_)  BookingRequestStatus status, @JsonKey(name: BookingRequestView.expiresAtKey_)  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _BookingRequestView():
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes,_that.status,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingRequestView.idKey_)  String id, @JsonKey(name: BookingRequestView.proUserIdKey_)  String proUserId, @JsonKey(name: BookingRequestView.clientUserIdKey_)  String clientUserId, @JsonKey(name: BookingRequestView.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestView.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestView.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestView.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestView.notesKey_)  String? notes, @JsonKey(name: BookingRequestView.statusKey_)  BookingRequestStatus status, @JsonKey(name: BookingRequestView.expiresAtKey_)  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _BookingRequestView() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes,_that.status,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingRequestView extends BookingRequestView {
  const _BookingRequestView({@JsonKey(name: BookingRequestView.idKey_) required this.id, @JsonKey(name: BookingRequestView.proUserIdKey_) required this.proUserId, @JsonKey(name: BookingRequestView.clientUserIdKey_) required this.clientUserId, @JsonKey(name: BookingRequestView.packageIdKey_) required this.packageId, @JsonKey(name: BookingRequestView.requestedStartKey_) required this.requestedStart, @JsonKey(name: BookingRequestView.requestedEndKey_) required this.requestedEnd, @JsonKey(name: BookingRequestView.locationTextKey_) this.locationText, @JsonKey(name: BookingRequestView.notesKey_) this.notes, @JsonKey(name: BookingRequestView.statusKey_) required this.status, @JsonKey(name: BookingRequestView.expiresAtKey_) required this.expiresAt}): super._();
  factory _BookingRequestView.fromJson(Map<String, dynamic> json) => _$BookingRequestViewFromJson(json);

/// id
@override@JsonKey(name: BookingRequestView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: BookingRequestView.proUserIdKey_) final  String proUserId;
/// clientUserId
@override@JsonKey(name: BookingRequestView.clientUserIdKey_) final  String clientUserId;
/// packageId
@override@JsonKey(name: BookingRequestView.packageIdKey_) final  String packageId;
/// requestedStart
@override@JsonKey(name: BookingRequestView.requestedStartKey_) final  DateTime requestedStart;
/// requestedEnd
@override@JsonKey(name: BookingRequestView.requestedEndKey_) final  DateTime requestedEnd;
/// locationText
@override@JsonKey(name: BookingRequestView.locationTextKey_) final  String? locationText;
/// notes
@override@JsonKey(name: BookingRequestView.notesKey_) final  String? notes;
/// status
@override@JsonKey(name: BookingRequestView.statusKey_) final  BookingRequestStatus status;
/// expiresAt
@override@JsonKey(name: BookingRequestView.expiresAtKey_) final  DateTime expiresAt;

/// Create a copy of BookingRequestView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingRequestViewCopyWith<_BookingRequestView> get copyWith => __$BookingRequestViewCopyWithImpl<_BookingRequestView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingRequestViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingRequestView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,packageId,requestedStart,requestedEnd,locationText,notes,status,expiresAt);

@override
String toString() {
  return 'BookingRequestView(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes, status: $status, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$BookingRequestViewCopyWith<$Res> implements $BookingRequestViewCopyWith<$Res> {
  factory _$BookingRequestViewCopyWith(_BookingRequestView value, $Res Function(_BookingRequestView) _then) = __$BookingRequestViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingRequestView.idKey_) String id,@JsonKey(name: BookingRequestView.proUserIdKey_) String proUserId,@JsonKey(name: BookingRequestView.clientUserIdKey_) String clientUserId,@JsonKey(name: BookingRequestView.packageIdKey_) String packageId,@JsonKey(name: BookingRequestView.requestedStartKey_) DateTime requestedStart,@JsonKey(name: BookingRequestView.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: BookingRequestView.locationTextKey_) String? locationText,@JsonKey(name: BookingRequestView.notesKey_) String? notes,@JsonKey(name: BookingRequestView.statusKey_) BookingRequestStatus status,@JsonKey(name: BookingRequestView.expiresAtKey_) DateTime expiresAt
});




}
/// @nodoc
class __$BookingRequestViewCopyWithImpl<$Res>
    implements _$BookingRequestViewCopyWith<$Res> {
  __$BookingRequestViewCopyWithImpl(this._self, this._then);

  final _BookingRequestView _self;
  final $Res Function(_BookingRequestView) _then;

/// Create a copy of BookingRequestView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = null,Object? packageId = null,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? notes = freezed,Object? status = null,Object? expiresAt = null,}) {
  return _then(_BookingRequestView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,requestedStart: null == requestedStart ? _self.requestedStart : requestedStart // ignore: cast_nullable_to_non_nullable
as DateTime,requestedEnd: null == requestedEnd ? _self.requestedEnd : requestedEnd // ignore: cast_nullable_to_non_nullable
as DateTime,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingRequestStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
