// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_listing_preview_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProListingPreviewResponse {

/// card
@JsonKey(name: ProListingPreviewResponse.cardKey_) ClientDiscoverCard get card;/// isLive
@JsonKey(name: ProListingPreviewResponse.isLiveKey_) bool get isLive;/// blockingReasons
@JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_) List<String>? get blockingReasons;/// availableDaysNext14
@JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_) int? get availableDaysNext14;
/// Create a copy of ProListingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProListingPreviewResponseCopyWith<ProListingPreviewResponse> get copyWith => _$ProListingPreviewResponseCopyWithImpl<ProListingPreviewResponse>(this as ProListingPreviewResponse, _$identity);

  /// Serializes this ProListingPreviewResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProListingPreviewResponse&&(identical(other.card, card) || other.card == card)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&const DeepCollectionEquality().equals(other.blockingReasons, blockingReasons)&&(identical(other.availableDaysNext14, availableDaysNext14) || other.availableDaysNext14 == availableDaysNext14));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,card,isLive,const DeepCollectionEquality().hash(blockingReasons),availableDaysNext14);

@override
String toString() {
  return 'ProListingPreviewResponse(card: $card, isLive: $isLive, blockingReasons: $blockingReasons, availableDaysNext14: $availableDaysNext14)';
}


}

/// @nodoc
abstract mixin class $ProListingPreviewResponseCopyWith<$Res>  {
  factory $ProListingPreviewResponseCopyWith(ProListingPreviewResponse value, $Res Function(ProListingPreviewResponse) _then) = _$ProListingPreviewResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProListingPreviewResponse.cardKey_) ClientDiscoverCard card,@JsonKey(name: ProListingPreviewResponse.isLiveKey_) bool isLive,@JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_) List<String>? blockingReasons,@JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_) int? availableDaysNext14
});


$ClientDiscoverCardCopyWith<$Res> get card;

}
/// @nodoc
class _$ProListingPreviewResponseCopyWithImpl<$Res>
    implements $ProListingPreviewResponseCopyWith<$Res> {
  _$ProListingPreviewResponseCopyWithImpl(this._self, this._then);

  final ProListingPreviewResponse _self;
  final $Res Function(ProListingPreviewResponse) _then;

/// Create a copy of ProListingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? card = null,Object? isLive = null,Object? blockingReasons = freezed,Object? availableDaysNext14 = freezed,}) {
  return _then(_self.copyWith(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as ClientDiscoverCard,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,blockingReasons: freezed == blockingReasons ? _self.blockingReasons : blockingReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,availableDaysNext14: freezed == availableDaysNext14 ? _self.availableDaysNext14 : availableDaysNext14 // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ProListingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientDiscoverCardCopyWith<$Res> get card {
  
  return $ClientDiscoverCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProListingPreviewResponse].
extension ProListingPreviewResponsePatterns on ProListingPreviewResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProListingPreviewResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProListingPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProListingPreviewResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProListingPreviewResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProListingPreviewResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProListingPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProListingPreviewResponse.cardKey_)  ClientDiscoverCard card, @JsonKey(name: ProListingPreviewResponse.isLiveKey_)  bool isLive, @JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_)  List<String>? blockingReasons, @JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_)  int? availableDaysNext14)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProListingPreviewResponse() when $default != null:
return $default(_that.card,_that.isLive,_that.blockingReasons,_that.availableDaysNext14);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProListingPreviewResponse.cardKey_)  ClientDiscoverCard card, @JsonKey(name: ProListingPreviewResponse.isLiveKey_)  bool isLive, @JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_)  List<String>? blockingReasons, @JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_)  int? availableDaysNext14)  $default,) {final _that = this;
switch (_that) {
case _ProListingPreviewResponse():
return $default(_that.card,_that.isLive,_that.blockingReasons,_that.availableDaysNext14);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProListingPreviewResponse.cardKey_)  ClientDiscoverCard card, @JsonKey(name: ProListingPreviewResponse.isLiveKey_)  bool isLive, @JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_)  List<String>? blockingReasons, @JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_)  int? availableDaysNext14)?  $default,) {final _that = this;
switch (_that) {
case _ProListingPreviewResponse() when $default != null:
return $default(_that.card,_that.isLive,_that.blockingReasons,_that.availableDaysNext14);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProListingPreviewResponse extends ProListingPreviewResponse {
  const _ProListingPreviewResponse({@JsonKey(name: ProListingPreviewResponse.cardKey_) required this.card, @JsonKey(name: ProListingPreviewResponse.isLiveKey_) required this.isLive, @JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_) final  List<String>? blockingReasons, @JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_) this.availableDaysNext14}): _blockingReasons = blockingReasons,super._();
  factory _ProListingPreviewResponse.fromJson(Map<String, dynamic> json) => _$ProListingPreviewResponseFromJson(json);

/// card
@override@JsonKey(name: ProListingPreviewResponse.cardKey_) final  ClientDiscoverCard card;
/// isLive
@override@JsonKey(name: ProListingPreviewResponse.isLiveKey_) final  bool isLive;
/// blockingReasons
 final  List<String>? _blockingReasons;
/// blockingReasons
@override@JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_) List<String>? get blockingReasons {
  final value = _blockingReasons;
  if (value == null) return null;
  if (_blockingReasons is EqualUnmodifiableListView) return _blockingReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// availableDaysNext14
@override@JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_) final  int? availableDaysNext14;

