// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketing_consent_offer_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketingConsentOfferResponse {

/// offered
@JsonKey(name: MarketingConsentOfferResponse.offeredKey_) bool get offered;/// reason
@JsonKey(name: MarketingConsentOfferResponse.reasonKey_) String? get reason;/// wordingVersion
@JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_) String? get wordingVersion;/// wordingText
@JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_) String? get wordingText;/// scope
@JsonKey(name: MarketingConsentOfferResponse.scopeKey_) String get scope;/// terms
@JsonKey(name: MarketingConsentOfferResponse.termsKey_) List<MarketingTermView>? get terms;/// defaultTermMonths
@JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_) int get defaultTermMonths;/// photographerCredit
@JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_) String? get photographerCredit;/// photos
@JsonKey(name: MarketingConsentOfferResponse.photosKey_) List<MarketingPhotoView>? get photos;
/// Create a copy of MarketingConsentOfferResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketingConsentOfferResponseCopyWith<MarketingConsentOfferResponse> get copyWith => _$MarketingConsentOfferResponseCopyWithImpl<MarketingConsentOfferResponse>(this as MarketingConsentOfferResponse, _$identity);

  /// Serializes this MarketingConsentOfferResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketingConsentOfferResponse&&(identical(other.offered, offered) || other.offered == offered)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.wordingVersion, wordingVersion) || other.wordingVersion == wordingVersion)&&(identical(other.wordingText, wordingText) || other.wordingText == wordingText)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other.terms, terms)&&(identical(other.defaultTermMonths, defaultTermMonths) || other.defaultTermMonths == defaultTermMonths)&&(identical(other.photographerCredit, photographerCredit) || other.photographerCredit == photographerCredit)&&const DeepCollectionEquality().equals(other.photos, photos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offered,reason,wordingVersion,wordingText,scope,const DeepCollectionEquality().hash(terms),defaultTermMonths,photographerCredit,const DeepCollectionEquality().hash(photos));

@override
String toString() {
  return 'MarketingConsentOfferResponse(offered: $offered, reason: $reason, wordingVersion: $wordingVersion, wordingText: $wordingText, scope: $scope, terms: $terms, defaultTermMonths: $defaultTermMonths, photographerCredit: $photographerCredit, photos: $photos)';
}


}

