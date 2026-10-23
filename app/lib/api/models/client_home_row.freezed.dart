// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_home_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientHomeRow {

/// key
@JsonKey(name: ClientHomeRow.keyKey_) String get key;/// title
@JsonKey(name: ClientHomeRow.titleKey_) String get title;/// subtitle
@JsonKey(name: ClientHomeRow.subtitleKey_) String? get subtitle;/// items
@JsonKey(name: ClientHomeRow.itemsKey_) List<ClientDiscoverCard>? get items;/// banner
@JsonKey(name: ClientHomeRow.bannerKey_) NicheBannerView? get banner;
/// Create a copy of ClientHomeRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientHomeRowCopyWith<ClientHomeRow> get copyWith => _$ClientHomeRowCopyWithImpl<ClientHomeRow>(this as ClientHomeRow, _$identity);

  /// Serializes this ClientHomeRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientHomeRow&&(identical(other.key, key) || other.key == key)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.banner, banner) || other.banner == banner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,title,subtitle,const DeepCollectionEquality().hash(items),banner);

@override
String toString() {
  return 'ClientHomeRow(key: $key, title: $title, subtitle: $subtitle, items: $items, banner: $banner)';
}


}

/// @nodoc
abstract mixin class $ClientHomeRowCopyWith<$Res>  {
  factory $ClientHomeRowCopyWith(ClientHomeRow value, $Res Function(ClientHomeRow) _then) = _$ClientHomeRowCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientHomeRow.keyKey_) String key,@JsonKey(name: ClientHomeRow.titleKey_) String title,@JsonKey(name: ClientHomeRow.subtitleKey_) String? subtitle,@JsonKey(name: ClientHomeRow.itemsKey_) List<ClientDiscoverCard>? items,@JsonKey(name: ClientHomeRow.bannerKey_) NicheBannerView? banner
});