/// Create a copy of ProListingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProListingPreviewResponseCopyWith<_ProListingPreviewResponse> get copyWith => __$ProListingPreviewResponseCopyWithImpl<_ProListingPreviewResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProListingPreviewResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProListingPreviewResponse&&(identical(other.card, card) || other.card == card)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&const DeepCollectionEquality().equals(other._blockingReasons, _blockingReasons)&&(identical(other.availableDaysNext14, availableDaysNext14) || other.availableDaysNext14 == availableDaysNext14));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,card,isLive,const DeepCollectionEquality().hash(_blockingReasons),availableDaysNext14);

@override
String toString() {
  return 'ProListingPreviewResponse(card: $card, isLive: $isLive, blockingReasons: $blockingReasons, availableDaysNext14: $availableDaysNext14)';
}


}

/// @nodoc
abstract mixin class _$ProListingPreviewResponseCopyWith<$Res> implements $ProListingPreviewResponseCopyWith<$Res> {
  factory _$ProListingPreviewResponseCopyWith(_ProListingPreviewResponse value, $Res Function(_ProListingPreviewResponse) _then) = __$ProListingPreviewResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProListingPreviewResponse.cardKey_) ClientDiscoverCard card,@JsonKey(name: ProListingPreviewResponse.isLiveKey_) bool isLive,@JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_) List<String>? blockingReasons,@JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_) int? availableDaysNext14
});


@override $ClientDiscoverCardCopyWith<$Res> get card;

}
/// @nodoc
class __$ProListingPreviewResponseCopyWithImpl<$Res>
    implements _$ProListingPreviewResponseCopyWith<$Res> {
  __$ProListingPreviewResponseCopyWithImpl(this._self, this._then);

  final _ProListingPreviewResponse _self;
  final $Res Function(_ProListingPreviewResponse) _then;

/// Create a copy of ProListingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? card = null,Object? isLive = null,Object? blockingReasons = freezed,Object? availableDaysNext14 = freezed,}) {
  return _then(_ProListingPreviewResponse(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as ClientDiscoverCard,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,blockingReasons: freezed == blockingReasons ? _self._blockingReasons : blockingReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,availableDaysNext14: freezed == availableDaysNext14 ? _self.availableDaysNext14 : availableDaysNext14 // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ProListingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientDiscoverCardCopyWith<$Res> get card {
  
  return $ClientDiscoverCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

// dart format on
