/// CreateProblemReportRequest
/// {
///     "properties": {
///         "reason": {
///             "$ref": "#/components/schemas/ProblemReportReason"
///         },
///         "note": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "maxLength": 1000
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Note"
///         }
///     },
///     "type": "object",
///     "required": [
///         "reason"
///     ],
///     "title": "CreateProblemReportRequest"
/// }
library create_problem_report_request;

import 'exports.dart';
part 'create_problem_report_request.freezed.dart';
part 'create_problem_report_request.g.dart'; // CreateProblemReportRequest

@freezed
abstract class CreateProblemReportRequest with _$CreateProblemReportRequest {
  const CreateProblemReportRequest._();

  @jsonSerializable
  const factory CreateProblemReportRequest({
    /// reason
    @JsonKey(name: CreateProblemReportRequest.reasonKey_)
    required ProblemReportReason reason,

    /// note
    @JsonKey(name: CreateProblemReportRequest.noteKey_) String? note,
  }) = _CreateProblemReportRequest;

  factory CreateProblemReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProblemReportRequestFromJson(json);

  static const String reasonKey_ = r'reason';

  static const String noteKey_ = r'note';
}
