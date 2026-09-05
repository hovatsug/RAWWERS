// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_detail_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisputeDetailView {

/// id
@JsonKey(name: DisputeDetailView.idKey_) String get id;/// gigId
@JsonKey(name: DisputeDetailView.gigIdKey_) String? get gigId;/// extraPurchaseId
@JsonKey(name: DisputeDetailView.extraPurchaseIdKey_) String? get extraPurchaseId;/// openedByUserId
@JsonKey(name: DisputeDetailView.openedByUserIdKey_) String get openedByUserId;/// againstUserId
@JsonKey(name: DisputeDetailView.againstUserIdKey_) String? get againstUserId;/// category
@JsonKey(name: DisputeDetailView.categoryKey_) DisputeCategory get category;/// status
@JsonKey(name: DisputeDetailView.statusKey_) DisputeStatus get status;/// reason
@JsonKey(name: DisputeDetailView.reasonKey_) String get reason;/// summary
@JsonKey(name: DisputeDetailView.summaryKey_) String get summary;/// requestedRefundAmount
@JsonKey(name: DisputeDetailView.requestedRefundAmountKey_) String? get requestedRefundAmount;/// currency
@JsonKey(name: DisputeDetailView.currencyKey_) String get currency;/// openedAt
@JsonKey(name: DisputeDetailView.openedAtKey_) DateTime get openedAt;/// dueResponseAt
@JsonKey(name: DisputeDetailView.dueResponseAtKey_) DateTime? get dueResponseAt;/// resolvedAt
@JsonKey(name: DisputeDetailView.resolvedAtKey_) DateTime? get resolvedAt;/// resolution
@JsonKey(name: DisputeDetailView.resolutionKey_) Map<String, dynamic>? get resolution;/// metadata
@JsonKey(name: DisputeDetailView.metadataKey_) Map<String, dynamic>? get metadata;/// createdAt
@JsonKey(name: DisputeDetailView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: DisputeDetailView.updatedAtKey_) DateTime get updatedAt;/// messages
@JsonKey(name: DisputeDetailView.messagesKey_) List<DisputeMessageView>? get messages;/// events
@JsonKey(name: DisputeDetailView.eventsKey_) List<DisputeEventView>? get events;
/// Create a copy of DisputeDetailView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisputeDetailViewCopyWith<DisputeDetailView> get copyWith => _$DisputeDetailViewCopyWithImpl<DisputeDetailView>(this as DisputeDetailView, _$identity);

  /// Serializes this DisputeDetailView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisputeDetailView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.extraPurchaseId, extraPurchaseId) || other.extraPurchaseId == extraPurchaseId)&&(identical(other.openedByUserId, openedByUserId) || other.openedByUserId == openedByUserId)&&(identical(other.againstUserId, againstUserId) || other.againstUserId == againstUserId)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.requestedRefundAmount, requestedRefundAmount) || other.requestedRefundAmount == requestedRefundAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.dueResponseAt, dueResponseAt) || other.dueResponseAt == dueResponseAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&const DeepCollectionEquality().equals(other.resolution, resolution)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.events, events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,gigId,extraPurchaseId,openedByUserId,againstUserId,category,status,reason,summary,requestedRefundAmount,currency,openedAt,dueResponseAt,resolvedAt,const DeepCollectionEquality().hash(resolution),const DeepCollectionEquality().hash(metadata),createdAt,updatedAt,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(events)]);

@override
String toString() {
  return 'DisputeDetailView(id: $id, gigId: $gigId, extraPurchaseId: $extraPurchaseId, openedByUserId: $openedByUserId, againstUserId: $againstUserId, category: $category, status: $status, reason: $reason, summary: $summary, requestedRefundAmount: $requestedRefundAmount, currency: $currency, openedAt: $openedAt, dueResponseAt: $dueResponseAt, resolvedAt: $resolvedAt, resolution: $resolution, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, messages: $messages, events: $events)';
}


}

