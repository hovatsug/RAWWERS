// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selection_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SelectionResponse {

/// selectionId
@JsonKey(name: SelectionResponse.selectionIdKey_) String get selectionId;/// version
@JsonKey(name: SelectionResponse.versionKey_) int get version;/// status
@JsonKey(name: SelectionResponse.statusKey_) SelectionStatus get status;/// selectedCount
@JsonKey(name: SelectionResponse.selectedCountKey_) int get selectedCount;
/// Create a copy of SelectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectionResponseCopyWith<SelectionResponse> get copyWith => _$SelectionResponseCopyWithImpl<SelectionResponse>(this as SelectionResponse, _$identity);

  /// Serializes this SelectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectionResponse&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.selectedCount, selectedCount) || other.selectedCount == selectedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,version,status,selectedCount);

@override
String toString() {
  return 'SelectionResponse(selectionId: $selectionId, version: $version, status: $status, selectedCount: $selectedCount)';
}


}

/// @nodoc
abstract mixin class $SelectionResponseCopyWith<$Res>  {
  factory $SelectionResponseCopyWith(SelectionResponse value, $Res Function(SelectionResponse) _then) = _$SelectionResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SelectionResponse.selectionIdKey_) String selectionId,@JsonKey(name: SelectionResponse.versionKey_) int version,@JsonKey(name: SelectionResponse.statusKey_) SelectionStatus status,@JsonKey(name: SelectionResponse.selectedCountKey_) int selectedCount
});




}
/// @nodoc
class _$SelectionResponseCopyWithImpl<$Res>
    implements $SelectionResponseCopyWith<$Res> {
  _$SelectionResponseCopyWithImpl(this._self, this._then);

  final SelectionResponse _self;
  final $Res Function(SelectionResponse) _then;

/// Create a copy of SelectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectionId = null,Object? version = null,Object? status = null,Object? selectedCount = null,}) {
  return _then(_self.copyWith(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SelectionStatus,selectedCount: null == selectedCount ? _self.selectedCount : selectedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectionResponse].
extension SelectionResponsePatterns on SelectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SelectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SelectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SelectionResponse.selectionIdKey_)  String selectionId, @JsonKey(name: SelectionResponse.versionKey_)  int version, @JsonKey(name: SelectionResponse.statusKey_)  SelectionStatus status, @JsonKey(name: SelectionResponse.selectedCountKey_)  int selectedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectionResponse() when $default != null:
return $default(_that.selectionId,_that.version,_that.status,_that.selectedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SelectionResponse.selectionIdKey_)  String selectionId, @JsonKey(name: SelectionResponse.versionKey_)  int version, @JsonKey(name: SelectionResponse.statusKey_)  SelectionStatus status, @JsonKey(name: SelectionResponse.selectedCountKey_)  int selectedCount)  $default,) {final _that = this;
switch (_that) {
case _SelectionResponse():
return $default(_that.selectionId,_that.version,_that.status,_that.selectedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SelectionResponse.selectionIdKey_)  String selectionId, @JsonKey(name: SelectionResponse.versionKey_)  int version, @JsonKey(name: SelectionResponse.statusKey_)  SelectionStatus status, @JsonKey(name: SelectionResponse.selectedCountKey_)  int selectedCount)?  $default,) {final _that = this;
switch (_that) {
case _SelectionResponse() when $default != null:
return $default(_that.selectionId,_that.version,_that.status,_that.selectedCount);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SelectionResponse extends SelectionResponse {
  const _SelectionResponse({@JsonKey(name: SelectionResponse.selectionIdKey_) required this.selectionId, @JsonKey(name: SelectionResponse.versionKey_) required this.version, @JsonKey(name: SelectionResponse.statusKey_) required this.status, @JsonKey(name: SelectionResponse.selectedCountKey_) required this.selectedCount}): super._();
  factory _SelectionResponse.fromJson(Map<String, dynamic> json) => _$SelectionResponseFromJson(json);

/// selectionId
@override@JsonKey(name: SelectionResponse.selectionIdKey_) final  String selectionId;
/// version
@override@JsonKey(name: SelectionResponse.versionKey_) final  int version;
/// status
@override@JsonKey(name: SelectionResponse.statusKey_) final  SelectionStatus status;
/// selectedCount
@override@JsonKey(name: SelectionResponse.selectedCountKey_) final  int selectedCount;

/// Create a copy of SelectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectionResponseCopyWith<_SelectionResponse> get copyWith => __$SelectionResponseCopyWithImpl<_SelectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectionResponse&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.selectedCount, selectedCount) || other.selectedCount == selectedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,version,status,selectedCount);

@override
String toString() {
  return 'SelectionResponse(selectionId: $selectionId, version: $version, status: $status, selectedCount: $selectedCount)';
}


}

/// @nodoc
abstract mixin class _$SelectionResponseCopyWith<$Res> implements $SelectionResponseCopyWith<$Res> {
  factory _$SelectionResponseCopyWith(_SelectionResponse value, $Res Function(_SelectionResponse) _then) = __$SelectionResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SelectionResponse.selectionIdKey_) String selectionId,@JsonKey(name: SelectionResponse.versionKey_) int version,@JsonKey(name: SelectionResponse.statusKey_) SelectionStatus status,@JsonKey(name: SelectionResponse.selectedCountKey_) int selectedCount
});




}
/// @nodoc
class __$SelectionResponseCopyWithImpl<$Res>
    implements _$SelectionResponseCopyWith<$Res> {
  __$SelectionResponseCopyWithImpl(this._self, this._then);

  final _SelectionResponse _self;
  final $Res Function(_SelectionResponse) _then;

/// Create a copy of SelectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectionId = null,Object? version = null,Object? status = null,Object? selectedCount = null,}) {
  return _then(_SelectionResponse(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SelectionStatus,selectedCount: null == selectedCount ? _self.selectedCount : selectedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
