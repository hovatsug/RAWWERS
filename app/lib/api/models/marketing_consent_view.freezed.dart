// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketing_consent_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketingConsentView {

/// id
@JsonKey(name: MarketingConsentView.idKey_) String get id;/// gigId
@JsonKey(name: MarketingConsentView.gigIdKey_) String get gigId;/// mediaAssetId
@JsonKey(name: MarketingConsentView.mediaAssetIdKey_) String get mediaAssetId;/// thumbnailUrl
@JsonKey(name: MarketingConsentView.thumbnailUrlKey_) String? get thumbnailUrl;/// photographerCredit
@JsonKey(name: MarketingConsentView.photographerCreditKey_) String get photographerCredit;/// scope
@JsonKey(name: MarketingConsentView.scopeKey_) String get scope;/// termMonths
@JsonKey(name: MarketingConsentView.termMonthsKey_) int get termMonths;/// grantedAt
@JsonKey(name: MarketingConsentView.grantedAtKey_) DateTime get grantedAt;/// endsAt
@JsonKey(name: MarketingConsentView.endsAtKey_) DateTime get endsAt;/// status
@JsonKey(name: MarketingConsentView.statusKey_) String get status;/// withdrawnAt
@JsonKey(name: MarketingConsentView.withdrawnAtKey_) DateTime? get withdrawnAt;/// renewsConsentId
@JsonKey(name: MarketingConsentView.renewsConsentIdKey_) String? get renewsConsentId;
/// Create a copy of MarketingConsentView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketingConsentViewCopyWith<MarketingConsentView> get copyWith => _$MarketingConsentViewCopyWithImpl<MarketingConsentView>(this as MarketingConsentView, _$identity);

  /// Serializes this MarketingConsentView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketingConsentView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.photographerCredit, photographerCredit) || other.photographerCredit == photographerCredit)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.withdrawnAt, withdrawnAt) || other.withdrawnAt == withdrawnAt)&&(identical(other.renewsConsentId, renewsConsentId) || other.renewsConsentId == renewsConsentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,mediaAssetId,thumbnailUrl,photographerCredit,scope,termMonths,grantedAt,endsAt,status,withdrawnAt,renewsConsentId);

@override
String toString() {
  return 'MarketingConsentView(id: $id, gigId: $gigId, mediaAssetId: $mediaAssetId, thumbnailUrl: $thumbnailUrl, photographerCredit: $photographerCredit, scope: $scope, termMonths: $termMonths, grantedAt: $grantedAt, endsAt: $endsAt, status: $status, withdrawnAt: $withdrawnAt, renewsConsentId: $renewsConsentId)';
}


}