/// @nodoc
abstract mixin class $DisputeDetailViewCopyWith<$Res>  {
  factory $DisputeDetailViewCopyWith(DisputeDetailView value, $Res Function(DisputeDetailView) _then) = _$DisputeDetailViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisputeDetailView.idKey_) String id,@JsonKey(name: DisputeDetailView.gigIdKey_) String? gigId,@JsonKey(name: DisputeDetailView.extraPurchaseIdKey_) String? extraPurchaseId,@JsonKey(name: DisputeDetailView.openedByUserIdKey_) String openedByUserId,@JsonKey(name: DisputeDetailView.againstUserIdKey_) String? againstUserId,@JsonKey(name: DisputeDetailView.categoryKey_) DisputeCategory category,@JsonKey(name: DisputeDetailView.statusKey_) DisputeStatus status,@JsonKey(name: DisputeDetailView.reasonKey_) String reason,@JsonKey(name: DisputeDetailView.summaryKey_) String summary,@JsonKey(name: DisputeDetailView.requestedRefundAmountKey_) String? requestedRefundAmount,@JsonKey(name: DisputeDetailView.currencyKey_) String currency,@JsonKey(name: DisputeDetailView.openedAtKey_) DateTime openedAt,@JsonKey(name: DisputeDetailView.dueResponseAtKey_) DateTime? dueResponseAt,@JsonKey(name: DisputeDetailView.resolvedAtKey_) DateTime? resolvedAt,@JsonKey(name: DisputeDetailView.resolutionKey_) Map<String, dynamic>? resolution,@JsonKey(name: DisputeDetailView.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: DisputeDetailView.createdAtKey_) DateTime createdAt,@JsonKey(name: DisputeDetailView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: DisputeDetailView.messagesKey_) List<DisputeMessageView>? messages,@JsonKey(name: DisputeDetailView.eventsKey_) List<DisputeEventView>? events
});




}
/// @nodoc
class _$DisputeDetailViewCopyWithImpl<$Res>
    implements $DisputeDetailViewCopyWith<$Res> {
  _$DisputeDetailViewCopyWithImpl(this._self, this._then);

  final DisputeDetailView _self;
  final $Res Function(DisputeDetailView) _then;

/// Create a copy of DisputeDetailView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gigId = freezed,Object? extraPurchaseId = freezed,Object? openedByUserId = null,Object? againstUserId = freezed,Object? category = null,Object? status = null,Object? reason = null,Object? summary = null,Object? requestedRefundAmount = freezed,Object? currency = null,Object? openedAt = null,Object? dueResponseAt = freezed,Object? resolvedAt = freezed,Object? resolution = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,Object? messages = freezed,Object? events = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,extraPurchaseId: freezed == extraPurchaseId ? _self.extraPurchaseId : extraPurchaseId // ignore: cast_nullable_to_non_nullable
as String?,openedByUserId: null == openedByUserId ? _self.openedByUserId : openedByUserId // ignore: cast_nullable_to_non_nullable
as String,againstUserId: freezed == againstUserId ? _self.againstUserId : againstUserId // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DisputeCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisputeStatus,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,requestedRefundAmount: freezed == requestedRefundAmount ? _self.requestedRefundAmount : requestedRefundAmount // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,dueResponseAt: freezed == dueResponseAt ? _self.dueResponseAt : dueResponseAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: freezed == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<DisputeMessageView>?,events: freezed == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<DisputeEventView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DisputeDetailView].
extension DisputeDetailViewPatterns on DisputeDetailView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisputeDetailView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisputeDetailView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisputeDetailView value)  $default,){
final _that = this;
switch (_that) {
case _DisputeDetailView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisputeDetailView value)?  $default,){
final _that = this;
switch (_that) {
case _DisputeDetailView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeDetailView.idKey_)  String id, @JsonKey(name: DisputeDetailView.gigIdKey_)  String? gigId, @JsonKey(name: DisputeDetailView.extraPurchaseIdKey_)  String? extraPurchaseId, @JsonKey(name: DisputeDetailView.openedByUserIdKey_)  String openedByUserId, @JsonKey(name: DisputeDetailView.againstUserIdKey_)  String? againstUserId, @JsonKey(name: DisputeDetailView.categoryKey_)  DisputeCategory category, @JsonKey(name: DisputeDetailView.statusKey_)  DisputeStatus status, @JsonKey(name: DisputeDetailView.reasonKey_)  String reason, @JsonKey(name: DisputeDetailView.summaryKey_)  String summary, @JsonKey(name: DisputeDetailView.requestedRefundAmountKey_)  String? requestedRefundAmount, @JsonKey(name: DisputeDetailView.currencyKey_)  String currency, @JsonKey(name: DisputeDetailView.openedAtKey_)  DateTime openedAt, @JsonKey(name: DisputeDetailView.dueResponseAtKey_)  DateTime? dueResponseAt, @JsonKey(name: DisputeDetailView.resolvedAtKey_)  DateTime? resolvedAt, @JsonKey(name: DisputeDetailView.resolutionKey_)  Map<String, dynamic>? resolution, @JsonKey(name: DisputeDetailView.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: DisputeDetailView.createdAtKey_)  DateTime createdAt, @JsonKey(name: DisputeDetailView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: DisputeDetailView.messagesKey_)  List<DisputeMessageView>? messages, @JsonKey(name: DisputeDetailView.eventsKey_)  List<DisputeEventView>? events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisputeDetailView() when $default != null:
return $default(_that.id,_that.gigId,_that.extraPurchaseId,_that.openedByUserId,_that.againstUserId,_that.category,_that.status,_that.reason,_that.summary,_that.requestedRefundAmount,_that.currency,_that.openedAt,_that.dueResponseAt,_that.resolvedAt,_that.resolution,_that.metadata,_that.createdAt,_that.updatedAt,_that.messages,_that.events);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeDetailView.idKey_)  String id, @JsonKey(name: DisputeDetailView.gigIdKey_)  String? gigId, @JsonKey(name: DisputeDetailView.extraPurchaseIdKey_)  String? extraPurchaseId, @JsonKey(name: DisputeDetailView.openedByUserIdKey_)  String openedByUserId, @JsonKey(name: DisputeDetailView.againstUserIdKey_)  String? againstUserId, @JsonKey(name: DisputeDetailView.categoryKey_)  DisputeCategory category, @JsonKey(name: DisputeDetailView.statusKey_)  DisputeStatus status, @JsonKey(name: DisputeDetailView.reasonKey_)  String reason, @JsonKey(name: DisputeDetailView.summaryKey_)  String summary, @JsonKey(name: DisputeDetailView.requestedRefundAmountKey_)  String? requestedRefundAmount, @JsonKey(name: DisputeDetailView.currencyKey_)  String currency, @JsonKey(name: DisputeDetailView.openedAtKey_)  DateTime openedAt, @JsonKey(name: DisputeDetailView.dueResponseAtKey_)  DateTime? dueResponseAt, @JsonKey(name: DisputeDetailView.resolvedAtKey_)  DateTime? resolvedAt, @JsonKey(name: DisputeDetailView.resolutionKey_)  Map<String, dynamic>? resolution, @JsonKey(name: DisputeDetailView.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: DisputeDetailView.createdAtKey_)  DateTime createdAt, @JsonKey(name: DisputeDetailView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: DisputeDetailView.messagesKey_)  List<DisputeMessageView>? messages, @JsonKey(name: DisputeDetailView.eventsKey_)  List<DisputeEventView>? events)  $default,) {final _that = this;
switch (_that) {
case _DisputeDetailView():
return $default(_that.id,_that.gigId,_that.extraPurchaseId,_that.openedByUserId,_that.againstUserId,_that.category,_that.status,_that.reason,_that.summary,_that.requestedRefundAmount,_that.currency,_that.openedAt,_that.dueResponseAt,_that.resolvedAt,_that.resolution,_that.metadata,_that.createdAt,_that.updatedAt,_that.messages,_that.events);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisputeDetailView.idKey_)  String id, @JsonKey(name: DisputeDetailView.gigIdKey_)  String? gigId, @JsonKey(name: DisputeDetailView.extraPurchaseIdKey_)  String? extraPurchaseId, @JsonKey(name: DisputeDetailView.openedByUserIdKey_)  String openedByUserId, @JsonKey(name: DisputeDetailView.againstUserIdKey_)  String? againstUserId, @JsonKey(name: DisputeDetailView.categoryKey_)  DisputeCategory category, @JsonKey(name: DisputeDetailView.statusKey_)  DisputeStatus status, @JsonKey(name: DisputeDetailView.reasonKey_)  String reason, @JsonKey(name: DisputeDetailView.summaryKey_)  String summary, @JsonKey(name: DisputeDetailView.requestedRefundAmountKey_)  String? requestedRefundAmount, @JsonKey(name: DisputeDetailView.currencyKey_)  String currency, @JsonKey(name: DisputeDetailView.openedAtKey_)  DateTime openedAt, @JsonKey(name: DisputeDetailView.dueResponseAtKey_)  DateTime? dueResponseAt, @JsonKey(name: DisputeDetailView.resolvedAtKey_)  DateTime? resolvedAt, @JsonKey(name: DisputeDetailView.resolutionKey_)  Map<String, dynamic>? resolution, @JsonKey(name: DisputeDetailView.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: DisputeDetailView.createdAtKey_)  DateTime createdAt, @JsonKey(name: DisputeDetailView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: DisputeDetailView.messagesKey_)  List<DisputeMessageView>? messages, @JsonKey(name: DisputeDetailView.eventsKey_)  List<DisputeEventView>? events)?  $default,) {final _that = this;
switch (_that) {
case _DisputeDetailView() when $default != null:
return $default(_that.id,_that.gigId,_that.extraPurchaseId,_that.openedByUserId,_that.againstUserId,_that.category,_that.status,_that.reason,_that.summary,_that.requestedRefundAmount,_that.currency,_that.openedAt,_that.dueResponseAt,_that.resolvedAt,_that.resolution,_that.metadata,_that.createdAt,_that.updatedAt,_that.messages,_that.events);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisputeDetailView extends DisputeDetailView {
  const _DisputeDetailView({@JsonKey(name: DisputeDetailView.idKey_) required this.id, @JsonKey(name: DisputeDetailView.gigIdKey_) this.gigId, @JsonKey(name: DisputeDetailView.extraPurchaseIdKey_) this.extraPurchaseId, @JsonKey(name: DisputeDetailView.openedByUserIdKey_) required this.openedByUserId, @JsonKey(name: DisputeDetailView.againstUserIdKey_) this.againstUserId, @JsonKey(name: DisputeDetailView.categoryKey_) required this.category, @JsonKey(name: DisputeDetailView.statusKey_) required this.status, @JsonKey(name: DisputeDetailView.reasonKey_) required this.reason, @JsonKey(name: DisputeDetailView.summaryKey_) required this.summary, @JsonKey(name: DisputeDetailView.requestedRefundAmountKey_) this.requestedRefundAmount, @JsonKey(name: DisputeDetailView.currencyKey_) required this.currency, @JsonKey(name: DisputeDetailView.openedAtKey_) required this.openedAt, @JsonKey(name: DisputeDetailView.dueResponseAtKey_) this.dueResponseAt, @JsonKey(name: DisputeDetailView.resolvedAtKey_) this.resolvedAt, @JsonKey(name: DisputeDetailView.resolutionKey_) final  Map<String, dynamic>? resolution, @JsonKey(name: DisputeDetailView.metadataKey_) final  Map<String, dynamic>? metadata, @JsonKey(name: DisputeDetailView.createdAtKey_) required this.createdAt, @JsonKey(name: DisputeDetailView.updatedAtKey_) required this.updatedAt, @JsonKey(name: DisputeDetailView.messagesKey_) final  List<DisputeMessageView>? messages, @JsonKey(name: DisputeDetailView.eventsKey_) final  List<DisputeEventView>? events}): _resolution = resolution,_metadata = metadata,_messages = messages,_events = events,super._();
  factory _DisputeDetailView.fromJson(Map<String, dynamic> json) => _$DisputeDetailViewFromJson(json);

/// id
@override@JsonKey(name: DisputeDetailView.idKey_) final  String id;
/// gigId
@override@JsonKey(name: DisputeDetailView.gigIdKey_) final  String? gigId;
/// extraPurchaseId
@override@JsonKey(name: DisputeDetailView.extraPurchaseIdKey_) final  String? extraPurchaseId;
/// openedByUserId
@override@JsonKey(name: DisputeDetailView.openedByUserIdKey_) final  String openedByUserId;
/// againstUserId
@override@JsonKey(name: DisputeDetailView.againstUserIdKey_) final  String? againstUserId;
/// category
@override@JsonKey(name: DisputeDetailView.categoryKey_) final  DisputeCategory category;
/// status
@override@JsonKey(name: DisputeDetailView.statusKey_) final  DisputeStatus status;
/// reason
@override@JsonKey(name: DisputeDetailView.reasonKey_) final  String reason;
/// summary
@override@JsonKey(name: DisputeDetailView.summaryKey_) final  String summary;
/// requestedRefundAmount
@override@JsonKey(name: DisputeDetailView.requestedRefundAmountKey_) final  String? requestedRefundAmount;
/// currency
@override@JsonKey(name: DisputeDetailView.currencyKey_) final  String currency;
/// openedAt
@override@JsonKey(name: DisputeDetailView.openedAtKey_) final  DateTime openedAt;
/// dueResponseAt
@override@JsonKey(name: DisputeDetailView.dueResponseAtKey_) final  DateTime? dueResponseAt;
/// resolvedAt
@override@JsonKey(name: DisputeDetailView.resolvedAtKey_) final  DateTime? resolvedAt;
/// resolution
 final  Map<String, dynamic>? _resolution;
/// resolution
@override@JsonKey(name: DisputeDetailView.resolutionKey_) Map<String, dynamic>? get resolution {
  final value = _resolution;
  if (value == null) return null;
  if (_resolution is EqualUnmodifiableMapView) return _resolution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: DisputeDetailView.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: DisputeDetailView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: DisputeDetailView.updatedAtKey_) final  DateTime updatedAt;
/// messages
 final  List<DisputeMessageView>? _messages;
/// messages
@override@JsonKey(name: DisputeDetailView.messagesKey_) List<DisputeMessageView>? get messages {
  final value = _messages;
  if (value == null) return null;
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// events
 final  List<DisputeEventView>? _events;
/// events
@override@JsonKey(name: DisputeDetailView.eventsKey_) List<DisputeEventView>? get events {
  final value = _events;
  if (value == null) return null;
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of DisputeDetailView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisputeDetailViewCopyWith<_DisputeDetailView> get copyWith => __$DisputeDetailViewCopyWithImpl<_DisputeDetailView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisputeDetailViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisputeDetailView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.extraPurchaseId, extraPurchaseId) || other.extraPurchaseId == extraPurchaseId)&&(identical(other.openedByUserId, openedByUserId) || other.openedByUserId == openedByUserId)&&(identical(other.againstUserId, againstUserId) || other.againstUserId == againstUserId)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.requestedRefundAmount, requestedRefundAmount) || other.requestedRefundAmount == requestedRefundAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.dueResponseAt, dueResponseAt) || other.dueResponseAt == dueResponseAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&const DeepCollectionEquality().equals(other._resolution, _resolution)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,gigId,extraPurchaseId,openedByUserId,againstUserId,category,status,reason,summary,requestedRefundAmount,currency,openedAt,dueResponseAt,resolvedAt,const DeepCollectionEquality().hash(_resolution),const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_events)]);