/// @nodoc
abstract mixin class $MarketingConsentOfferResponseCopyWith<$Res>  {
  factory $MarketingConsentOfferResponseCopyWith(MarketingConsentOfferResponse value, $Res Function(MarketingConsentOfferResponse) _then) = _$MarketingConsentOfferResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MarketingConsentOfferResponse.offeredKey_) bool offered,@JsonKey(name: MarketingConsentOfferResponse.reasonKey_) String? reason,@JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_) String? wordingVersion,@JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_) String? wordingText,@JsonKey(name: MarketingConsentOfferResponse.scopeKey_) String scope,@JsonKey(name: MarketingConsentOfferResponse.termsKey_) List<MarketingTermView>? terms,@JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_) int defaultTermMonths,@JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_) String? photographerCredit,@JsonKey(name: MarketingConsentOfferResponse.photosKey_) List<MarketingPhotoView>? photos
});




}
/// @nodoc
class _$MarketingConsentOfferResponseCopyWithImpl<$Res>
    implements $MarketingConsentOfferResponseCopyWith<$Res> {
  _$MarketingConsentOfferResponseCopyWithImpl(this._self, this._then);

  final MarketingConsentOfferResponse _self;
  final $Res Function(MarketingConsentOfferResponse) _then;

/// Create a copy of MarketingConsentOfferResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offered = null,Object? reason = freezed,Object? wordingVersion = freezed,Object? wordingText = freezed,Object? scope = null,Object? terms = freezed,Object? defaultTermMonths = null,Object? photographerCredit = freezed,Object? photos = freezed,}) {
  return _then(_self.copyWith(
offered: null == offered ? _self.offered : offered // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,wordingVersion: freezed == wordingVersion ? _self.wordingVersion : wordingVersion // ignore: cast_nullable_to_non_nullable
as String?,wordingText: freezed == wordingText ? _self.wordingText : wordingText // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,terms: freezed == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as List<MarketingTermView>?,defaultTermMonths: null == defaultTermMonths ? _self.defaultTermMonths : defaultTermMonths // ignore: cast_nullable_to_non_nullable
as int,photographerCredit: freezed == photographerCredit ? _self.photographerCredit : photographerCredit // ignore: cast_nullable_to_non_nullable
as String?,photos: freezed == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<MarketingPhotoView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketingConsentOfferResponse].
extension MarketingConsentOfferResponsePatterns on MarketingConsentOfferResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketingConsentOfferResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketingConsentOfferResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketingConsentOfferResponse value)  $default,){
final _that = this;
switch (_that) {
case _MarketingConsentOfferResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketingConsentOfferResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MarketingConsentOfferResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingConsentOfferResponse.offeredKey_)  bool offered, @JsonKey(name: MarketingConsentOfferResponse.reasonKey_)  String? reason, @JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_)  String? wordingVersion, @JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_)  String? wordingText, @JsonKey(name: MarketingConsentOfferResponse.scopeKey_)  String scope, @JsonKey(name: MarketingConsentOfferResponse.termsKey_)  List<MarketingTermView>? terms, @JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_)  int defaultTermMonths, @JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_)  String? photographerCredit, @JsonKey(name: MarketingConsentOfferResponse.photosKey_)  List<MarketingPhotoView>? photos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketingConsentOfferResponse() when $default != null:
return $default(_that.offered,_that.reason,_that.wordingVersion,_that.wordingText,_that.scope,_that.terms,_that.defaultTermMonths,_that.photographerCredit,_that.photos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingConsentOfferResponse.offeredKey_)  bool offered, @JsonKey(name: MarketingConsentOfferResponse.reasonKey_)  String? reason, @JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_)  String? wordingVersion, @JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_)  String? wordingText, @JsonKey(name: MarketingConsentOfferResponse.scopeKey_)  String scope, @JsonKey(name: MarketingConsentOfferResponse.termsKey_)  List<MarketingTermView>? terms, @JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_)  int defaultTermMonths, @JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_)  String? photographerCredit, @JsonKey(name: MarketingConsentOfferResponse.photosKey_)  List<MarketingPhotoView>? photos)  $default,) {final _that = this;
switch (_that) {
case _MarketingConsentOfferResponse():
return $default(_that.offered,_that.reason,_that.wordingVersion,_that.wordingText,_that.scope,_that.terms,_that.defaultTermMonths,_that.photographerCredit,_that.photos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MarketingConsentOfferResponse.offeredKey_)  bool offered, @JsonKey(name: MarketingConsentOfferResponse.reasonKey_)  String? reason, @JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_)  String? wordingVersion, @JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_)  String? wordingText, @JsonKey(name: MarketingConsentOfferResponse.scopeKey_)  String scope, @JsonKey(name: MarketingConsentOfferResponse.termsKey_)  List<MarketingTermView>? terms, @JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_)  int defaultTermMonths, @JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_)  String? photographerCredit, @JsonKey(name: MarketingConsentOfferResponse.photosKey_)  List<MarketingPhotoView>? photos)?  $default,) {final _that = this;
switch (_that) {
case _MarketingConsentOfferResponse() when $default != null:
return $default(_that.offered,_that.reason,_that.wordingVersion,_that.wordingText,_that.scope,_that.terms,_that.defaultTermMonths,_that.photographerCredit,_that.photos);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MarketingConsentOfferResponse extends MarketingConsentOfferResponse {
  const _MarketingConsentOfferResponse({@JsonKey(name: MarketingConsentOfferResponse.offeredKey_) required this.offered, @JsonKey(name: MarketingConsentOfferResponse.reasonKey_) this.reason, @JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_) this.wordingVersion, @JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_) this.wordingText, @JsonKey(name: MarketingConsentOfferResponse.scopeKey_) this.scope = 'rawwers_organic', @JsonKey(name: MarketingConsentOfferResponse.termsKey_) final  List<MarketingTermView>? terms, @JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_) this.defaultTermMonths = 12, @JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_) this.photographerCredit, @JsonKey(name: MarketingConsentOfferResponse.photosKey_) final  List<MarketingPhotoView>? photos}): _terms = terms,_photos = photos,super._();
  factory _MarketingConsentOfferResponse.fromJson(Map<String, dynamic> json) => _$MarketingConsentOfferResponseFromJson(json);

/// offered
@override@JsonKey(name: MarketingConsentOfferResponse.offeredKey_) final  bool offered;
/// reason
@override@JsonKey(name: MarketingConsentOfferResponse.reasonKey_) final  String? reason;
/// wordingVersion
@override@JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_) final  String? wordingVersion;
/// wordingText
@override@JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_) final  String? wordingText;
/// scope
@override@JsonKey(name: MarketingConsentOfferResponse.scopeKey_) final  String scope;
/// terms
 final  List<MarketingTermView>? _terms;
