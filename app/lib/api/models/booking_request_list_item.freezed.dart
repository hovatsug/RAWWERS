// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_request_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingRequestListItem {

/// id
@JsonKey(name: BookingRequestListItem.idKey_) String get id;/// proUserId
@JsonKey(name: BookingRequestListItem.proUserIdKey_) String get proUserId;/// clientUserId
@JsonKey(name: BookingRequestListItem.clientUserIdKey_) String get clientUserId;/// packageId
@JsonKey(name: BookingRequestListItem.packageIdKey_) String get packageId;/// requestedStart
@JsonKey(name: BookingRequestListItem.requestedStartKey_) DateTime get requestedStart;/// requestedEnd
@JsonKey(name: BookingRequestListItem.requestedEndKey_) DateTime get requestedEnd;/// locationText
@JsonKey(name: BookingRequestListItem.locationTextKey_) String? get locationText;/// notes
@JsonKey(name: BookingRequestListItem.notesKey_) String? get notes;/// status
@JsonKey(name: BookingRequestListItem.statusKey_) BookingRequestStatus get status;/// expiresAt
@JsonKey(name: BookingRequestListItem.expiresAtKey_) DateTime get expiresAt;/// createdAt
@JsonKey(name: BookingRequestListItem.createdAtKey_) DateTime get createdAt;/// secondsUntilExpiry
@JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_) int? get secondsUntilExpiry;
/// Create a copy of BookingRequestListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingRequestListItemCopyWith<BookingRequestListItem> get copyWith => _$BookingRequestListItemCopyWithImpl<BookingRequestListItem>(this as BookingRequestListItem, _$identity);

  /// Serializes this BookingRequestListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingRequestListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.secondsUntilExpiry, secondsUntilExpiry) || other.secondsUntilExpiry == secondsUntilExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,packageId,requestedStart,requestedEnd,locationText,notes,status,expiresAt,createdAt,secondsUntilExpiry);

@override
String toString() {
  return 'BookingRequestListItem(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, secondsUntilExpiry: $secondsUntilExpiry)';
}


}

