// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_marketing_agreement_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProMarketingAgreementView {

/// optedIn
@JsonKey(name: ProMarketingAgreementView.optedInKey_) bool get optedIn;/// wordingVersion
@JsonKey(name: ProMarketingAgreementView.wordingVersionKey_) String get wordingVersion;/// wordingText
@JsonKey(name: ProMarketingAgreementView.wordingTextKey_) String get wordingText;/// recordedAt
@JsonKey(name: ProMarketingAgreementView.recordedAtKey_) DateTime? get recordedAt;
/// Create a copy of ProMarketingAgreementView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProMarketingAgreementViewCopyWith<ProMarketingAgreementView> get copyWith => _$ProMarketingAgreementViewCopyWithImpl<ProMarketingAgreementView>(this as ProMarketingAgreementView, _$identity);

  /// Serializes this ProMarketingAgreementView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProMarketingAgreementView&&(identical(other.optedIn, optedIn) || other.optedIn == optedIn)&&(identical(other.wordingVersion, wordingVersion) || other.wordingVersion == wordingVersion)&&(identical(other.wordingText, wordingText) || other.wordingText == wordingText)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,optedIn,wordingVersion,wordingText,recordedAt);

@override
String toString() {
  return 'ProMarketingAgreementView(optedIn: $optedIn, wordingVersion: $wordingVersion, wordingText: $wordingText, recordedAt: $recordedAt)';
}


}

