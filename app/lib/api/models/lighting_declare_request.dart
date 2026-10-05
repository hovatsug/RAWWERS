/// LightingDeclareRequest
/// {
///     "properties": {
///         "make": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Make"
///         },
///         "model": {
///             "type": "string",
///             "title": "Model"
///         },
///         "notes": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Notes"
///         }
///     },
///     "type": "object",
///     "required": [
///         "model"
///     ],
///     "title": "LightingDeclareRequest"
/// }
library lighting_declare_request;

import 'exports.dart';
part 'lighting_declare_request.freezed.dart';
part 'lighting_declare_request.g.dart'; // LightingDeclareRequest

@freezed
abstract class LightingDeclareRequest with _$LightingDeclareRequest {
  const LightingDeclareRequest._();

  @jsonSerializable
  const factory LightingDeclareRequest({
    /// make
    @JsonKey(name: LightingDeclareRequest.makeKey_) String? make,

    /// model
    @JsonKey(name: LightingDeclareRequest.modelKey_) required String model,

    /// notes
    @JsonKey(name: LightingDeclareRequest.notesKey_) String? notes,
  }) = _LightingDeclareRequest;

  factory LightingDeclareRequest.fromJson(Map<String, dynamic> json) =>
      _$LightingDeclareRequestFromJson(json);

  static const String makeKey_ = r'make';

  static const String modelKey_ = r'model';

  static const String notesKey_ = r'notes';
}