$NicheBannerViewCopyWith<$Res>? get banner;

}
/// @nodoc
class _$ClientHomeRowCopyWithImpl<$Res>
    implements $ClientHomeRowCopyWith<$Res> {
  _$ClientHomeRowCopyWithImpl(this._self, this._then);

  final ClientHomeRow _self;
  final $Res Function(ClientHomeRow) _then;

/// Create a copy of ClientHomeRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? title = null,Object? subtitle = freezed,Object? items = freezed,Object? banner = freezed,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ClientDiscoverCard>?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as NicheBannerView?,
  ));
}
/// Create a copy of ClientHomeRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NicheBannerViewCopyWith<$Res>? get banner {
    if (_self.banner == null) {
    return null;
  }

  return $NicheBannerViewCopyWith<$Res>(_self.banner!, (value) {
    return _then(_self.copyWith(banner: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientHomeRow].
extension ClientHomeRowPatterns on ClientHomeRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientHomeRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientHomeRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientHomeRow value)  $default,){
final _that = this;
switch (_that) {
case _ClientHomeRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientHomeRow value)?  $default,){
final _that = this;
switch (_that) {
case _ClientHomeRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientHomeRow.keyKey_)  String key, @JsonKey(name: ClientHomeRow.titleKey_)  String title, @JsonKey(name: ClientHomeRow.subtitleKey_)  String? subtitle, @JsonKey(name: ClientHomeRow.itemsKey_)  List<ClientDiscoverCard>? items, @JsonKey(name: ClientHomeRow.bannerKey_)  NicheBannerView? banner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientHomeRow() when $default != null:
return $default(_that.key,_that.title,_that.subtitle,_that.items,_that.banner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientHomeRow.keyKey_)  String key, @JsonKey(name: ClientHomeRow.titleKey_)  String title, @JsonKey(name: ClientHomeRow.subtitleKey_)  String? subtitle, @JsonKey(name: ClientHomeRow.itemsKey_)  List<ClientDiscoverCard>? items, @JsonKey(name: ClientHomeRow.bannerKey_)  NicheBannerView? banner)  $default,) {final _that = this;
switch (_that) {
case _ClientHomeRow():
return $default(_that.key,_that.title,_that.subtitle,_that.items,_that.banner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientHomeRow.keyKey_)  String key, @JsonKey(name: ClientHomeRow.titleKey_)  String title, @JsonKey(name: ClientHomeRow.subtitleKey_)  String? subtitle, @JsonKey(name: ClientHomeRow.itemsKey_)  List<ClientDiscoverCard>? items, @JsonKey(name: ClientHomeRow.bannerKey_)  NicheBannerView? banner)?  $default,) {final _that = this;
switch (_that) {
case _ClientHomeRow() when $default != null:
return $default(_that.key,_that.title,_that.subtitle,_that.items,_that.banner);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientHomeRow extends ClientHomeRow {
  const _ClientHomeRow({@JsonKey(name: ClientHomeRow.keyKey_) required this.key, @JsonKey(name: ClientHomeRow.titleKey_) required this.title, @JsonKey(name: ClientHomeRow.subtitleKey_) this.subtitle, @JsonKey(name: ClientHomeRow.itemsKey_) final  List<ClientDiscoverCard>? items, @JsonKey(name: ClientHomeRow.bannerKey_) this.banner}): _items = items,super._();
  factory _ClientHomeRow.fromJson(Map<String, dynamic> json) => _$ClientHomeRowFromJson(json);

/// key
@override@JsonKey(name: ClientHomeRow.keyKey_) final  String key;
/// title
@override@JsonKey(name: ClientHomeRow.titleKey_) final  String title;
/// subtitle
@override@JsonKey(name: ClientHomeRow.subtitleKey_) final  String? subtitle;
/// items
 final  List<ClientDiscoverCard>? _items;
/// items
@override@JsonKey(name: ClientHomeRow.itemsKey_) List<ClientDiscoverCard>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// banner
@override@JsonKey(name: ClientHomeRow.bannerKey_) final  NicheBannerView? banner;

/// Create a copy of ClientHomeRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientHomeRowCopyWith<_ClientHomeRow> get copyWith => __$ClientHomeRowCopyWithImpl<_ClientHomeRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientHomeRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientHomeRow&&(identical(other.key, key) || other.key == key)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.banner, banner) || other.banner == banner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,title,subtitle,const DeepCollectionEquality().hash(_items),banner);

@override
String toString() {
  return 'ClientHomeRow(key: $key, title: $title, subtitle: $subtitle, items: $items, banner: $banner)';
}


}

/// @nodoc
abstract mixin class _$ClientHomeRowCopyWith<$Res> implements $ClientHomeRowCopyWith<$Res> {
  factory _$ClientHomeRowCopyWith(_ClientHomeRow value, $Res Function(_ClientHomeRow) _then) = __$ClientHomeRowCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientHomeRow.keyKey_) String key,@JsonKey(name: ClientHomeRow.titleKey_) String title,@JsonKey(name: ClientHomeRow.subtitleKey_) String? subtitle,@JsonKey(name: ClientHomeRow.itemsKey_) List<ClientDiscoverCard>? items,@JsonKey(name: ClientHomeRow.bannerKey_) NicheBannerView? banner
});


@override $NicheBannerViewCopyWith<$Res>? get banner;

}
/// @nodoc
class __$ClientHomeRowCopyWithImpl<$Res>
    implements _$ClientHomeRowCopyWith<$Res> {
  __$ClientHomeRowCopyWithImpl(this._self, this._then);

  final _ClientHomeRow _self;
  final $Res Function(_ClientHomeRow) _then;

/// Create a copy of ClientHomeRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? title = null,Object? subtitle = freezed,Object? items = freezed,Object? banner = freezed,}) {
  return _then(_ClientHomeRow(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ClientDiscoverCard>?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as NicheBannerView?,
  ));
}

/// Create a copy of ClientHomeRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NicheBannerViewCopyWith<$Res>? get banner {
    if (_self.banner == null) {
    return null;
  }

  return $NicheBannerViewCopyWith<$Res>(_self.banner!, (value) {
    return _then(_self.copyWith(banner: value));
  });
}
}

// dart format on