/// @nodoc
abstract mixin class $ProMarketingAgreementViewCopyWith<$Res>  {
  factory $ProMarketingAgreementViewCopyWith(ProMarketingAgreementView value, $Res Function(ProMarketingAgreementView) _then) = _$ProMarketingAgreementViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProMarketingAgreementView.optedInKey_) bool optedIn,@JsonKey(name: ProMarketingAgreementView.wordingVersionKey_) String wordingVersion,@JsonKey(name: ProMarketingAgreementView.wordingTextKey_) String wordingText,@JsonKey(name: ProMarketingAgreementView.recordedAtKey_) DateTime? recordedAt
});




}
/// @nodoc
class _$ProMarketingAgreementViewCopyWithImpl<$Res>
    implements $ProMarketingAgreementViewCopyWith<$Res> {
  _$ProMarketingAgreementViewCopyWithImpl(this._self, this._then);

  final ProMarketingAgreementView _self;
  final $Res Function(ProMarketingAgreementView) _then;

/// Create a copy of ProMarketingAgreementView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? optedIn = null,Object? wordingVersion = null,Object? wordingText = null,Object? recordedAt = freezed,}) {
  return _then(_self.copyWith(
optedIn: null == optedIn ? _self.optedIn : optedIn // ignore: cast_nullable_to_non_nullable
as bool,wordingVersion: null == wordingVersion ? _self.wordingVersion : wordingVersion // ignore: cast_nullable_to_non_nullable
as String,wordingText: null == wordingText ? _self.wordingText : wordingText // ignore: cast_nullable_to_non_nullable
as String,recordedAt: freezed == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProMarketingAgreementView].
extension ProMarketingAgreementViewPatterns on ProMarketingAgreementView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProMarketingAgreementView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProMarketingAgreementView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProMarketingAgreementView value)  $default,){
final _that = this;
switch (_that) {
case _ProMarketingAgreementView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProMarketingAgreementView value)?  $default,){
final _that = this;
switch (_that) {
case _ProMarketingAgreementView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProMarketingAgreementView.optedInKey_)  bool optedIn, @JsonKey(name: ProMarketingAgreementView.wordingVersionKey_)  String wordingVersion, @JsonKey(name: ProMarketingAgreementView.wordingTextKey_)  String wordingText, @JsonKey(name: ProMarketingAgreementView.recordedAtKey_)  DateTime? recordedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProMarketingAgreementView() when $default != null:
return $default(_that.optedIn,_that.wordingVersion,_that.wordingText,_that.recordedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProMarketingAgreementView.optedInKey_)  bool optedIn, @JsonKey(name: ProMarketingAgreementView.wordingVersionKey_)  String wordingVersion, @JsonKey(name: ProMarketingAgreementView.wordingTextKey_)  String wordingText, @JsonKey(name: ProMarketingAgreementView.recordedAtKey_)  DateTime? recordedAt)  $default,) {final _that = this;
switch (_that) {
case _ProMarketingAgreementView():
return $default(_that.optedIn,_that.wordingVersion,_that.wordingText,_that.recordedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProMarketingAgreementView.optedInKey_)  bool optedIn, @JsonKey(name: ProMarketingAgreementView.wordingVersionKey_)  String wordingVersion, @JsonKey(name: ProMarketingAgreementView.wordingTextKey_)  String wordingText, @JsonKey(name: ProMarketingAgreementView.recordedAtKey_)  DateTime? recordedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProMarketingAgreementView() when $default != null:
return $default(_that.optedIn,_that.wordingVersion,_that.wordingText,_that.recordedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProMarketingAgreementView extends ProMarketingAgreementView {
  const _ProMarketingAgreementView({@JsonKey(name: ProMarketingAgreementView.optedInKey_) required this.optedIn, @JsonKey(name: ProMarketingAgreementView.wordingVersionKey_) required this.wordingVersion, @JsonKey(name: ProMarketingAgreementView.wordingTextKey_) required this.wordingText, @JsonKey(name: ProMarketingAgreementView.recordedAtKey_) this.recordedAt}): super._();
  factory _ProMarketingAgreementView.fromJson(Map<String, dynamic> json) => _$ProMarketingAgreementViewFromJson(json);

/// optedIn
@override@JsonKey(name: ProMarketingAgreementView.optedInKey_) final  bool optedIn;
/// wordingVersion
@override@JsonKey(name: ProMarketingAgreementView.wordingVersionKey_) final  String wordingVersion;
/// wordingText
@override@JsonKey(name: ProMarketingAgreementView.wordingTextKey_) final  String wordingText;
/// recordedAt
@override@JsonKey(name: ProMarketingAgreementView.recordedAtKey_) final  DateTime? recordedAt;

/// Create a copy of ProMarketingAgreementView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProMarketingAgreementViewCopyWith<_ProMarketingAgreementView> get copyWith => __$ProMarketingAgreementViewCopyWithImpl<_ProMarketingAgreementView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProMarketingAgreementViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProMarketingAgreementView&&(identical(other.optedIn, optedIn) || other.optedIn == optedIn)&&(identical(other.wordingVersion, wordingVersion) || other.wordingVersion == wordingVersion)&&(identical(other.wordingText, wordingText) || other.wordingText == wordingText)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,optedIn,wordingVersion,wordingText,recordedAt);

@override
String toString() {
  return 'ProMarketingAgreementView(optedIn: $optedIn, wordingVersion: $wordingVersion, wordingText: $wordingText, recordedAt: $recordedAt)';
}


}

/// @nodoc
abstract mixin class _$ProMarketingAgreementViewCopyWith<$Res> implements $ProMarketingAgreementViewCopyWith<$Res> {
  factory _$ProMarketingAgreementViewCopyWith(_ProMarketingAgreementView value, $Res Function(_ProMarketingAgreementView) _then) = __$ProMarketingAgreementViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProMarketingAgreementView.optedInKey_) bool optedIn,@JsonKey(name: ProMarketingAgreementView.wordingVersionKey_) String wordingVersion,@JsonKey(name: ProMarketingAgreementView.wordingTextKey_) String wordingText,@JsonKey(name: ProMarketingAgreementView.recordedAtKey_) DateTime? recordedAt
});




}
/// @nodoc
class __$ProMarketingAgreementViewCopyWithImpl<$Res>
    implements _$ProMarketingAgreementViewCopyWith<$Res> {
  __$ProMarketingAgreementViewCopyWithImpl(this._self, this._then);

  final _ProMarketingAgreementView _self;
  final $Res Function(_ProMarketingAgreementView) _then;

/// Create a copy of ProMarketingAgreementView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? optedIn = null,Object? wordingVersion = null,Object? wordingText = null,Object? recordedAt = freezed,}) {
  return _then(_ProMarketingAgreementView(
optedIn: null == optedIn ? _self.optedIn : optedIn // ignore: cast_nullable_to_non_nullable
as bool,wordingVersion: null == wordingVersion ? _self.wordingVersion : wordingVersion // ignore: cast_nullable_to_non_nullable
as String,wordingText: null == wordingText ? _self.wordingText : wordingText // ignore: cast_nullable_to_non_nullable
as String,recordedAt: freezed == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
