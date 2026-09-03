// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_preference_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientPreferenceView {

/// preferredNiches
@JsonKey(name: ClientPreferenceView.preferredNichesKey_) List<String>? get preferredNiches;/// budgetMin
@JsonKey(name: ClientPreferenceView.budgetMinKey_) String? get budgetMin;/// budgetMax
@JsonKey(name: ClientPreferenceView.budgetMaxKey_) String? get budgetMax;/// styleTags
@JsonKey(name: ClientPreferenceView.styleTagsKey_) List<String>? get styleTags;/// location
@JsonKey(name: ClientPreferenceView.locationKey_) Map<String, dynamic>? get location;/// consentDefault
@JsonKey(name: ClientPreferenceView.consentDefaultKey_) GigConsentLevel get consentDefault;/// updatedAt
@JsonKey(name: ClientPreferenceView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of ClientPreferenceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientPreferenceViewCopyWith<ClientPreferenceView> get copyWith => _$ClientPreferenceViewCopyWithImpl<ClientPreferenceView>(this as ClientPreferenceView, _$identity);

  /// Serializes this ClientPreferenceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientPreferenceView&&const DeepCollectionEquality().equals(other.preferredNiches, preferredNiches)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&const DeepCollectionEquality().equals(other.styleTags, styleTags)&&const DeepCollectionEquality().equals(other.location, location)&&(identical(other.consentDefault, consentDefault) || other.consentDefault == consentDefault)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(preferredNiches),budgetMin,budgetMax,const DeepCollectionEquality().hash(styleTags),const DeepCollectionEquality().hash(location),consentDefault,updatedAt);

@override
String toString() {
  return 'ClientPreferenceView(preferredNiches: $preferredNiches, budgetMin: $budgetMin, budgetMax: $budgetMax, styleTags: $styleTags, location: $location, consentDefault: $consentDefault, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClientPreferenceViewCopyWith<$Res>  {
  factory $ClientPreferenceViewCopyWith(ClientPreferenceView value, $Res Function(ClientPreferenceView) _then) = _$ClientPreferenceViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientPreferenceView.preferredNichesKey_) List<String>? preferredNiches,@JsonKey(name: ClientPreferenceView.budgetMinKey_) String? budgetMin,@JsonKey(name: ClientPreferenceView.budgetMaxKey_) String? budgetMax,@JsonKey(name: ClientPreferenceView.styleTagsKey_) List<String>? styleTags,@JsonKey(name: ClientPreferenceView.locationKey_) Map<String, dynamic>? location,@JsonKey(name: ClientPreferenceView.consentDefaultKey_) GigConsentLevel consentDefault,@JsonKey(name: ClientPreferenceView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$ClientPreferenceViewCopyWithImpl<$Res>
    implements $ClientPreferenceViewCopyWith<$Res> {
  _$ClientPreferenceViewCopyWithImpl(this._self, this._then);

  final ClientPreferenceView _self;
  final $Res Function(ClientPreferenceView) _then;

/// Create a copy of ClientPreferenceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preferredNiches = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? styleTags = freezed,Object? location = freezed,Object? consentDefault = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
preferredNiches: freezed == preferredNiches ? _self.preferredNiches : preferredNiches // ignore: cast_nullable_to_non_nullable
as List<String>?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,styleTags: freezed == styleTags ? _self.styleTags : styleTags // ignore: cast_nullable_to_non_nullable
as List<String>?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,consentDefault: null == consentDefault ? _self.consentDefault : consentDefault // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientPreferenceView].
extension ClientPreferenceViewPatterns on ClientPreferenceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientPreferenceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientPreferenceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientPreferenceView value)  $default,){
final _that = this;
switch (_that) {
case _ClientPreferenceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientPreferenceView value)?  $default,){
final _that = this;
switch (_that) {
case _ClientPreferenceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientPreferenceView.preferredNichesKey_)  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceView.budgetMinKey_)  String? budgetMin, @JsonKey(name: ClientPreferenceView.budgetMaxKey_)  String? budgetMax, @JsonKey(name: ClientPreferenceView.styleTagsKey_)  List<String>? styleTags, @JsonKey(name: ClientPreferenceView.locationKey_)  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceView.consentDefaultKey_)  GigConsentLevel consentDefault, @JsonKey(name: ClientPreferenceView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientPreferenceView() when $default != null:
return $default(_that.preferredNiches,_that.budgetMin,_that.budgetMax,_that.styleTags,_that.location,_that.consentDefault,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientPreferenceView.preferredNichesKey_)  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceView.budgetMinKey_)  String? budgetMin, @JsonKey(name: ClientPreferenceView.budgetMaxKey_)  String? budgetMax, @JsonKey(name: ClientPreferenceView.styleTagsKey_)  List<String>? styleTags, @JsonKey(name: ClientPreferenceView.locationKey_)  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceView.consentDefaultKey_)  GigConsentLevel consentDefault, @JsonKey(name: ClientPreferenceView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ClientPreferenceView():
return $default(_that.preferredNiches,_that.budgetMin,_that.budgetMax,_that.styleTags,_that.location,_that.consentDefault,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientPreferenceView.preferredNichesKey_)  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceView.budgetMinKey_)  String? budgetMin, @JsonKey(name: ClientPreferenceView.budgetMaxKey_)  String? budgetMax, @JsonKey(name: ClientPreferenceView.styleTagsKey_)  List<String>? styleTags, @JsonKey(name: ClientPreferenceView.locationKey_)  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceView.consentDefaultKey_)  GigConsentLevel consentDefault, @JsonKey(name: ClientPreferenceView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClientPreferenceView() when $default != null:
return $default(_that.preferredNiches,_that.budgetMin,_that.budgetMax,_that.styleTags,_that.location,_that.consentDefault,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientPreferenceView extends ClientPreferenceView {
  const _ClientPreferenceView({@JsonKey(name: ClientPreferenceView.preferredNichesKey_) final  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceView.budgetMinKey_) this.budgetMin, @JsonKey(name: ClientPreferenceView.budgetMaxKey_) this.budgetMax, @JsonKey(name: ClientPreferenceView.styleTagsKey_) final  List<String>? styleTags, @JsonKey(name: ClientPreferenceView.locationKey_) final  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceView.consentDefaultKey_) required this.consentDefault, @JsonKey(name: ClientPreferenceView.updatedAtKey_) required this.updatedAt}): _preferredNiches = preferredNiches,_styleTags = styleTags,_location = location,super._();
  factory _ClientPreferenceView.fromJson(Map<String, dynamic> json) => _$ClientPreferenceViewFromJson(json);

/// preferredNiches
 final  List<String>? _preferredNiches;
/// preferredNiches
@override@JsonKey(name: ClientPreferenceView.preferredNichesKey_) List<String>? get preferredNiches {
  final value = _preferredNiches;
  if (value == null) return null;
  if (_preferredNiches is EqualUnmodifiableListView) return _preferredNiches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// budgetMin
@override@JsonKey(name: ClientPreferenceView.budgetMinKey_) final  String? budgetMin;
/// budgetMax
@override@JsonKey(name: ClientPreferenceView.budgetMaxKey_) final  String? budgetMax;
/// styleTags
 final  List<String>? _styleTags;
/// styleTags
@override@JsonKey(name: ClientPreferenceView.styleTagsKey_) List<String>? get styleTags {
  final value = _styleTags;
  if (value == null) return null;
  if (_styleTags is EqualUnmodifiableListView) return _styleTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// location
 final  Map<String, dynamic>? _location;
/// location
@override@JsonKey(name: ClientPreferenceView.locationKey_) Map<String, dynamic>? get location {
  final value = _location;
  if (value == null) return null;
  if (_location is EqualUnmodifiableMapView) return _location;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// consentDefault
@override@JsonKey(name: ClientPreferenceView.consentDefaultKey_) final  GigConsentLevel consentDefault;
/// updatedAt
@override@JsonKey(name: ClientPreferenceView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of ClientPreferenceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientPreferenceViewCopyWith<_ClientPreferenceView> get copyWith => __$ClientPreferenceViewCopyWithImpl<_ClientPreferenceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientPreferenceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientPreferenceView&&const DeepCollectionEquality().equals(other._preferredNiches, _preferredNiches)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&const DeepCollectionEquality().equals(other._styleTags, _styleTags)&&const DeepCollectionEquality().equals(other._location, _location)&&(identical(other.consentDefault, consentDefault) || other.consentDefault == consentDefault)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_preferredNiches),budgetMin,budgetMax,const DeepCollectionEquality().hash(_styleTags),const DeepCollectionEquality().hash(_location),consentDefault,updatedAt);

@override
String toString() {
  return 'ClientPreferenceView(preferredNiches: $preferredNiches, budgetMin: $budgetMin, budgetMax: $budgetMax, styleTags: $styleTags, location: $location, consentDefault: $consentDefault, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClientPreferenceViewCopyWith<$Res> implements $ClientPreferenceViewCopyWith<$Res> {
  factory _$ClientPreferenceViewCopyWith(_ClientPreferenceView value, $Res Function(_ClientPreferenceView) _then) = __$ClientPreferenceViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientPreferenceView.preferredNichesKey_) List<String>? preferredNiches,@JsonKey(name: ClientPreferenceView.budgetMinKey_) String? budgetMin,@JsonKey(name: ClientPreferenceView.budgetMaxKey_) String? budgetMax,@JsonKey(name: ClientPreferenceView.styleTagsKey_) List<String>? styleTags,@JsonKey(name: ClientPreferenceView.locationKey_) Map<String, dynamic>? location,@JsonKey(name: ClientPreferenceView.consentDefaultKey_) GigConsentLevel consentDefault,@JsonKey(name: ClientPreferenceView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$ClientPreferenceViewCopyWithImpl<$Res>
    implements _$ClientPreferenceViewCopyWith<$Res> {
  __$ClientPreferenceViewCopyWithImpl(this._self, this._then);

  final _ClientPreferenceView _self;
  final $Res Function(_ClientPreferenceView) _then;

/// Create a copy of ClientPreferenceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preferredNiches = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? styleTags = freezed,Object? location = freezed,Object? consentDefault = null,Object? updatedAt = null,}) {
  return _then(_ClientPreferenceView(
preferredNiches: freezed == preferredNiches ? _self._preferredNiches : preferredNiches // ignore: cast_nullable_to_non_nullable
as List<String>?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,styleTags: freezed == styleTags ? _self._styleTags : styleTags // ignore: cast_nullable_to_non_nullable
as List<String>?,location: freezed == location ? _self._location : location // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,consentDefault: null == consentDefault ? _self.consentDefault : consentDefault // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