/// @nodoc
abstract mixin class $BookingRequestListItemCopyWith<$Res>  {
  factory $BookingRequestListItemCopyWith(BookingRequestListItem value, $Res Function(BookingRequestListItem) _then) = _$BookingRequestListItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingRequestListItem.idKey_) String id,@JsonKey(name: BookingRequestListItem.proUserIdKey_) String proUserId,@JsonKey(name: BookingRequestListItem.clientUserIdKey_) String clientUserId,@JsonKey(name: BookingRequestListItem.packageIdKey_) String packageId,@JsonKey(name: BookingRequestListItem.requestedStartKey_) DateTime requestedStart,@JsonKey(name: BookingRequestListItem.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: BookingRequestListItem.locationTextKey_) String? locationText,@JsonKey(name: BookingRequestListItem.notesKey_) String? notes,@JsonKey(name: BookingRequestListItem.statusKey_) BookingRequestStatus status,@JsonKey(name: BookingRequestListItem.expiresAtKey_) DateTime expiresAt,@JsonKey(name: BookingRequestListItem.createdAtKey_) DateTime createdAt,@JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_) int? secondsUntilExpiry
});




}
/// @nodoc
class _$BookingRequestListItemCopyWithImpl<$Res>
    implements $BookingRequestListItemCopyWith<$Res> {
  _$BookingRequestListItemCopyWithImpl(this._self, this._then);

  final BookingRequestListItem _self;
  final $Res Function(BookingRequestListItem) _then;

/// Create a copy of BookingRequestListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = null,Object? packageId = null,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? notes = freezed,Object? status = null,Object? expiresAt = null,Object? createdAt = null,Object? secondsUntilExpiry = freezed,}) {
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
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,secondsUntilExpiry: freezed == secondsUntilExpiry ? _self.secondsUntilExpiry : secondsUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingRequestListItem].
extension BookingRequestListItemPatterns on BookingRequestListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingRequestListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingRequestListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingRequestListItem value)  $default,){
final _that = this;
switch (_that) {
case _BookingRequestListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingRequestListItem value)?  $default,){
final _that = this;
switch (_that) {
case _BookingRequestListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestListItem.idKey_)  String id, @JsonKey(name: BookingRequestListItem.proUserIdKey_)  String proUserId, @JsonKey(name: BookingRequestListItem.clientUserIdKey_)  String clientUserId, @JsonKey(name: BookingRequestListItem.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestListItem.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestListItem.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestListItem.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestListItem.notesKey_)  String? notes, @JsonKey(name: BookingRequestListItem.statusKey_)  BookingRequestStatus status, @JsonKey(name: BookingRequestListItem.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: BookingRequestListItem.createdAtKey_)  DateTime createdAt, @JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_)  int? secondsUntilExpiry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingRequestListItem() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes,_that.status,_that.expiresAt,_that.createdAt,_that.secondsUntilExpiry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingRequestListItem.idKey_)  String id, @JsonKey(name: BookingRequestListItem.proUserIdKey_)  String proUserId, @JsonKey(name: BookingRequestListItem.clientUserIdKey_)  String clientUserId, @JsonKey(name: BookingRequestListItem.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestListItem.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestListItem.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestListItem.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestListItem.notesKey_)  String? notes, @JsonKey(name: BookingRequestListItem.statusKey_)  BookingRequestStatus status, @JsonKey(name: BookingRequestListItem.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: BookingRequestListItem.createdAtKey_)  DateTime createdAt, @JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_)  int? secondsUntilExpiry)  $default,) {final _that = this;
switch (_that) {
case _BookingRequestListItem():
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes,_that.status,_that.expiresAt,_that.createdAt,_that.secondsUntilExpiry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingRequestListItem.idKey_)  String id, @JsonKey(name: BookingRequestListItem.proUserIdKey_)  String proUserId, @JsonKey(name: BookingRequestListItem.clientUserIdKey_)  String clientUserId, @JsonKey(name: BookingRequestListItem.packageIdKey_)  String packageId, @JsonKey(name: BookingRequestListItem.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: BookingRequestListItem.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: BookingRequestListItem.locationTextKey_)  String? locationText, @JsonKey(name: BookingRequestListItem.notesKey_)  String? notes, @JsonKey(name: BookingRequestListItem.statusKey_)  BookingRequestStatus status, @JsonKey(name: BookingRequestListItem.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: BookingRequestListItem.createdAtKey_)  DateTime createdAt, @JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_)  int? secondsUntilExpiry)?  $default,) {final _that = this;
switch (_that) {
case _BookingRequestListItem() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.packageId,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.notes,_that.status,_that.expiresAt,_that.createdAt,_that.secondsUntilExpiry);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingRequestListItem extends BookingRequestListItem {
  const _BookingRequestListItem({@JsonKey(name: BookingRequestListItem.idKey_) required this.id, @JsonKey(name: BookingRequestListItem.proUserIdKey_) required this.proUserId, @JsonKey(name: BookingRequestListItem.clientUserIdKey_) required this.clientUserId, @JsonKey(name: BookingRequestListItem.packageIdKey_) required this.packageId, @JsonKey(name: BookingRequestListItem.requestedStartKey_) required this.requestedStart, @JsonKey(name: BookingRequestListItem.requestedEndKey_) required this.requestedEnd, @JsonKey(name: BookingRequestListItem.locationTextKey_) this.locationText, @JsonKey(name: BookingRequestListItem.notesKey_) this.notes, @JsonKey(name: BookingRequestListItem.statusKey_) required this.status, @JsonKey(name: BookingRequestListItem.expiresAtKey_) required this.expiresAt, @JsonKey(name: BookingRequestListItem.createdAtKey_) required this.createdAt, @JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_) this.secondsUntilExpiry}): super._();
  factory _BookingRequestListItem.fromJson(Map<String, dynamic> json) => _$BookingRequestListItemFromJson(json);

/// id
@override@JsonKey(name: BookingRequestListItem.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: BookingRequestListItem.proUserIdKey_) final  String proUserId;
/// clientUserId
@override@JsonKey(name: BookingRequestListItem.clientUserIdKey_) final  String clientUserId;
/// packageId
@override@JsonKey(name: BookingRequestListItem.packageIdKey_) final  String packageId;
/// requestedStart
@override@JsonKey(name: BookingRequestListItem.requestedStartKey_) final  DateTime requestedStart;
/// requestedEnd
@override@JsonKey(name: BookingRequestListItem.requestedEndKey_) final  DateTime requestedEnd;
/// locationText
@override@JsonKey(name: BookingRequestListItem.locationTextKey_) final  String? locationText;
/// notes
@override@JsonKey(name: BookingRequestListItem.notesKey_) final  String? notes;
/// status
@override@JsonKey(name: BookingRequestListItem.statusKey_) final  BookingRequestStatus status;
/// expiresAt
@override@JsonKey(name: BookingRequestListItem.expiresAtKey_) final  DateTime expiresAt;
/// createdAt
@override@JsonKey(name: BookingRequestListItem.createdAtKey_) final  DateTime createdAt;
/// secondsUntilExpiry
@override@JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_) final  int? secondsUntilExpiry;