/// terms
@override@JsonKey(name: MarketingConsentOfferResponse.termsKey_) List<MarketingTermView>? get terms {
  final value = _terms;
  if (value == null) return null;
  if (_terms is EqualUnmodifiableListView) return _terms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// defaultTermMonths
@override@JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_) final  int defaultTermMonths;
/// photographerCredit
@override@JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_) final  String? photographerCredit;
/// photos
 final  List<MarketingPhotoView>? _photos;
/// photos
@override@JsonKey(name: MarketingConsentOfferResponse.photosKey_) List<MarketingPhotoView>? get photos {
  final value = _photos;
  if (value == null) return null;
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MarketingConsentOfferResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketingConsentOfferResponseCopyWith<_MarketingConsentOfferResponse> get copyWith => __$MarketingConsentOfferResponseCopyWithImpl<_MarketingConsentOfferResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketingConsentOfferResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketingConsentOfferResponse&&(identical(other.offered, offered) || other.offered == offered)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.wordingVersion, wordingVersion) || other.wordingVersion == wordingVersion)&&(identical(other.wordingText, wordingText) || other.wordingText == wordingText)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other._terms, _terms)&&(identical(other.defaultTermMonths, defaultTermMonths) || other.defaultTermMonths == defaultTermMonths)&&(identical(other.photographerCredit, photographerCredit) || other.photographerCredit == photographerCredit)&&const DeepCollectionEquality().equals(other._photos, _photos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offered,reason,wordingVersion,wordingText,scope,const DeepCollectionEquality().hash(_terms),defaultTermMonths,photographerCredit,const DeepCollectionEquality().hash(_photos));

@override
String toString() {
  return 'MarketingConsentOfferResponse(offered: $offered, reason: $reason, wordingVersion: $wordingVersion, wordingText: $wordingText, scope: $scope, terms: $terms, defaultTermMonths: $defaultTermMonths, photographerCredit: $photographerCredit, photos: $photos)';
}


}

/// @nodoc
abstract mixin class _$MarketingConsentOfferResponseCopyWith<$Res> implements $MarketingConsentOfferResponseCopyWith<$Res> {
  factory _$MarketingConsentOfferResponseCopyWith(_MarketingConsentOfferResponse value, $Res Function(_MarketingConsentOfferResponse) _then) = __$MarketingConsentOfferResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MarketingConsentOfferResponse.offeredKey_) bool offered,@JsonKey(name: MarketingConsentOfferResponse.reasonKey_) String? reason,@JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_) String? wordingVersion,@JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_) String? wordingText,@JsonKey(name: MarketingConsentOfferResponse.scopeKey_) String scope,@JsonKey(name: MarketingConsentOfferResponse.termsKey_) List<MarketingTermView>? terms,@JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_) int defaultTermMonths,@JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_) String? photographerCredit,@JsonKey(name: MarketingConsentOfferResponse.photosKey_) List<MarketingPhotoView>? photos
});




}
/// @nodoc
class __$MarketingConsentOfferResponseCopyWithImpl<$Res>
    implements _$MarketingConsentOfferResponseCopyWith<$Res> {
  __$MarketingConsentOfferResponseCopyWithImpl(this._self, this._then);

  final _MarketingConsentOfferResponse _self;
  final $Res Function(_MarketingConsentOfferResponse) _then;

/// Create a copy of MarketingConsentOfferResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offered = null,Object? reason = freezed,Object? wordingVersion = freezed,Object? wordingText = freezed,Object? scope = null,Object? terms = freezed,Object? defaultTermMonths = null,Object? photographerCredit = freezed,Object? photos = freezed,}) {
  return _then(_MarketingConsentOfferResponse(
offered: null == offered ? _self.offered : offered // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,wordingVersion: freezed == wordingVersion ? _self.wordingVersion : wordingVersion // ignore: cast_nullable_to_non_nullable
as String?,wordingText: freezed == wordingText ? _self.wordingText : wordingText // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,terms: freezed == terms ? _self._terms : terms // ignore: cast_nullable_to_non_nullable
as List<MarketingTermView>?,defaultTermMonths: null == defaultTermMonths ? _self.defaultTermMonths : defaultTermMonths // ignore: cast_nullable_to_non_nullable
as int,photographerCredit: freezed == photographerCredit ? _self.photographerCredit : photographerCredit // ignore: cast_nullable_to_non_nullable
as String?,photos: freezed == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<MarketingPhotoView>?,
  ));
}


}

// dart format on