@override
String toString() {
  return 'DisputeDetailView(id: $id, gigId: $gigId, extraPurchaseId: $extraPurchaseId, openedByUserId: $openedByUserId, againstUserId: $againstUserId, category: $category, status: $status, reason: $reason, summary: $summary, requestedRefundAmount: $requestedRefundAmount, currency: $currency, openedAt: $openedAt, dueResponseAt: $dueResponseAt, resolvedAt: $resolvedAt, resolution: $resolution, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, messages: $messages, events: $events)';
}


}

/// @nodoc
abstract mixin class _$DisputeDetailViewCopyWith<$Res> implements $DisputeDetailViewCopyWith<$Res> {
  factory _$DisputeDetailViewCopyWith(_DisputeDetailView value, $Res Function(_DisputeDetailView) _then) = __$DisputeDetailViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisputeDetailView.idKey_) String id,@JsonKey(name: DisputeDetailView.gigIdKey_) String? gigId,@JsonKey(name: DisputeDetailView.extraPurchaseIdKey_) String? extraPurchaseId,@JsonKey(name: DisputeDetailView.openedByUserIdKey_) String openedByUserId,@JsonKey(name: DisputeDetailView.againstUserIdKey_) String? againstUserId,@JsonKey(name: DisputeDetailView.categoryKey_) DisputeCategory category,@JsonKey(name: DisputeDetailView.statusKey_) DisputeStatus status,@JsonKey(name: DisputeDetailView.reasonKey_) String reason,@JsonKey(name: DisputeDetailView.summaryKey_) String summary,@JsonKey(name: DisputeDetailView.requestedRefundAmountKey_) String? requestedRefundAmount,@JsonKey(name: DisputeDetailView.currencyKey_) String currency,@JsonKey(name: DisputeDetailView.openedAtKey_) DateTime openedAt,@JsonKey(name: DisputeDetailView.dueResponseAtKey_) DateTime? dueResponseAt,@JsonKey(name: DisputeDetailView.resolvedAtKey_) DateTime? resolvedAt,@JsonKey(name: DisputeDetailView.resolutionKey_) Map<String, dynamic>? resolution,@JsonKey(name: DisputeDetailView.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: DisputeDetailView.createdAtKey_) DateTime createdAt,@JsonKey(name: DisputeDetailView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: DisputeDetailView.messagesKey_) List<DisputeMessageView>? messages,@JsonKey(name: DisputeDetailView.eventsKey_) List<DisputeEventView>? events
});




}
/// @nodoc
class __$DisputeDetailViewCopyWithImpl<$Res>
    implements _$DisputeDetailViewCopyWith<$Res> {
  __$DisputeDetailViewCopyWithImpl(this._self, this._then);

  final _DisputeDetailView _self;
  final $Res Function(_DisputeDetailView) _then;

/// Create a copy of DisputeDetailView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gigId = freezed,Object? extraPurchaseId = freezed,Object? openedByUserId = null,Object? againstUserId = freezed,Object? category = null,Object? status = null,Object? reason = null,Object? summary = null,Object? requestedRefundAmount = freezed,Object? currency = null,Object? openedAt = null,Object? dueResponseAt = freezed,Object? resolvedAt = freezed,Object? resolution = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,Object? messages = freezed,Object? events = freezed,}) {
  return _then(_DisputeDetailView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,extraPurchaseId: freezed == extraPurchaseId ? _self.extraPurchaseId : extraPurchaseId // ignore: cast_nullable_to_non_nullable
as String?,openedByUserId: null == openedByUserId ? _self.openedByUserId : openedByUserId // ignore: cast_nullable_to_non_nullable
as String,againstUserId: freezed == againstUserId ? _self.againstUserId : againstUserId // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DisputeCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisputeStatus,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,requestedRefundAmount: freezed == requestedRefundAmount ? _self.requestedRefundAmount : requestedRefundAmount // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,dueResponseAt: freezed == dueResponseAt ? _self.dueResponseAt : dueResponseAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self._resolution : resolution // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: freezed == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<DisputeMessageView>?,events: freezed == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<DisputeEventView>?,
  ));
}


}

// dart format on