/// Create a copy of BookingRequestListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingRequestListItemCopyWith<_BookingRequestListItem> get copyWith => __$BookingRequestListItemCopyWithImpl<_BookingRequestListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingRequestListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingRequestListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.secondsUntilExpiry, secondsUntilExpiry) || other.secondsUntilExpiry == secondsUntilExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,packageId,requestedStart,requestedEnd,locationText,notes,status,expiresAt,createdAt,secondsUntilExpiry);

@override
String toString() {
  return 'BookingRequestListItem(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, packageId: $packageId, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, notes: $notes, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, secondsUntilExpiry: $secondsUntilExpiry)';
}


}

/// @nodoc
abstract mixin class _$BookingRequestListItemCopyWith<$Res> implements $BookingRequestListItemCopyWith<$Res> {
  factory _$BookingRequestListItemCopyWith(_BookingRequestListItem value, $Res Function(_BookingRequestListItem) _then) = __$BookingRequestListItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingRequestListItem.idKey_) String id,@JsonKey(name: BookingRequestListItem.proUserIdKey_) String proUserId,@JsonKey(name: BookingRequestListItem.clientUserIdKey_) String clientUserId,@JsonKey(name: BookingRequestListItem.packageIdKey_) String packageId,@JsonKey(name: BookingRequestListItem.requestedStartKey_) DateTime requestedStart,@JsonKey(name: BookingRequestListItem.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: BookingRequestListItem.locationTextKey_) String? locationText,@JsonKey(name: BookingRequestListItem.notesKey_) String? notes,@JsonKey(name: BookingRequestListItem.statusKey_) BookingRequestStatus status,@JsonKey(name: BookingRequestListItem.expiresAtKey_) DateTime expiresAt,@JsonKey(name: BookingRequestListItem.createdAtKey_) DateTime createdAt,@JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_) int? secondsUntilExpiry
});




}
/// @nodoc
class __$BookingRequestListItemCopyWithImpl<$Res>
    implements _$BookingRequestListItemCopyWith<$Res> {
  __$BookingRequestListItemCopyWithImpl(this._self, this._then);

  final _BookingRequestListItem _self;
  final $Res Function(_BookingRequestListItem) _then;

/// Create a copy of BookingRequestListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = null,Object? packageId = null,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? notes = freezed,Object? status = null,Object? expiresAt = null,Object? createdAt = null,Object? secondsUntilExpiry = freezed,}) {
  return _then(_BookingRequestListItem(
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
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,secondsUntilExpiry: freezed == secondsUntilExpiry ? _self.secondsUntilExpiry : secondsUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