/// @nodoc
abstract mixin class $MarketingConsentViewCopyWith<$Res>  {
  factory $MarketingConsentViewCopyWith(MarketingConsentView value, $Res Function(MarketingConsentView) _then) = _$MarketingConsentViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MarketingConsentView.idKey_) String id,@JsonKey(name: MarketingConsentView.gigIdKey_) String gigId,@JsonKey(name: MarketingConsentView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MarketingConsentView.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: MarketingConsentView.photographerCreditKey_) String photographerCredit,@JsonKey(name: MarketingConsentView.scopeKey_) String scope,@JsonKey(name: MarketingConsentView.termMonthsKey_) int termMonths,@JsonKey(name: MarketingConsentView.grantedAtKey_) DateTime grantedAt,@JsonKey(name: MarketingConsentView.endsAtKey_) DateTime endsAt,@JsonKey(name: MarketingConsentView.statusKey_) String status,@JsonKey(name: MarketingConsentView.withdrawnAtKey_) DateTime? withdrawnAt,@JsonKey(name: MarketingConsentView.renewsConsentIdKey_) String? renewsConsentId
});




}
/// @nodoc
class _$MarketingConsentViewCopyWithImpl<$Res>
    implements $MarketingConsentViewCopyWith<$Res> {
  _$MarketingConsentViewCopyWithImpl(this._self, this._then);

  final MarketingConsentView _self;
  final $Res Function(MarketingConsentView) _then;

/// Create a copy of MarketingConsentView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gigId = null,Object? mediaAssetId = null,Object? thumbnailUrl = freezed,Object? photographerCredit = null,Object? scope = null,Object? termMonths = null,Object? grantedAt = null,Object? endsAt = null,Object? status = null,Object? withdrawnAt = freezed,Object? renewsConsentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,photographerCredit: null == photographerCredit ? _self.photographerCredit : photographerCredit // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,grantedAt: null == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,withdrawnAt: freezed == withdrawnAt ? _self.withdrawnAt : withdrawnAt // ignore: cast_nullable_to_non_nullable
as DateTime?,renewsConsentId: freezed == renewsConsentId ? _self.renewsConsentId : renewsConsentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketingConsentView].
extension MarketingConsentViewPatterns on MarketingConsentView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketingConsentView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketingConsentView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketingConsentView value)  $default,){
final _that = this;
switch (_that) {
case _MarketingConsentView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketingConsentView value)?  $default,){
final _that = this;
switch (_that) {
case _MarketingConsentView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingConsentView.idKey_)  String id, @JsonKey(name: MarketingConsentView.gigIdKey_)  String gigId, @JsonKey(name: MarketingConsentView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MarketingConsentView.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: MarketingConsentView.photographerCreditKey_)  String photographerCredit, @JsonKey(name: MarketingConsentView.scopeKey_)  String scope, @JsonKey(name: MarketingConsentView.termMonthsKey_)  int termMonths, @JsonKey(name: MarketingConsentView.grantedAtKey_)  DateTime grantedAt, @JsonKey(name: MarketingConsentView.endsAtKey_)  DateTime endsAt, @JsonKey(name: MarketingConsentView.statusKey_)  String status, @JsonKey(name: MarketingConsentView.withdrawnAtKey_)  DateTime? withdrawnAt, @JsonKey(name: MarketingConsentView.renewsConsentIdKey_)  String? renewsConsentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketingConsentView() when $default != null:
return $default(_that.id,_that.gigId,_that.mediaAssetId,_that.thumbnailUrl,_that.photographerCredit,_that.scope,_that.termMonths,_that.grantedAt,_that.endsAt,_that.status,_that.withdrawnAt,_that.renewsConsentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingConsentView.idKey_)  String id, @JsonKey(name: MarketingConsentView.gigIdKey_)  String gigId, @JsonKey(name: MarketingConsentView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MarketingConsentView.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: MarketingConsentView.photographerCreditKey_)  String photographerCredit, @JsonKey(name: MarketingConsentView.scopeKey_)  String scope, @JsonKey(name: MarketingConsentView.termMonthsKey_)  int termMonths, @JsonKey(name: MarketingConsentView.grantedAtKey_)  DateTime grantedAt, @JsonKey(name: MarketingConsentView.endsAtKey_)  DateTime endsAt, @JsonKey(name: MarketingConsentView.statusKey_)  String status, @JsonKey(name: MarketingConsentView.withdrawnAtKey_)  DateTime? withdrawnAt, @JsonKey(name: MarketingConsentView.renewsConsentIdKey_)  String? renewsConsentId)  $default,) {final _that = this;
switch (_that) {
case _MarketingConsentView():
return $default(_that.id,_that.gigId,_that.mediaAssetId,_that.thumbnailUrl,_that.photographerCredit,_that.scope,_that.termMonths,_that.grantedAt,_that.endsAt,_that.status,_that.withdrawnAt,_that.renewsConsentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MarketingConsentView.idKey_)  String id, @JsonKey(name: MarketingConsentView.gigIdKey_)  String gigId, @JsonKey(name: MarketingConsentView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: MarketingConsentView.thumbnailUrlKey_)  String? thumbnailUrl, @JsonKey(name: MarketingConsentView.photographerCreditKey_)  String photographerCredit, @JsonKey(name: MarketingConsentView.scopeKey_)  String scope, @JsonKey(name: MarketingConsentView.termMonthsKey_)  int termMonths, @JsonKey(name: MarketingConsentView.grantedAtKey_)  DateTime grantedAt, @JsonKey(name: MarketingConsentView.endsAtKey_)  DateTime endsAt, @JsonKey(name: MarketingConsentView.statusKey_)  String status, @JsonKey(name: MarketingConsentView.withdrawnAtKey_)  DateTime? withdrawnAt, @JsonKey(name: MarketingConsentView.renewsConsentIdKey_)  String? renewsConsentId)?  $default,) {final _that = this;
switch (_that) {
case _MarketingConsentView() when $default != null:
return $default(_that.id,_that.gigId,_that.mediaAssetId,_that.thumbnailUrl,_that.photographerCredit,_that.scope,_that.termMonths,_that.grantedAt,_that.endsAt,_that.status,_that.withdrawnAt,_that.renewsConsentId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MarketingConsentView extends MarketingConsentView {
  const _MarketingConsentView({@JsonKey(name: MarketingConsentView.idKey_) required this.id, @JsonKey(name: MarketingConsentView.gigIdKey_) required this.gigId, @JsonKey(name: MarketingConsentView.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: MarketingConsentView.thumbnailUrlKey_) this.thumbnailUrl, @JsonKey(name: MarketingConsentView.photographerCreditKey_) required this.photographerCredit, @JsonKey(name: MarketingConsentView.scopeKey_) required this.scope, @JsonKey(name: MarketingConsentView.termMonthsKey_) required this.termMonths, @JsonKey(name: MarketingConsentView.grantedAtKey_) required this.grantedAt, @JsonKey(name: MarketingConsentView.endsAtKey_) required this.endsAt, @JsonKey(name: MarketingConsentView.statusKey_) required this.status, @JsonKey(name: MarketingConsentView.withdrawnAtKey_) this.withdrawnAt, @JsonKey(name: MarketingConsentView.renewsConsentIdKey_) this.renewsConsentId}): super._();
  factory _MarketingConsentView.fromJson(Map<String, dynamic> json) => _$MarketingConsentViewFromJson(json);

/// id
@override@JsonKey(name: MarketingConsentView.idKey_) final  String id;
/// gigId
@override@JsonKey(name: MarketingConsentView.gigIdKey_) final  String gigId;
/// mediaAssetId
@override@JsonKey(name: MarketingConsentView.mediaAssetIdKey_) final  String mediaAssetId;
/// thumbnailUrl
@override@JsonKey(name: MarketingConsentView.thumbnailUrlKey_) final  String? thumbnailUrl;
/// photographerCredit
@override@JsonKey(name: MarketingConsentView.photographerCreditKey_) final  String photographerCredit;
/// scope
@override@JsonKey(name: MarketingConsentView.scopeKey_) final  String scope;
/// termMonths
@override@JsonKey(name: MarketingConsentView.termMonthsKey_) final  int termMonths;
/// grantedAt
@override@JsonKey(name: MarketingConsentView.grantedAtKey_) final  DateTime grantedAt;
/// endsAt
@override@JsonKey(name: MarketingConsentView.endsAtKey_) final  DateTime endsAt;
/// status
@override@JsonKey(name: MarketingConsentView.statusKey_) final  String status;
/// withdrawnAt
@override@JsonKey(name: MarketingConsentView.withdrawnAtKey_) final  DateTime? withdrawnAt;
/// renewsConsentId
@override@JsonKey(name: MarketingConsentView.renewsConsentIdKey_) final  String? renewsConsentId;

/// Create a copy of MarketingConsentView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketingConsentViewCopyWith<_MarketingConsentView> get copyWith => __$MarketingConsentViewCopyWithImpl<_MarketingConsentView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketingConsentViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketingConsentView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.photographerCredit, photographerCredit) || other.photographerCredit == photographerCredit)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.withdrawnAt, withdrawnAt) || other.withdrawnAt == withdrawnAt)&&(identical(other.renewsConsentId, renewsConsentId) || other.renewsConsentId == renewsConsentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,mediaAssetId,thumbnailUrl,photographerCredit,scope,termMonths,grantedAt,endsAt,status,withdrawnAt,renewsConsentId);

@override
String toString() {
  return 'MarketingConsentView(id: $id, gigId: $gigId, mediaAssetId: $mediaAssetId, thumbnailUrl: $thumbnailUrl, photographerCredit: $photographerCredit, scope: $scope, termMonths: $termMonths, grantedAt: $grantedAt, endsAt: $endsAt, status: $status, withdrawnAt: $withdrawnAt, renewsConsentId: $renewsConsentId)';
}


}

/// @nodoc
abstract mixin class _$MarketingConsentViewCopyWith<$Res> implements $MarketingConsentViewCopyWith<$Res> {
  factory _$MarketingConsentViewCopyWith(_MarketingConsentView value, $Res Function(_MarketingConsentView) _then) = __$MarketingConsentViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MarketingConsentView.idKey_) String id,@JsonKey(name: MarketingConsentView.gigIdKey_) String gigId,@JsonKey(name: MarketingConsentView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: MarketingConsentView.thumbnailUrlKey_) String? thumbnailUrl,@JsonKey(name: MarketingConsentView.photographerCreditKey_) String photographerCredit,@JsonKey(name: MarketingConsentView.scopeKey_) String scope,@JsonKey(name: MarketingConsentView.termMonthsKey_) int termMonths,@JsonKey(name: MarketingConsentView.grantedAtKey_) DateTime grantedAt,@JsonKey(name: MarketingConsentView.endsAtKey_) DateTime endsAt,@JsonKey(name: MarketingConsentView.statusKey_) String status,@JsonKey(name: MarketingConsentView.withdrawnAtKey_) DateTime? withdrawnAt,@JsonKey(name: MarketingConsentView.renewsConsentIdKey_) String? renewsConsentId
});




}
/// @nodoc
class __$MarketingConsentViewCopyWithImpl<$Res>
    implements _$MarketingConsentViewCopyWith<$Res> {
  __$MarketingConsentViewCopyWithImpl(this._self, this._then);

  final _MarketingConsentView _self;
  final $Res Function(_MarketingConsentView) _then;

/// Create a copy of MarketingConsentView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gigId = null,Object? mediaAssetId = null,Object? thumbnailUrl = freezed,Object? photographerCredit = null,Object? scope = null,Object? termMonths = null,Object? grantedAt = null,Object? endsAt = null,Object? status = null,Object? withdrawnAt = freezed,Object? renewsConsentId = freezed,}) {
  return _then(_MarketingConsentView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,photographerCredit: null == photographerCredit ? _self.photographerCredit : photographerCredit // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,grantedAt: null == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,withdrawnAt: freezed == withdrawnAt ? _self.withdrawnAt : withdrawnAt // ignore: cast_nullable_to_non_nullable
as DateTime?,renewsConsentId: freezed == renewsConsentId ? _self.renewsConsentId : renewsConsentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
