// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_currency_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayCurrencyView {

/// displayCurrency
@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_) String get displayCurrency;/// chosen
@JsonKey(name: DisplayCurrencyView.chosenKey_) bool get chosen;/// available
@JsonKey(name: DisplayCurrencyView.availableKey_) List<String> get available;
/// Create a copy of DisplayCurrencyView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayCurrencyViewCopyWith<DisplayCurrencyView> get copyWith => _$DisplayCurrencyViewCopyWithImpl<DisplayCurrencyView>(this as DisplayCurrencyView, _$identity);

  /// Serializes this DisplayCurrencyView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayCurrencyView&&(identical(other.displayCurrency, displayCurrency) || other.displayCurrency == displayCurrency)&&(identical(other.chosen, chosen) || other.chosen == chosen)&&const DeepCollectionEquality().equals(other.available, available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayCurrency,chosen,const DeepCollectionEquality().hash(available));

@override
String toString() {
  return 'DisplayCurrencyView(displayCurrency: $displayCurrency, chosen: $chosen, available: $available)';
}


}

/// @nodoc
abstract mixin class $DisplayCurrencyViewCopyWith<$Res>  {
  factory $DisplayCurrencyViewCopyWith(DisplayCurrencyView value, $Res Function(DisplayCurrencyView) _then) = _$DisplayCurrencyViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_) String displayCurrency,@JsonKey(name: DisplayCurrencyView.chosenKey_) bool chosen,@JsonKey(name: DisplayCurrencyView.availableKey_) List<String> available
});




}
/// @nodoc
class _$DisplayCurrencyViewCopyWithImpl<$Res>
    implements $DisplayCurrencyViewCopyWith<$Res> {
  _$DisplayCurrencyViewCopyWithImpl(this._self, this._then);

  final DisplayCurrencyView _self;
  final $Res Function(DisplayCurrencyView) _then;

/// Create a copy of DisplayCurrencyView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayCurrency = null,Object? chosen = null,Object? available = null,}) {
  return _then(_self.copyWith(
displayCurrency: null == displayCurrency ? _self.displayCurrency : displayCurrency // ignore: cast_nullable_to_non_nullable
as String,chosen: null == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayCurrencyView].
extension DisplayCurrencyViewPatterns on DisplayCurrencyView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayCurrencyView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayCurrencyView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayCurrencyView value)  $default,){
final _that = this;
switch (_that) {
case _DisplayCurrencyView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayCurrencyView value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayCurrencyView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_)  String displayCurrency, @JsonKey(name: DisplayCurrencyView.chosenKey_)  bool chosen, @JsonKey(name: DisplayCurrencyView.availableKey_)  List<String> available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayCurrencyView() when $default != null:
return $default(_that.displayCurrency,_that.chosen,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_)  String displayCurrency, @JsonKey(name: DisplayCurrencyView.chosenKey_)  bool chosen, @JsonKey(name: DisplayCurrencyView.availableKey_)  List<String> available)  $default,) {final _that = this;
switch (_that) {
case _DisplayCurrencyView():
return $default(_that.displayCurrency,_that.chosen,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_)  String displayCurrency, @JsonKey(name: DisplayCurrencyView.chosenKey_)  bool chosen, @JsonKey(name: DisplayCurrencyView.availableKey_)  List<String> available)?  $default,) {final _that = this;
switch (_that) {
case _DisplayCurrencyView() when $default != null:
return $default(_that.displayCurrency,_that.chosen,_that.available);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisplayCurrencyView extends DisplayCurrencyView {
  const _DisplayCurrencyView({@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_) required this.displayCurrency, @JsonKey(name: DisplayCurrencyView.chosenKey_) required this.chosen, @JsonKey(name: DisplayCurrencyView.availableKey_) required final  List<String> available}): _available = available,super._();
  factory _DisplayCurrencyView.fromJson(Map<String, dynamic> json) => _$DisplayCurrencyViewFromJson(json);

/// displayCurrency
@override@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_) final  String displayCurrency;
/// chosen
@override@JsonKey(name: DisplayCurrencyView.chosenKey_) final  bool chosen;
/// available
 final  List<String> _available;
/// available
@override@JsonKey(name: DisplayCurrencyView.availableKey_) List<String> get available {
  if (_available is EqualUnmodifiableListView) return _available;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_available);
}


/// Create a copy of DisplayCurrencyView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayCurrencyViewCopyWith<_DisplayCurrencyView> get copyWith => __$DisplayCurrencyViewCopyWithImpl<_DisplayCurrencyView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayCurrencyViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayCurrencyView&&(identical(other.displayCurrency, displayCurrency) || other.displayCurrency == displayCurrency)&&(identical(other.chosen, chosen) || other.chosen == chosen)&&const DeepCollectionEquality().equals(other._available, _available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayCurrency,chosen,const DeepCollectionEquality().hash(_available));

@override
String toString() {
  return 'DisplayCurrencyView(displayCurrency: $displayCurrency, chosen: $chosen, available: $available)';
}


}

/// @nodoc
abstract mixin class _$DisplayCurrencyViewCopyWith<$Res> implements $DisplayCurrencyViewCopyWith<$Res> {
  factory _$DisplayCurrencyViewCopyWith(_DisplayCurrencyView value, $Res Function(_DisplayCurrencyView) _then) = __$DisplayCurrencyViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisplayCurrencyView.displayCurrencyKey_) String displayCurrency,@JsonKey(name: DisplayCurrencyView.chosenKey_) bool chosen,@JsonKey(name: DisplayCurrencyView.availableKey_) List<String> available
});




}
/// @nodoc
class __$DisplayCurrencyViewCopyWithImpl<$Res>
    implements _$DisplayCurrencyViewCopyWith<$Res> {
  __$DisplayCurrencyViewCopyWithImpl(this._self, this._then);

  final _DisplayCurrencyView _self;
  final $Res Function(_DisplayCurrencyView) _then;

/// Create a copy of DisplayCurrencyView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayCurrency = null,Object? chosen = null,Object? available = null,}) {
  return _then(_DisplayCurrencyView(
displayCurrency: null == displayCurrency ? _self.displayCurrency : displayCurrency // ignore: cast_nullable_to_non_nullable
as String,chosen: null == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self._available : available // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
