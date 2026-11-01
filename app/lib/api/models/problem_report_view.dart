/// ProblemReportView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "reason": {
///             "$ref": "#/components/schemas/ProblemReportReason"
///         },
///         "note": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Note"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "gig_id",
///         "reason",
///         "note",
///         "created_at"
///     ],
///     "title": "ProblemReportView"
/// }
library problem_report_view;

import 'exports.dart';
part 'problem_report_view.freezed.dart';
part 'problem_report_view.g.dart'; // ProblemReportView

@freezed
abstract class ProblemReportView with _$ProblemReportView {
  const ProblemReportView._();

  @jsonSerializable
  const factory ProblemReportView({
    /// id
    @JsonKey(name: ProblemReportView.idKey_) required String id,

    /// gigId
    @JsonKey(name: ProblemReportView.gigIdKey_) required String gigId,

    /// reason
    @JsonKey(name: ProblemReportView.reasonKey_)
    required ProblemReportReason reason,

    /// note
    @JsonKey(name: ProblemReportView.noteKey_) required String? note,

    /// createdAt
    @JsonKey(name: ProblemReportView.createdAtKey_) required DateTime createdAt,
  }) = _ProblemReportView;

  factory ProblemReportView.fromJson(Map<String, dynamic> json) =>
      _$ProblemReportViewFromJson(json);

  static const String idKey_ = r'id';

  static const String gigIdKey_ = r'gig_id';

  static const String reasonKey_ = r'reason';

  static const String noteKey_ = r'note';

  static const String createdAtKey_ = r'created_at';
}
